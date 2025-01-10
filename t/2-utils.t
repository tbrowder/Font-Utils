use Test;

use Font::Utils;
use Font::Utils::Subs;
use Font::Utils::Misc;

my $debug = 0;
my @tmpfils; # files to clean before and after
BEGIN {
@tmpfils = <
    $goodasc
    $goodasc2
    $goodasc3

    $goodps
    $goodps2
    $goodps3

    $goodpdf
    $goodpd2f
    $goodpd3f
    >;
    for @tmpfils {
        unlink $_ if $_.IO.e;
    }
} # BEGIN

my ($s1, $s2, $c1, $c2, @gchars, @words);

# create some known good files
my $permasc = "xt/data/sample.asc".IO;
my $goodasc = "good.asc";
copy $permasc, $goodasc;

my $goodps = "good.ps";
shell "a2ps -o '$goodps' '$goodasc'";

shell "ps2pdf $goodps";
my $goodpdf = "good.pdf".IO;

# test turning a text file into a PostScript file (.ps)
#   first the default
my $goodasc2 = "good2.asc";
copy $goodasc, $goodasc2;
lives-ok {
        asc2ps $goodasc2, :force;
}, "test 1, running asc2ps on file '$goodasc'";
# expected output: "good2.ps";

#   then try to overwrite an existing file
my $force = 1;
my $goodasc3 = "good3.asc";
copy $goodasc, $goodasc3;

lives-ok {
    if $goodasc3.defined {
        asc2ps $goodasc3, :force;
    }
    else {
        asc2ps $goodasc3;
    }
}, "test 2, running asc2ps on file '$goodasc3'";

#   then a non-file
my $nofile = "some-string";
my $ps;
dies-ok {
     $ps = asc2ps $nofile;
}, "test 3, running asc2ps on file '$nofile'";

# test ps2pdf
$ps = $nofile;
my $pdf;
dies-ok {
     $pdf = ps2pdf $nofile;
}, "test 4, running ps2pdf '$nofile'";

$pdf = $goodpdf;
lives-ok {
    if $pdf.defined {
        $pdf = ps2pdf $goodps, :force;
    }
    else {
        $pdf = ps2pdf $goodps;
    }
}, "test 5, running ps2pdf '$ps', '$pdf'";

say "DEBUG: early exit"; exit;

=begin comment
for 1..2000 {
    my $c = $_.chr;
    next if $c.uniprop("M");
    next if $c.uniprop("Z");
    next if $c.uniprop("C");
    say $c;
}
exit;
=end comment

=begin comment
#=== DO NOT USE DECIMAL STRING INPUTS FOR NOW
# use decimals first
#sym ranges in decimal: 33 47 58 64 91 96 123 126
$s1 = "33-47 58-64 91-96 123-126";
@chars $s1 = dec2string @symbols;
# char ranges in decimal: 48 57 65 90 97 122
@chars = "48-57 65-90 97-122";
$c1 = dec2string @chars;
say "symbols: '$s1'" if $debug;
say "chars:   '$c1'" if $debug;
=end comment

# then use hex
@words = "21-2f 3a-40 5b-60 7b-7e".words;

=begin comment
my @s = "21 2f 3a 40 5b 60 7b 7e";
my $sr = "";
for @s.kv -> $i, $v {
    my $d = parse-base "$v", 16;
    $sr ~= "$d ";
}
say "sym ranges in decimal: $sr";
=end comment

@gchars = HexStrs2GlyphStrs @words;
say @gchars;
@words = "30-39 41-5a 61-7a".words;
@gchars = HexStrs2GlyphStrs @words;
say @gchars;

done-testing;

=finish

=begin comment
my @c = "30 39 41 5a 61 7a";
my $cr = "";
for @c.kv -> $i, $v {
    my $d = parse-base "$v", 16;
    $cr ~= "$d ";
}
say "char ranges in decimal: $cr";
=end comment

$c2 = hex2string @chars;
say "symbols: '$s2'" if $debug;
say "chars:   '$c2'" if $debug;

is $s1, $s2, "symbols are the same";
is $c1, $c2, "chars are the same";

done-testing;
