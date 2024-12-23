use Test;

use PDF::Font::Loader :load-font;
use Text::Utils :strip-comment;

use Font::Utils;
use Font::Utils::Misc;
use Font::Utils::FaceFreeType;

my $debug = 0;
is 1, 1;

my $dir   = "$*HOME/.Font-Utils";
my $flist = slurp "$dir/font-files.list";
for $flist.lines -> $line is copy {
    $line = strip-comment $line;
    next unless $line ~~ /\S/; # skip blank lines
    my @w = $line.words;
    my $nw = @w.elems;
    unless $nw == 3 {
        note "WARNING: line doesn't have 3 words it has $nw";
    }

    say "line: $line" if $debug;
    my $key = @w.shift;
    my $basename = @w.shift;
    say "DEBUG: found file basename '$basename'" if $debug;
    my $file = @w.shift.IO.absolute;
    my $font = load-font :$file;
    my $face = $font.face;
    note "=== Inspecting font '$basename' =========" if $debug;
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

        my $width  = 0;
        my $height = 0;

        say qq:to/HERE/ if $debug;
        glyph-index: $glyph-index
           char: $char
          glyph: $glyph
           name: $name
            dec: $dec
            hex: $hex
           prop: $prop
        HERE

        # try to get the size
        $face.forall-chars: $glyph, -> $g {
            $width  = $g.width;
            $height = $g.height;
        }
        if $debug and $width <= 0 {
            note "  hex $hex width = 0";
            say "  width: $width" if $debug;
        }
        if $debug and $height <= 0 {
            note "  hex $hex height = 0";
            say " height: $height" if $debug;
        }
    }
}

done-testing;
   
=finish

for @fils -> $file {
    my $font = load-font :$file;
    my $basename = $file.IO.basename;
    my $fo = Font::Utils::FreeFaceType.new: :$file, :size(12);
    say "DEBUG: found file basename '$basename'" if $debug;
}

done-testing;
