#
# a cute Crew general animation
#
do 'tricks.pl';
print hide_cursor();

print clear(), move_home();
type( 0.1, "  Welcome to Crew!\n 314 West Village H" );
sleep 3;
print clear_line(), move_leftmost();
type( 0.1, "  crew.ccs.neu.edu" );
sleep 3;
cute_clear();

type( 0.1, "Meetings every\nThursday at 6pm" );
sleep 3;
print clear(), move_home(), "\n    (in this room)";
sleep 2;
print clear(), move_home(), "(yes, the one you're looking at)";
sleep 3;
cute_clear();

