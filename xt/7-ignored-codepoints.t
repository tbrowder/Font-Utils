use Test;

use PDF::Font::Loader :load-font;

use Font::Utils;
use Font::Utils::FaceFreeType;
use Font::Utils::Misc;
use Font::Utils::Subs;

my $debug = 0;
my (@s, $s);

# proper subset: $a member of $b but has fewer members
my @set = 1, 2;
is (1) (<) @set, True;

my $file = "/usr/share/fonts/opentype/freefont/FreeSerif.otf";
my $font = load-font :$file;
my $fo   = Font::Utils::FaceFreeType.new: :$font, :font-size(12);

isa-ok $fo, Font::Utils::FaceFreeType;

done-testing;

=finish

my @hex-ignored = [
        # Unicode code points for unwanted glyphs to show in charts
        0x0009, # CHARACTER TABULATION
        0x000A, # LINE FEED (LF)              vertical
        0x000B, # LINE TABULATION             vertical
        0x000C, # FORM FEED (FF)              vertical
        0x000D, # CARRIAGE RETURN (CR)        vertical
        0x00A0, # NO-BREAK SPACE
        0x1680, # OGHAM SPACE MARK
        0x180E, # MONGOLIAN VOWEL SEPARATOR
        0x2000, # EN QUAD <= normalized to 0x2002
        0x2001, # EM QUAD <= normalized to 0x2003
        0x2002, # EN SPACE
        0x2003, # EM SPACE
        0x2004, # THREE-PER-EM SPACE
        0x2005, # FOUR-PER-EM SPACE
        0x2006, # SIX-PER-EM SPACE
        0x2007, # FIGURE SPACE <= unicode considers this non-breaking
        0x2008, # PUNCTUATION SPACE
        0x2009, # THIN SPACE
        0x200A, # HAIR SPACE                  <= PROBLEM
        0x2028, # LINE SEPARATOR              vertical
        0x2029, # PARAGRAPH SEPARATOR         vertical
        0x202F, # NARROW NO-BREAK SPACE
        0x205F, # MEDIUM MATHEMATICAL SPACE
        0x2060, # WORD JOINER
        0x3000, # IDEOGRAPHIC SPACE
];

my @hex = <
    0009
    000A
    000B
    000C
    000D
    00A0
    1680
    180E
    2000
    2001
    2002
    2003
    2004
    2005
    2006
    2007
    2008
    2009
    200A
    2028
    2029
    202F
    205F
    2060
    3000
>;

for @hex-ignored.kv -> $i, $hexin is copy {
    # due to the format, $hexin is now a decimal number,
    # so convert it back to a hex string
    my $dec-input = $hexin;
    my $hexout = dec2hex $dec-input;
    # need to pad
    my $nc = $hexout.chars;
    while $hexout.chars < 4 {
        $hexout = '0' ~ $hexout;
    }

    is $hexout, @hex[$i];
    say "\$dec-input: '$dec-input', hex result: '$hexout'" if $debug;
}

my @misc-bad-hex = <
    0009
    000A
    000B
    000C
>;

for @misc-bad-hex {
    is is-ignored($_), True, "bad hex codepoint";
}

my @misc-good-hex = <
    0042
    0043
    0044
    0045
>;

for @misc-good-hex {
    is is-ignored($_), False, "good hex codepoint";
}

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
