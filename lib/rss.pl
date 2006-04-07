use Digest::MD5 qw(md5_hex);
use XML::RSSLite;
use LWP::Simple qw(get);
use Storable qw(store retrieve);
do 'tricks.pl';

if ( not defined $CrewDisplay::RSS::URI ) {
    print "Need to define\nCrewDisplay:RSS::URI";
    sleep 5;
}

$CrewDisplay::RSS::REFRESH ||= 8;    # in hours
$CrewDisplay::RSS::COUNT   ||= 10;

my $cachefile = "/tmp/rss-cache-" . md5_hex($CrewDisplay::RSS::URI);
my $rss       = {};

if ( not -e $cachefile
    or [ stat($cachefile) ]->[9] <
    time - ( $CrewDisplay::RSS::REFRESH * 3600 ) )
{
    my $content = get($CrewDisplay::RSS::URI);
    parseRSS( $rss, \$content );
    store( $rss, $cachefile );
}
else {
    $rss = retrieve($cachefile);
}

my @headlines = map { $_->{title} } @{ $rss->{item} };
@headlines = splice @headlines, 0, $CrewDisplay::RSS::COUNT;

# make the title pretty, goddammit
my $title    = $rss->{channel}{title};
my $fillchar = chr(205);
if ( length($title) < 17 ) {
    my $space = 20 - length($title);
    my ( $left, $right ) = ( $fillchar x ( int( $space / 2 ) - 1 ) ) x 2;
    $right = " $right" if $space % 2;
    $title = "$left $title $right";
}
else {
    $title = sprintf '%-20s', substr( $title, 0, 20 );
}

print clear(), move_home(), $title;
print horzscroll_mode();
foreach my $headline (@headlines) {
    print clear_line(), move_leftmost();
    type( 0.1, $headline . '...' );
    sleep 3;
}
print vertscroll_mode();
