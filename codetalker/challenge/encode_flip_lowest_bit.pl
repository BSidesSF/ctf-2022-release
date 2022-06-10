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

    my @lc = split(//, $line);

    my $nl = '';
    for (my $i = 0; $i < scalar(@lc); $i++) {
        $nl .= chr(ord($lc[$i]) ^ 0x01);
    }

    print $nl, "\n";

}
