use Test;

use Font::Utils;
use Font::Utils::Misc;

my $debug = 0;
my (@s, $s);

@s = %uni<L-sym>.words;
$s = hex2string @s;
is $s.comb.head, '!';

@s = %uni<L-chr>.words;
$s = hex2string @s;
is $s.comb.head, '0';

@s = %uni<L-Sup>.words;
$s = hex2string @s;

# test them all
@s = %uni<L-Ext-A>.words;
$s = hex2string @s;

@s = %uni<L-Ext-B>.words;
$s = hex2string @s;

@s = %uni<L-Ext-C>.words;
$s = hex2string @s;

@s = %uni<L-Ext-D>.words;
$s = hex2string @s;

@s = %uni<L-Additional>.words;
$s = hex2string @s;

@s = %uni<L-Ligatures>.words;
$s = hex2string @s;

#==========================
# glyph '1'

# dec 49
is '1'.ord, 49;
is 1.ord, 49;
is 49.chr, 1;
is 49.chr, '1';

# hex 31
is 31, 49.base: 16;
is '31'.parse-base(16), 49;
is '31'.parse-base(16).chr, '1';
is '31'.parse-base(16).chr, 1;

#==========================
# glyph 'A'

# dec 65
is 'A'.ord, 65;
is 65.chr, 'A';

# hex 41
is 41, 65.base: 16;
is '41'.parse-base(16), 65;
is '41'.parse-base(16).chr, 'A';

#==========================
# glyph 'a'

# dec 97
is 'a'.ord, 97;
is 97.chr, 'a';

# hex 61
is 61, 97.base: 16;
is '61'.parse-base(16), 97;
is '61'.parse-base(16).chr, 'a';

#==========================
#==========================
done-testing;
