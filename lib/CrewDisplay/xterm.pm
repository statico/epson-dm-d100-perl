package CrewDisplay::xterm;
use strict;
use warnings;

use base 'Exporter';

use File::Temp qw(tmpnam);
use IO::File;
use Carp;

# options, currently not configurable
my %o = (
    width  => 20,
    height => 2,
);

# create our named pipe
my $fifo = tmpnam();
qx(mkfifo $fifo);

# WTF? why doesn't *this* work?
#system( mkfifo => $fifo );
#ie "mkfifo failed, \$? = $?" if $? != 0;

# fire up a new xterm to read from the pipe
my $child_pid = fork;
die "fork failed" if not defined $child_pid;
if ( $child_pid == 0 ) {
    exec(
        'xterm',
        -bg       => 'lightgreen',
        -fg       => 'black',
        -font     => '10x20',
        -geometry => "$o{width}x$o{height}",
        -e => ( 'cat', $fifo ),
    );
}

# create a filehandle which we can use
my $fh = IO::File->new( $fifo, 'w' ) or die $!;
$fh->autoflush(1);

# make sure our named pipe is reaped when we exit
END {
    close $fh;
    unlink $fifo;
}

# a method that returns our filehandle
sub fh { $fh }

# now, terminal sequences for xterm
my %commands = (
    move_left      => "\e[1D",
    move_right     => "\e[1C",
    move_down      => "\e[1B",
    move_up        => "\e[1A",
    move_home      => "\e[H",
    move_leftmost  => "\e[$o{width}D",
    move_rightmost => "\e[$o{width}C",
    move_bottom    => "\e[$o{height}B",
    move_to        => sub {
        my ( $x, $y ) = @_;
        croak "column out of range" if $x < 1 or $x > 20;
        croak "row out of range"    if $y < 1 or $y > 2;
        ( $x, $y ) = map { $_ - 1 } ( $x, $y );
        "\e[${y};${x}H";
    },
    clear       => "\e[2J",
    clear_line  => "\e[2K",
    init        => "\ec",
    set_charset => sub {
        my ($n) = @_;
        croak "charset number out of range" if $n < 0 or $n > 1;
        "\e" . ( $n ? ')' : '(' );
    },
    overwrite_mode    => sub { carp "modes unimplemented",         q{} },
    vertscroll_mode   => "\e[?7h",
    horzscroll_mode   => "\e[?7l",
    hide_cursor       => "\e[?25l",
    show_cursor       => "\e[?25h",
    display_off       => sub { carp "on/off unimplemented",        q{} },
    display_on        => sub { carp "on/off unimplemented",        q{} },
    set_blinkinterval => sub { carp "blink unimplemented",         q{} },
    set_and_show_time => sub { carp "show and time unimplemented", q{} },
    set_time          => sub { carp "show and time unimplemented", q{} },
    set_brightness    => sub { carp "brightness unimplemented",    q{} },
    enable_reverse    => "\e[0m",
    disable_reverse   => "\e[7m",
    self_test         => sub { carp "set test unimplemented",      q{} },
);

# create exportable subroutines when this module is used
our @EXPORT = keys %commands;
{
    no strict 'refs';
    while ( my ( $k, $v ) = each %commands ) {
        if ( ref($v) eq 'CODE' ) {
            *{$k} = $v;
        }
        else {
            *{$k} = sub { $v };
        }
    }
}

# EOF
1;
