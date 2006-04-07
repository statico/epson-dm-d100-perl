#
# General tricks and helper functions for _you_!
#

# type(speed, text)
# Simulates keypresses. Try speeds of 0.1 or 0.5.
sub type {
    my ( $speed, $text ) = @_;
    print and sleep $speed for split //, $text;
}

# cute_clear()
# Uses type to slowly clear the screen.
sub cute_clear {
    print move_home();
    type( 0.05, q{ } x 40 );
    print move_home();
}

