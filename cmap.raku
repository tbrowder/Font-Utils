#!/usr/bin/env raku

use Font::FreeType;
use Font::FreeType::Face;

my $file  = "/usr/share/fonts/opentype/freefont/FreeSerif.otf";

my $fo   = Font::FreeType.new;
my $face = $fo.face: $file;

my enum Control-Chars (
        :Control<Cc>,
        :Format<Cf>,
        :Surrogate<Cs>,
        :Private<Co>,
        :Unassigned<Cn>
 );

# using cmap() [FreeType v0.5.12+]
my %control-chars = ();
for $face.cmap {
    my $glyph-index = .key;
    # David's $char is the decimal code point
    my $char        = .value;
    my $prop        = $char.uniprop;
    # my code
    my $glyph       = $char.chr;
    my $dec         = $char;
    my $hex         = $dec.base: 16;
    my $name        = $char.uniname;
    say qq:to/HERE/;
    glyph-index: $glyph-index
           char: $char
          glyph: $glyph
           name: $name
            dec: $dec
            hex: $hex
           prop: $prop
    HERE
}

done-testing;

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
