#!/usr/bin/env raku

use Font::FreeType;
use Font::FreeType::Face;

#my $file  = "/usr/share/fonts/opentype/freefont/FreeSerif.otf";
my $file  = "/usr/share/local/fonts/noto/NotoSerif-Regular.ttf";

my $fo   = Font::FreeType.new;
my $face = $fo.face: $file;

my enum Control-Chars (
        :Control<Cc>,
        :Format<Cf>,
        :Surrogate<Cs>,
        :Private<Co>,
        :Unassigned<Cn>
 );

# From my study of code-point properties,
# these should be printable chars:
my enum PrintChars (
    :P1<Lu>, :P2<Ll>, :P3<Lt>,
    :P4<Nd>, :P5<Nl>, :P6<No>,
    :P7<Pc>, :P8<Pd>, :P9<Ps>, :Pa<Pe>, :Pb<Pi>, :Pc<Pf>, :Pd<Po>,
    :Pe<Sm>, :Pf<Sc>,
);

=begin comment
# David uses the code this way:
    %control-chars{$prop}.push($char.uniname)
        if Control-Chars($char.uniprop);
# rearranging that:
    if Control-Chars($char.uniprop) {
        %control-chars{$prop}.push($char.uniname)
    }
# I want only printable glyphs:
    if not PrintChars($char.uniprop) {
        next;
    }

=end comment


# using cmap() [FreeType v0.5.12+]
my %control-chars = ();
for $face.cmap {
    my $glyph-index = .key;
    # David's ($char = .value) yields the decimal code point
    my $char        = .value;
    my $prop        = $char.uniprop;
    # my added code
    my $glyph       = $char.chr;
    my $dec         = $char;
    my $hex         = $dec.base: 16;
    my $name        = $char.uniname;

    if not PrintChars($char.uniprop) {
        note "$hex";
        next;
    }


    if $prop ~~ /^ :i [L|N|P|S] / {
        note "$hex";
    }

    =begin comment
    say qq:to/HERE/;
    glyph-index: $glyph-index
           char: $char
          glyph: $glyph
           name: $name
            dec: $dec
            hex: $hex
           prop: $prop
    HERE
    =end comment
}

#done-testing;

=finish

    next;
    #say "key ", .key;
    #say "  .value ", .value;
    #say "  .value.chr ", (.value.chr);
#exit;
    #my $char        = .value.chr;
    #say $prop;
    %control-chars{$prop}.push($char.uniname)
        if Control-Chars($char.uniprop);
}
#dd %control-chars if 0;
for %control-chars.keys.sort -> $k {
    say "key: |$k|";
    my @v = @(%control-chars{$k});
    for @v -> $v {
        my $u = $v.uniparse;
        my $d = $u.ord;
        my $x = $d.base(16);
        say "  hex: $x";
    }
    #say %control-chars{$k};
}

=finish
use Font::FreeType;
use Font::FreeType::Face;

my Font::FreeType $freetype .= new;
my Font::FreeType::Face $face = $freetype.face('t/fonts/Vera.ttf');

$face.set-char-size(24, 24, 100, 100);
for $face.glyph-images('ABC') {
    my $outline = .outline;
    my $bitmap = .bitmap;
    # ...
}
Description
