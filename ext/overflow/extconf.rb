require 'mkmf'

$CFLAGS << " -Wall"

create_makefile('overflow/overflow')
