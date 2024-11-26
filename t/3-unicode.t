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

done-testing;
