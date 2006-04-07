#
# Lets people know that NUrdRadio is recording!
#
do 'tricks.pl';

print hide_cursor(), clear(), move_home();

print "     NUrdRadio\n";
print horzscroll_mode();
type( 0.05, "http://acm.ccs.neu.edu/podcast/" );
print vertscroll_mode();
sleep 1;

print clear(), move_home(), set_blinkinterval(4);
print "     RECORDING\n";
print "    IN PROGRESS";
sleep 3;
print set_blinkinterval(0);

