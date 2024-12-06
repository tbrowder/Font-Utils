use Test;

use PDF::Font::Loader :load-font;
use Font::Utils;
use Font::Utils::FaceFreeType;

my $f1 = "xt/data/fontforge.fonts";

my ($font, $dir, $file);
;
for $f1.IO.lines -> $basename {
    # incomplete paths: path = dir/basenane
    $dir = "/usr/local/git-repos/forks/fontforge/tests/fonts";
    $file = "$dir/$basename";

    $font = load-font :$file;
    my $o = Font::Utils::FaceFreeType.new: :$font, :$file, :font-size(10);
    is $o.has-kerning, False, "has-kerning is False";
}

done-testing;

