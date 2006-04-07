#
# Pretends to log into tigana and erase all of CCS
#
do 'tricks.pl';

print show_cursor(), clear(), move_home();

type( 0.1, "\$ ssh root\@tigana\n" );
sleep 3;
print "Password: ";
sleep 2;
type( 0.1, "*******" );
sleep 0.3;
print clear(), move_home();
sleep 1;
print "tig# ";
sleep 0.5;
type( 0.4, "rm -rf /" );
sleep 1;
print "\n/bin/sh not found";
sleep 4;
