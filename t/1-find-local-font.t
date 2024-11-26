use Test;

use paths;

my $font-file = 0;
my @dirs = </usr/share/fonts /Users ~/Library/Fonts>;
for @dirs -> $dir {
    for paths($dir) -> $path {
        # take the first of the set of known types handled by PDF 
        # libraries (in order of preference)
        if $path ~~ /:i otf|ttf|woff|pfb $/ {
            $font-file = $path.IO.basename;
            say "Font file: $path";
            last;
        }
    }
}
isa-ok $font-file, Str, "File '$font-file' has been found";

done-testing;
