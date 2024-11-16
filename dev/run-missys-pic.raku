#!/usr/bin/env raku

# Usage: {$*PROGRAM.basename} <width>, <height> [...options...]
# my @margs = "8-15/16", "10-9/16";
# my @fargs = "4-7/8", "7.0";
my $w1 = 8.0 + 15.0/16; #"8-15/16";
my $h1 = 10.0 + 9.0/16; # "10-9/16";

my $c-w = 4.0 + 7.0/8; #'4-7/8';
my $c-h = 7.0;

my $p1 = run "./photo-dimens.raku", $w1, $h1;

#=finish

my $p2 = run ("./photo-dimens.raku", '--', $w1, $h1, :$c-w), :out, :err;
my $o2 = $p2.out.slurp(:close);
my $e2 = $p2.err.slurp(:close);
say $o2;
say $e2;

