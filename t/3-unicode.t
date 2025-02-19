use Test;

use Font::Utils;
use Font::Utils::Misc;
use Font::Utils::Subs;

my $debug = 0;
my (@s, $s, @w);

is 1, 1;

@s = %uni<L-sym>.words;
if $debug {
    say "DEBUG: \@s = {@s.gist}";
}
@w = HexStrs2GlyphStrs @s;
if $debug {
    say "DEBUG: \@w = {@w.gist}";
}
$s = HexStr2Char @w.head;
is $s.comb.head, '!';

@s = %uni<L-chr>.words;
@w = HexStrs2GlyphStrs @s;
$s = HexStr2Char @w.head;
is $s.comb.head, '0';

# test them all
@s = %uni<L-Sup>.words;
@w = HexStrs2GlyphStrs @s;

@s = %uni<L-Ext-A>.words;
@w = HexStrs2GlyphStrs @s;

@s = %uni<L-Ext-B>.words;
@w = HexStrs2GlyphStrs @s;

@s = %uni<L-Ext-C>.words;
@w = HexStrs2GlyphStrs @s;

@s = %uni<L-Ext-D>.words;
@w = HexStrs2GlyphStrs @s;

@s = %uni<L-Ext-E>.words;
@w = HexStrs2GlyphStrs @s;

@s = %uni<L-Ext-F>.words;
@w = HexStrs2GlyphStrs @s;

@s = %uni<L-Additional>.words;
@w = HexStrs2GlyphStrs @s;

@s = %uni<L-Ligatures>.words;
@w = HexStrs2GlyphStrs @s;

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
# Create some mixed steings of codepoints and text
my $un = "latin small letter c with cedilla".uc;

my $cx = "\xe7"; # cedilla
is $cx.uniname, $un, "test unicode hex entry";

my $cd = "\c[231]"; # cedilla
is $cd.uniname, $un, "test unicode decimal entry";

my $co = "\o347"; # cedilla
is $co.uniname, $un, "test unicode octal entry";

is "231".parse-base(10).uniname, $un;
is "e7".parse-base(16).uniname, $un;
is "347".parse-base(8).uniname, $un;

is "231".parse-base(10), 231;
is "e7".parse-base(16), 231;
is "347".parse-base(8), 231;

is "231".parse-base(10).base(16), "e7".uc;
is "e7".parse-base(16).base(8), 347;
is "e7".parse-base(16).base(8), "347";

#==========================
done-testing;
