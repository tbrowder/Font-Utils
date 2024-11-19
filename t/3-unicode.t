use Test;

use Font::Utils;
use Font::Utils::Misc;

my $debug = 0;
my (@s, @c, $s, $c);

@s = @(%uni<L-symbols>);
$s = hex2string @s;
is $s.comb.head, '!';

@c = @(%uni<L-chars>);
$c = hex2string @c;
is $c.comb.head, '0';

done-testing;
