use Test;

=begin comment
# these are not needed if no PDF::Lite $page is needed

#use PDF::API6; # <== required for $page
#use PDF::Content;
#use PDF::Lite;
#use PDF::Content::Text::Box;
=end comment

use PDF::Font::Loader :load-font;

use Font::Utils;
use Font::Utils::Misc;
use Font::Utils::FaceFreeType;

my $debug = 0;

my $file  = "/usr/share/fonts/opentype/freefont/FreeSerif.otf";
my $font  = load-font :$file;

my $fo = Font::Utils::FaceFreeType;

is $fo, Font::Utils::FaceFreeType;

done-testing;
