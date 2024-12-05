use Test;

use PDF::API6; # <== required for $page
use PDF::Content;
use PDF::Font::Loader :load-font;
use PDF::Lite;
use PDF::Content::Text::Box;

use Font::Utils;
use Font::Utils::Misc;
use Font::Utils::FaceFreeType;

my $debug = 0;

my $file  = "/usr/share/fonts/opentype/freefont/FreeSerif.otf";
my $font  = load-font :$file;

is 1, 1;

done-testing;
