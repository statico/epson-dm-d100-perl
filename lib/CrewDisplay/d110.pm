package CrewDisplay::d110;
use base 'Exporter';
use IO::File;
use Carp;

# options, currently not configurable
my %o = ( device => '/dev/ttyS0', );

# create a filehandle to our device
my $fh = IO::File->new( $o{device}, 'w' ) or die $!;
$fh->autoflush(1);

# a method that returns our filehandle
sub fh { $fh }

# now, terminal sequences for d110
my %commands = (
    move_left      => "\x08",
    move_right     => "\x09",
    move_down      => "\x0a",
    move_up        => "\x1f\x0a",
    move_home      => "\x0b",
    move_leftmost  => "\x0d",
    move_rightmost => "\x1f\x0d",
    move_bottom    => "\x1f42",
    move_to        => sub {
        my ( $x, $y ) = @_;
        croak "column out of range" if $x < 1 or $x > 20;
        croak "row out of range"    if $y < 1 or $y > 2;
        "\x1f\x24" . chr($x) . chr($y);
    },
    clear       => "\x0c",
    clear_line  => "\x18",
    init        => "\x1b\x40",
    set_charset => sub {
        my ($n) = @_;
        croak "charset number out of range" if $n < 0 or $n > 255;
        "\x1b\x25" . chr($n);
    },
    overwrite_mode    => "\x1f\x01",
    vertscroll_mode   => "\x1f\x02",
    horzscroll_mode   => "\x1f\x03",
    hide_cursor       => "\x1f\x43\x00",
    show_cursor       => "\x1f\x43\x01",
    display_off       => "\x1f\x45\xff",
    display_on        => "\x1f\x45\x00",
    set_blinkinterval => sub {
        my ($n) = @_;
        croak "interval out of range" if $n < 0 or $n > 255;
        "\x1f\x45" . chr($n);
    },
    set_and_show_time => sub {
        my ( $h, $m ) = @_;
        croak "hours out of range"   if $h < 0 or $h > 23;
        croak "minutes out of range" if $m < 0 or $m > 59;
        "\x1f\x54" . chr($h) . chr($m);
    },
    set_time       => "\x1f\x55",
    set_brightness => sub {
        my ($n) = @_;
        croak "brightness out of range" if $n < 1 and $n > 4;
        "\x1f\x58" . chr($n);
    },
    enable_reverse  => "\x1f\x72\x01",
    disable_reverse => "\x1f\x72\x00",
    self_test       => "\x1f\x40",
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
