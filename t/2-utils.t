use Test;

use Font::Utils;

my ($s, @symbols, @chars);

# use decimals first
@symbols = <33-47 58-64 91-96 123-126>;
$s = dec2string @symbols;
say "symbols: '$s'";

@chars = <48-57 65-90 97-122>;
$s = dec2string @chars;
say "chars: '$s'";

# then use hex
@symbols = <21-2f 3a-40 58-60 7b-7e>;
$s = hex2string @symbols;
say "symbols: '$s'";

@chars = <30-39 41-5a 61-7a>;
$s = hex2string @chars;
say "chars: '$s'";

done-testing;
