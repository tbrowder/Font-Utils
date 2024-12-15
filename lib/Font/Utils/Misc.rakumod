unit module Font::Utils::Misc;

#=========================================================
# important subset defs (see them tested in t/9-hex-types.t)
#=========================================================
# A single token: no whitespace allowed.  Ultimately, all HexStrRange
# objects will be converted to a list of HexStr objects.
subset HexStr of Str is export where { $_ ~~
    /^
        <[0..9a..fA..F]>+
    $/
}
# A single token: no whitespace allowed.
subset HexStrRange of Str is export where { $_ ~~
    /^
        <[0..9a..fA..F]>+ '-' <[0..9a..fA..F]>+
    $/
}
# One or more tokens in a string, demarked by whitespace.  The string
# will be converted to individual HexStrRange and HexStr tokens with
# the .words method.  Then the entire list will be converted to HexStr
# tokens.
subset HexStrRangeWords of Str is export where { $_ ~~
    /^
        \h*  # optional leading whitespace
             # interleaving HexStrRange and HexStr types
             # first instance is required
             [ [<[0..9a..fA..F]>+ '-' <[0..9a..fA..F]>+] | [<[0..9a..fA..F]>+] ]

             # following instances are optional
             [
               \h+ [ [<[0..9a..fA..F]>+ '-' <[0..9a..fA..F]>+] | [<[0..9a..fA..F]>+] ]
             ]?

        \h*  # optional trailing whitespace
    $/
}
#=========================================================


# constants for a glyph box per the Unicode code point charts
# at <https://unicode.org>

#=begin comment
# dimensions of a Unicode glyph box:
#   width:  1.1 cm # width is good
#   height: 1.4 cm
# convert to points: cm / cm per in * 72
constant $glyph-box-width  is export = 1.1 / 2.54 * 72; #cm2ps(1.1), # width of the complete box
constant $glyph-box-height is export = 1.4 / 2.54 * 72; #cm2ps(1.4), # height of the complete box
#   glyph baseline 0.5 cm from cell bottom
#   hex code baseline 0.1 cm from cell bottom
constant $glyph-box-baselineY  is export = 2.54 / 0.5 * 72; #cm2ps(0.5);
constant $glyph-box-baselineY2 is export = 2.54 / 0.1 * 72; #cm2ps(0.1);
#=end comment

# List keys and titles for Unicode Latin glyphs
constant %uni-titles is export = %(
    a => {
        title => "Basic Latin (ASCII) (symbols)",
        key   => "L-sym",
    },
    b => {
        title => "Basic Latin (ASCII) (alphanumerics)",
        key   => "L-chr";
    },
    c => {
        title => "Latin-1 Supplement",
        key   => "L-Sup";
    },
    d => {
        title => "Latin Extended A",
        key   => "L-Ext-A";
    },
    e => {
        title => "Latin Extended B",
        key   => "L-Ext-B";
    },
    f => {
        title => "Latin Extended C",
        key   => "L-Ext-C";
    },
    g => {
        title => "Latin Extended D",
        key   => "L-Ext-D";
    },
    h => {
        title => "Latin Extended E",
        key   => "L-Ext-E";
    },
    i => {
        title => "Latin Extended F",
        key   => "L-Ext-F";
    },
    j => {
        title => "Latin Extended G",
        key   => "L-Ext-G";
    },
    k => {
        title => "Latin Additional",
        key   => "L-Additional";
    },
    l => {
        title => "Latin Ligatures",
        key   => "L-Ligatures";
    },
);

# Need to export by a hash or class
constant %uni is export = %(

# Basic Latin (ASCII)
L-sym => "21-2f 3a-40 5b-60 7b-7e",
L-chr => "30-39 41-5a 61-7a",

# Latin-1 Supplement
L-Sup => "a1-ac ae-bf c0-ff",

# Latin Extended A
L-Ext-A => "100-17f",

# Latin Extended B
L-Ext-B => "180-24f",

# Latin Extended C
L-Ext-C => "2c60-2c7f",

# Latin Extended D
L-Ext-D => "a720-a7cd a7d0 a7d1 a7d3 a7d5-a7dc a7f2-a7ff",

# Latin Extended E
L-Ext-E => "ab30-ab6b",

# Latin Extended F
# TODO complete
L-Ext-F => "10780-10785 10787-107ba",

# Latin Extended G
# TODO complete
L-Ext-G => "1df00-1df1e 1df25-1df2a",

# Latin Additional
L-Additional => "1e00-1eff",

# Latin Ligatures (others in this group excluded)
L-Ligatures => "fb00-fb06",

);
