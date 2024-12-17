use Test;

use PDF::API6; # <== required for $page
use PDF::Content;
use PDF::Font::Loader :load-font;
use PDF::Lite;

use Font::Utils;
use Font::Utils::FaceFreeType;
use Font::Utils::Misc;
use Font::Utils::Subs;

my $debug = 1;

is 1, 1;

# wrap-string
my (@w, @s, @c, @g, $s, $c, $cn, $sn, @lines);

@w = %uni<L-chr>.words;
@c = HexStrs2GlyphStrs @w;
$c = HexStr2Char @c.head;
is $c, '0';

my $file = %user-fonts<1><path>;
my $font = load-font :$file;
my $o = Font::Utils::FaceFreeType.new: :$font, :font-size(12);
@lines = $o.wrap-string($c, :width(6.5*72));

@w = %uni<L-Sup>.words;
@c = HexStrs2GlyphStrs @w;
$c = HexStr2Char @c.head;

say "\$c: '$c'";
$sn = $c.chars;

for @c {
    my $g = HexStr2Char($_);
    @g.push: $g;
}

$s = @g.join(" ");
@lines = $o.wrap-string($s, :width(6.5*72));

done-testing;
