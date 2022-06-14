#!/usr/bin/perl

use strict;
use warnings;

srand(time());

my $flag = 'CTF{zenos_run_length_encoding}';
my $fi = 0;

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

my $sp = 0;
my $rle = 0;

# Handle header
my $out = substr($pcx, 0, 128);

# Loop over RLE image data
my $i = 128;
while ($i < length($pcx) - (768 + 1)) {

    if ((my $r = unpack('C', substr($pcx, $i, 1))) >= 0xC0) {
        if ($r == 0xC0) {
            warn 'got zero run at offset ', $i, "\n"
        }
        $rle++;
        # This is an RLE pair
        $out .= substr($pcx, $i, 2);
        $i += 2;
    } else {
        $sp++;
        $out .= substr($pcx, $i, 1);
        $i += 1;

        if (int(rand(100)) == 0) {
            if ($fi < length($flag)) {
                warn 'hiding flag byte at ', $i, "\n";
                $out .= pack('H*', 'C0') . substr($flag, $fi, 1);
                $fi++;
            }
        }
    }
}

# Handle pallet
$out .= substr($pcx, $i);

print $out;

warn sprintf('Got %d RLE pairs and %d single pixels', $rle, $sp), "\n";
