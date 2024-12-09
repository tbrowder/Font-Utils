use Test;


use PDF::Font::Loader :load-font;
use Font::Utils;
use Font::Utils::FaceFreeType;

my $debug = 0;

my $f1 = "xt/data/fontforge.fonts";

my ($font, $dir, $file);

for $f1.IO.lines -> $basename {
    # incomplete paths: path = dir/basenane
    $dir = "/usr/local/git-repos/forks/fontforge/tests/fonts";
    $file = "$dir/$basename";

    $font = load-font :$file;
    my $ftyp = "unknown";
    if $font.file ~~ /:i '.' (\S+) $/ {
        $ftyp = ~$0;
    }
    say "Font type: $ftyp" if $debug;
    if $ftyp ne 'woff2' {
        my $fo = Font::Utils::FaceFreeType.new: :$font, :font-size(12);
        isa-ok $fo, Font::Utils::FaceFreeType;
    }

    isa-ok $font, PDF::Font::Loader::FontObj; 
    #my $fo = FaceFreeType.new: :$font, :font-size(12);
    #is $fo.has-kerning, False, "has-kerning is False";
}

done-testing;

