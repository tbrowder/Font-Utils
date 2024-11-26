use Test;

use Font::Utils;
use Font::Utils::Misc;

my $debug = 0;
my (@s, @c, $s, $c);

@s = %uni<L-symbols>.words;
$s = hex2string @s;
is $s.comb.head, '!';

@c = %uni<L-chars>.words;
$c = hex2string @c;
is $c.comb.head, '0';

@c = %uni<L-Sup-chars>.words;
$c = hex2string @c;

done-testing;
