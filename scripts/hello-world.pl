print show_cursor(), move_home(), clear();

print $_ and sleep 0.2 for 1 .. 14;
print "\n";

print hide_cursor();

for ( 1 .. 6 ) {
    print "hello, world!";
    sleep 0.2;
    print clear_line(), move_leftmost();
    sleep 0.2;
}
