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

my $fo = Font::Utils::FaceFreeType.new: :$font, :font-size(12);

isa-ok $fo, Font::Utils::FaceFreeType;

my @lines = [
    "T. M. Browder, Jr.",
    "114 Shoreline Dr",
    "Gulf Breeze, FL 32561";
];


lives-ok {
    my $bbox = $fo.lines-bbox(@lines);
    say "{$bbox.gist}";
}, "testing method lines-bbox";

done-testing;
