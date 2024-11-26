use Test;

use Font::Utils;
use Font::Utils::Misc;

my $debug = 0;

is 1, 1;

# wrap-atring
my (@s, @c, $s, $c, $cn, $sn, @lines);

@c = %uni<L-chars>.words;
$c = hex2string @c;
say "\$c: '$c'";
is $c.comb.head, '0';
$cn = $c.chars;

my $file = %user-fonts<1><path>;
my $o = FreeTypeFace.new: :$file;
@lines = $o.wrap-string($c, :font-size(12), :width(6.5*72));

@s = %uni<L-Sup-chars>.words;
$s = hex2string @s;
say "\$s: '$s'";
$sn = $s.chars;
@lines = $o.wrap-string($s, :font-size(12), :width(6.5*72));

done-testing;
