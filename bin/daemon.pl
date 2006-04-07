#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use File::Slurp qw(read_file);
use Time::HiRes qw(sleep);
use POE qw(Component::Server::HTTP Wheel::Run);

#-----------------------------------------------------------------------
# usage
#-----------------------------------------------------------------------
die "usage: $0 <driver> [ <initial-script> ]" if @ARGV == 0 or @ARGV > 2;
my ( $driver, $initial_script ) = @ARGV;

#-----------------------------------------------------------------------
# initialize driver
#-----------------------------------------------------------------------

# load the package and import subroutines
my $driver_package = "CrewDisplay::$driver";
use lib "$Bin/../lib";
eval "use $driver_package";
die $@ if $@;

# grab the filehandle that we'll write to
my $fh = $driver_package->fh;
print $fh init();

#-----------------------------------------------------------------------
# initialize scripts
#-----------------------------------------------------------------------
my $script_dir = "$Bin/../scripts";

sub list_scripts {

    # /path/to/display/scripts/foo.pl -> foo
    return map { m{$script_dir/(.+)\.pl}; $1 } glob("$script_dir/*.pl");
}
die "no scripts found" unless list_scripts();

# if we haven't set a script on the command line, pick the first one
my $current_script_name = $initial_script || [ list_scripts() ]->[0];

#-----------------------------------------------------------------------
# POE - see http://poe.perl.org/
#-----------------------------------------------------------------------

# first, create a session that repeats our script
POE::Session->create(
    inline_states => {
        _start => sub {
            my $kernel = $_[KERNEL];
            $kernel->alias_set('main_loop');
            $kernel->yield('pre_run_delay');
        },

        pre_run_delay => sub {
            my $kernel = $_[KERNEL];
            $kernel->delay( run_current_script => 1 );
        },

        run_current_script => sub {
            my $heap = $_[HEAP];

            $heap->{wheel} = POE::Wheel::Run->new(
                Program => sub {
                    select $fh;
                    eval { do "$script_dir/$current_script_name.pl" };
                    warn $@ if $@;
                },
                CloseEvent  => 'script_finished',
                StderrEvent => 'script_error',
            );
        },

        script_error => sub {
            warn $_[ARG0];
        },

        script_finished => sub {
            my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];
            delete $heap->{wheel};
            $kernel->yield('pre_run_delay');
        },
    }
);

# next, create a session for the web server
POE::Component::Server::HTTP->new(
    Port           => 3140,
    ContentHandler => {
        '/'     => \&web_index,
        '/set/' => \&web_set,
    },
);

#-----------------------------------------------------------------------
# web server handlers
#-----------------------------------------------------------------------

sub web_index {
    my ( $request, $response ) = @_;
    $response->code(RC_OK);
    $response->push_header( "Content-Type", "text/html" );

    my $content =
        "<p>Current script: $current_script_name</p>"
      . "<p>Available scripts:</p>";
    $content .= qq{<a href="/set/$_">$_</a><br/>} for list_scripts();
    $response->content($content);

    return RC_OK;
}

sub web_set {
    my ( $request, $response ) = @_;
    $response->code(RC_OK);

    my ($chosen) = ( $request->uri =~ m{ /set/ ([\w-]+) \Z }sx );
    if ( defined $chosen and -e "$script_dir/$chosen.pl" ) {

        print "set script to $chosen\n";
        $current_script_name = $chosen;

        if ( my $session = $poe_kernel->alias_resolve('main_loop') ) {
            if ( my $heap = $session->get_heap ) {
                if ( my $wheel = $heap->{wheel} ) {
                    $wheel->kill;
                }
            }
        }

        print $fh init();

        $response->push_header( "Content-Type", "text/html" );
        $response->content( qq{<p>Script set to $chosen</p>}
              . qq{<p><a href="javascript:back()">&larr; back</a></p>} );
    }
    else {
        $response->content("couldn't find specified script");
    }

    return RC_OK;
}

#-----------------------------------------------------------------------
# main
#-----------------------------------------------------------------------

# hitting ^C should make is exit nicely (well, POE doesn't like exit(), but we
# don't care about that) -- this way, any END blocks get called.
# (CrewDisplay::xterm uses an END block to remove a named pipe in /tmp)
$poe_kernel->sig( INT => sub { exit } );

# typical POE thing to do
$poe_kernel->run;
exit 0;
