#!/usr/bin/perl

use strict;
use warnings;

use MIME::Base64;

use bignum;

my $S = 128; # Per-glyph size in pixels (they must be square)
my $OVR = 8; # Number of pixels to overlap between glyphs
my $GDIR = 'glyphs';

my $SNAME = 'symmetric\'s truly horrible perl hack to approximate a webserver';

my $HTML_START = << 'ENDHTMLSTART';
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <title>septoglyph</title>

    <style type="text/css">
      div {
          padding-top: 16px;
          padding-right: 16px;
          padding-bottom: 16px;
          padding-left: 16px;
      }
      .container {
          align:left;
      }
      .word {
          float:left;
          text-align:center;
      }
    </style>

  </head>
  <body>
    <div class="container">
ENDHTMLSTART
;

my $HTML_END = << 'ENDHTMLEND';
    </div>
  </body>
</html>
ENDHTMLEND
;


my @words = ();


alarm 5;

my $lc = 0;
my $got_get = 0;
my $error = 0;
my $hc = 0;
while (<STDIN>) {
    $lc++;

    my $line = $_;

    if ($lc == 1) {
        #warn 'line 1', "\n";
        #warn $line, "\n";
        if ($line =~ m/^GET\s([a-zA-Z\/]{1,10000})\sHTTP\/1\.[01]\s+$/) {
            #warn 'got get', "\n";
            my @l = split(/\//, lc($1));
            foreach my $w (@l) {
                next if ($w eq '');
                $error = 1 if (length($w) > 30);
                #warn 'adding word ', $w, "\n";
                push @words, $w;
            }

            $got_get = 1;
        }
    } else {
        if ($line =~ m/^User-Agent: .*GoogleHC.*$/) {
          $hc = 1;
        }
        last if ($line =~ m/^[\r\n]+$/);
    }
}

if ($hc == 1) {
  print "HTTP/1.0 200 OK\r\n";
  print "\r\n";
  exit 0;
}

$error = 1 unless ($got_get == 1);
$error = 1 if (scalar(@words) > 100);

if ($error == 1) {
    print 'HTTP/1.0 303 See Other', "\r\n";
    print "Server: ", $SNAME, "\r\n";
    print 'Location: /error/abuse/will/not/be/tolerated', "\r\n";
    print "\r\n";

    exit 0;
}


if (scalar(@words) == 0) {
    print 'HTTP/1.0 303 See Other', "\r\n";
    print "Server: ", $SNAME, "\r\n";
    print 'Location: /this/is/an/example', "\r\n";
    print "\r\n";

    exit 0;
}


#warn 'got words to encode: ', join(' ', @words), "\n";

my @imgs = ();
foreach my $w (@words) {
    my $n = word_to_number($w);

    my @digits = num_to_base_49($n);

    #warn 'word "', $w, '" -> ', $n, ' -> (', join(', ', @digits), ')', "\n";

    my $img = num_to_img($n);

    push @imgs, $img;
}

# if (scalar @imgs > 0) {
#     print "HTTP/1.0 200 OK\r\n";
#     print "Server: symmetric's horrible perl hack\r\n";
#     print sprintf("Content Length: %d\r\n", length($imgs[0]));
#     print "Content Type: image/png\r\n";
#     print "\r\n";
#     print $imgs[0];
# }


my $html = $HTML_START;

for (my $i = 0; $i < scalar(@imgs); $i++) {
    $html .= "\n" . img_to_html($imgs[$i], $words[$i]) . "\n";
}

$html .= $HTML_END;

print 'HTTP/1.0 200 OK', "\r\n";
print 'Server: ', $SNAME, "\r\n";
print sprintf('Content-Length: %d', length($html)), "\r\n";
print 'Content-Type: text/html', "\r\n";
print "\r\n";
print $html;

sub word_to_number {
    my $w = shift;

    return -1 unless ($w =~ m/^[a-z]{1,30}$/);

    my @lets = split(//, $w);

    my $n = 0;

    foreach my $l (@lets) {
        my $c = (ord($l) - ord('a')) + 1;
        $n = ($n * 27) + $c;
    }

    #print 'word ', $w, ' -> ', $n, "\n";

    return $n;
}


sub num_to_base_49 {
    my $n = shift;

    return -1 if ($n < 0);

    my @digits = ();
    my $t = $n;
    do {
        my $d = $t % 49;

        unshift(@digits, $d);

        $t = ($t - $d) / 49;

    } while ($t > 0);

    return @digits;
}


sub num_to_img {
    my $n = shift;

    my @digits = num_to_base_49($n);

    my $len = scalar @digits;

    my $cmd = sprintf('convert -size %dx%d xc:white', $S, (($S * $len) - ($OVR * ($len - 1))));

    for (my $i = 0; $i < $len; $i++) {
        my $d = $digits[$i];

        my $low = $d % 7; # The lower digit
        my $high = ($d - $low) / 7; # The upper digit (gets rotated 90)

        my $Y = ($S - $OVR) * $i; # Where on the canvas this gets placed vertically

        my $glyph = sprintf('\\( %s/bars.png -repage +0+%d \\) \\( %s/%d.png -rotate -90 -repage +0+%d \\) \\( %s/%d.png -repage +0+%d \\)', $GDIR, $Y, $GDIR, $high, $Y, $GDIR, $low, $Y);

        $cmd = $cmd . ' ' . $glyph;
    }

    $cmd = $cmd . ' -layers flatten png:-';

    my $ret = `$cmd`;

    return $ret;
}


sub img_to_html {
    my $img = shift;
    my $word = shift;

    my $html = sprintf('<div class="word">%s<p><img src="data:image/png;base64,%s" alt="%s" /></p></div>', $word, "\n" . encode_base64($img), $word);

    return $html;
}
