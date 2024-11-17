use Test;

use Font::Utils;

my ($s, $c, @symbols, @chars);

# use decimals first
#sym ranges in decimal: 33 47 58 64 91 96 123 126 
@symbols = <33-47 58-64 91-96 123-126>;
$s = dec2string @symbols;
# char ranges in decimal: 48 57 65 90 97 122 
@chars = <48-57 65-90 97-122>;
$c = dec2string @chars;
say "symbols: '$s'";
say "chars:   '$c'";

# then use hex
@symbols = <21-2f 3a-40 5b-60 7b-7e>;

=begin comment
my @s = <21 2f 3a 40 5b 60 7b 7e>;
my $sr = "";
for @s.kv -> $i, $v {
    my $d = parse-base "$v", 16;
    $sr ~= "$d ";
}
say "sym ranges in decimal: $sr";
=end comment

$s = hex2string @symbols;
@chars = <30-39 41-5a 61-7a>;

=begin comment
my @c = <30 39 41 5a 61 7a>;
my $cr = "";
for @c.kv -> $i, $v {
    my $d = parse-base "$v", 16;
    $cr ~= "$d ";
}
say "char ranges in decimal: $cr";
=end comment

$c = hex2string @chars;
say "symbols: '$s'";
say "chars:   '$c'";

done-testing;
