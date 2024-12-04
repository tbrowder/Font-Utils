use Test;

use Font::Utils;
use Font::Utils::Misc;

my $debug = 0;

is 1, 1;

# wrap-string
my (@s, @c, $s, $c, $cn, $sn, @lines);

@c = %uni<L-chr>.words;
$c = hex2string @c;
say "\$c: '$c'";
is $c.comb.head, '0';
$cn = $c.chars;

my $file = %user-fonts<1><path>;
my $o = FreeTypeFace.new: :$file, :font-size(12);
@lines = $o.wrap-string($c, :width(6.5*72));

@s = %uni<L-Sup>.words;
$s = hex2string @s;
say "\$s: '$s'";
$sn = $s.chars;
@lines = $o.wrap-string($s, :width(6.5*72));

done-testing;
