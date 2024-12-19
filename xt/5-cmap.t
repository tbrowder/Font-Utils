use Test;

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
    say ".cmap: {$_.gist}";
    my $glyph-index = .key;
    my $char        = .value.chr;
    my $width = 0;
    $face.for-glyphs: $char, -> $g {
        $width = $g.width;
    }
    my $prop        = $char.uniprop;
    my $name        = $char.uniname;
    my $ord         = $char.ord;
    my $hex         = $ord.base(16);
    say "glyph index: $glyph-index";
    say "       char: $char";
    say "    decimal: $ord";
    say "        hex: $hex";
    say "      width: $width";
    say "    uniname: $name";
    say "    uniprop: $prop";
    if $width == 0 {
        note "WARNING: glyph '$hex' == 0";
    }

    #say $prop;
    %control-chars{$prop}.push($char.uniname)
        if Control-Chars($char.uniprop);
}

if 0 {
for %control-chars.keys.sort -> $k {
    say "key: |$k|";
    my @v = @(%control-chars{$k});
    for @v -> $v {
        my $u = $v.uniparse;
        my $d = $u.ord;
        my $x = $d.base(16);
        #say "  hex: $x";
    }
    #say %control-chars{$k};
}
}

done-testing;
