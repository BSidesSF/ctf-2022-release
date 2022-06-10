#!/usr/bin/perl

use strict;
use warnings;

# flag has been hidden in zero-length RLE runs


unless ((defined $ARGV[0]) && (-e $ARGV[0])) {
    die 'Please specify source pcx file as first parameter.', "\n";
}

my $pcx;
open (IN, $ARGV[0]) or die 'Unable to open file: ', $!, "\n";
{
    local $/ = undef;
    $pcx  = <IN>;
}
close IN;

# Loop over RLE image data
my $i = 128;
while ($i < length($pcx) - (768 + 1)) {

    if ((my $r = unpack('C', substr($pcx, $i, 1))) >= 0xC0) {
        if ($r == 0xC0) {
            #warn 'got zero run at offset ', $i, "\n"
            print substr($pcx, $i + 1, 1);
        }

        # This is an RLE pair

        $i += 2;
    } else {

        $i += 1;

    }
}


print "\n";
