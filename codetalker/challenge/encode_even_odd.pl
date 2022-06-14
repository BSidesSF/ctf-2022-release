#!/usr/bin/perl

use strict;
use warnings;

while (<STDIN>) {
    my $line = $_;

    chomp($line);

    if ($line eq '') {
        print "\n";
        next;
    }

    my $el = '';
    my $ol = '';

    my @lc = split(//, $line);

    for (my $i = 0; $i < scalar(@lc); $i++) {
        if ($i % 2 == 0) {
            # even
            $el .= $lc[$i];
        } else {
            $ol .= $lc[$i];
        }
    }

    print $el, "\n";
    print $ol, "\n";
}
