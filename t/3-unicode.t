use Test;

use Font::Utils;
use Font::Utils::Misc;

my $debug = 0;
my (@s, $s);

@s = %uni<L-symbols>.words;
$s = hex2string @s;
is $s.comb.head, '!';

@s = %uni<L-chars>.words;
$s = hex2string @s;
is $s.comb.head, '0';

@s = %uni<L-Sup-chars>.words;
$s = hex2string @s;

# test them all
@s = %uni<L-Ext-A-chars>.words;
$s = hex2string @s;

@s = %uni<L-Ext-B-chars>.words;
$s = hex2string @s;

@s = %uni<L-Ext-C-chars>.words;
$s = hex2string @s;

@s = %uni<L-Ext-D-chars>.words;
$s = hex2string @s;

@s = %uni<L-Add-chars>.words;
$s = hex2string @s;

@s = %uni<L-Lig-chars>.words;
$s = hex2string @s;

# glyph '1'

is '1'.ord, 49;
is 1.ord, 49;
is 49.chr, 1;
is 49.chr, '1';
# hex
is '31'.parse-base(16), 49;
is '31'.parse-base(16).chr, '1';
is '31'.parse-base(16).chr, 1;


# glyph 'A'
is 'A'.ord, 65;
is 65.chr, 'A';
# hex
is '41'.parse-base(16), 65;
is '41'.parse-base(16).chr, 'A';

# glyph 'a'
is 'a'.ord, 97;
is 97.chr, 'a';
# hex
is '61'.parse-base(16), 97;
is '61'.parse-base(16).chr, 'a';

done-testing;
