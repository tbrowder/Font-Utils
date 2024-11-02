use Test;

use Font::Utils;

my $f1 = "xt/data/fontforge.fonts";
my $f2 = "xt/data/myfonts.list";

for $f1.IO.lines -> $basename {
    # incomplete paths
    my $dir = "/usr/local/git-repos/forks/fontforge/tests/fonts";
    my $file = "$dir/$basename";

    my $o = Font::Utils::FreeTypeFace.new: :$file;
}

for $f2.IO.lines {
    # complete paths
    my $o = Font::Utils::FreeTypeFace.new: :file($_);
}

done-testing;

