#!/usr/bin/perl

use strict;
use warnings;

srand(time());

my $W = 79;
my $H = 24;


unless ((defined $ARGV[0]) && (-e $ARGV[0])) {
    die 'Please specify source file as first parameter.', "\n";
}


my $text = '';
open (IN, $ARGV[0]) or die 'Unable to open file: ', $!, "\n";
{
    while (<IN>) {
        chomp;

        $text .= $_;
    }
}
close IN;

my @grid;
my @mlist;

my $good = 0;
while ($good == 0) {

    @grid = ();
    for (my $i = 0; $i < $W; $i++) {
        my @col = (('') x $H);

        push @grid, [@col];
    }

    my $CX = int(rand($W)) % $W;
    my $CY = int(rand($H)) % $H;
    my $O_OFF = 0;

    @mlist = ();
    my @dirs = ('U', 'D', 'L', 'R');
    my $finished = 1;
    foreach my $l (split(//, $text)) {

        my $placed = 0;

        my $doff = $O_OFF;
        if (int(rand(3)) == 0) {
            $doff = int(rand(4)) % 4;
        }

        foreach (my $d = 0; $d < 4; $d++) {
            my $dir = $dirs[($d + $doff) % 4];

            my ($NX, $NY) = move($dir, $CX, $CY);

            if ($grid[$NX][$NY] eq '') {
                $grid[$NX][$NY] = $l;
                $placed = 1;

                $O_OFF = $doff;

                push @mlist, $dir;

                ($CX, $CY) = ($NX, $NY);

                last;
            }
        }

        unless ($placed == 1) {
            $finished = 0;
            last;
        }
    }

    if ($finished == 1) {
        $good = 1;
    }
}

print 'Moves:';
for (my $i = 0; $i < scalar(@mlist); $i++) {
    if ($i % $W == 0) {
        print "\n";
    }

    print $mlist[$i];
}
print "\n\n";

print 'Grid:', "\n";
foreach (my $y = 0; $y < $H; $y++) {
    foreach (my $x = 0; $x < $W; $x++) {
        if ($grid[$x][$y] eq '') {
            print ' ';
        } else {
            print $grid[$x][$y];
        }
    }
    print "\n";
}


sub move {
    my $d = shift;
    my $x = shift;
    my $y = shift;

    my $xd = 0;
    my $yd = 0;

    if ($d eq 'L') {
        $xd = -1;
    }
    if ($d eq 'R') {
        $xd = 1;
    }
    if ($d eq 'U') {
        $yd = -1;
    }
    if ($d eq 'D') {
        $yd = 1;
    }

    return (($x + $xd + $W) % $W, ($y + $yd + $H) % $H);
}
