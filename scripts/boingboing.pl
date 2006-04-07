#------------------------------------------------------------------------
# RSS reader for LCD display

# The URI for the RSS feed (REQUIRED!)
#
$CrewDisplay::RSS::URI = 'http://feeds.feedburner.com/boingboing/iBag';

# How many items to cycle through (optional, default 5)
#
#$CrewDisplay::RSS::COUNT = 10;

# How often to refresh the feed in hours (optional, default 8)
#
#$CrewDisplay::RSS::REFRESH = 4;

#------------------------------------------------------------------------
do 'rss.pl';    # located in lib/
