use Test;

use Font::Utils;
use Font::Utils::Subs;
use Font::Utils::Misc;

my $debug = 0;

my (@chars, @gchars, @words);

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

# use hex (for using decimal, see standby tests following =finish)
@words = "21-2f 3a-40 5b-60 7b-7e".words;

# using <> ensures values are defined as strings
my @s = <21 2f 3a 40 5b 60 7b 7e>;
my $sr = "";
for @s.kv -> $i, $v {
    my $d = parse-base $v, 16;
    $sr ~= "$d ";
}
say "sym ranges in decimal: $sr";

@gchars = HexStrs2GlyphStrs @words;
say @gchars;
@words = "30-39 41-5a 61-7a".words;
@gchars = HexStrs2GlyphStrs @words;
say @gchars;

done-testing;

=finish

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
