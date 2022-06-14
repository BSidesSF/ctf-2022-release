#!/usr/bin/perl

use strict;
use warnings;

my $DIAL = 'ABCDEFGHILMNOPRSTUWY'; # Skips J, K, Q, V, X, Z

my $min = 3; # min distance between letters

my @d = split(//, $DIAL);


# CTF{<flag>}
my $FLAG = 'AROUNDWEGO';
my @f = split(//, $FLAG);
my $fp = 0;

my @mlist = ();


my $dp = 15; # Don't start at A
my $dir = 1; # Turning CCW
my $dist = 0;
my $done = 0;
my $dlen = scalar(@d);

while ($done != 1) {
    warn 'At ', $d[$dp], ' looking for ', $f[$fp], "\n";
    if (($dist < $min) || ($f[$fp] ne $d[$dp])) {
        push @mlist, 'click.samples';

        $dp = (($dp + $dir) + $dlen) % $dlen;

        $dist++;

        next;
    } else {
        push @mlist, 'rev.samples';

        warn 'got ', $f[$fp], ' at pos ', $d[$dp], "\n";

        $dist = 0;
        $dir *= -1;
        $fp++;

        if ($fp >= scalar(@f)){
            $done = 1;
            last;
        }

        $dp = (($dp + $dir) + $dlen) % $dlen;
    }
}

print join(' ', @mlist), "\n";
