use Test;

use PDF::API6; # <== required for $page
use PDF::Content;
use PDF::Font::Loader :load-font;
use PDF::Lite;
use PDF::Content::Text::Box;

use Font::Utils;
use Font::Utils::Misc;

my $debug = 0;

my $file  = "/usr/share/fonts/opentype/freefont/FreeSerif.otf";
my $file2 = "/usr/share/fonts/opentype/freefont/FreeMono.otf";

my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;

my ($fo, $fo2, $tb, $tb2, $width, $font, $text, $font-size);
my ($font2, $font-size2, @bbox);

$font-size  = 12;
$font-size2 = 8;
$width     = 6.5*72;
$font      = load-font :$file;
$font2     = load-font :file($file2);

# get two FreeTypeFace objects for use as needed
$fo  = FreeTypeFace.new: :$file, :$font-size;
$fo2 = FreeTypeFace.new: :$file, :font-size($font-size2);

# create a glyph box
my $ulx = 72;
my $uly = 300;
my $hex = "A734"; # Latin Extended-D
@bbox = make-glyph-box 
    $ulx, $uly, # upper-left corner of the glyph box
    :$font,     # the loaded font being sampled
    :$font2,    # the loaded mono font used for the hex code
    :$fo,       # the font being sampled
    :$fo2,      # the mono font used for the hex code
    :$hex,      # char to be shown
    :$page;

say @bbox.gist;

my $ofil = "xt2glyph-box.pdf";

$pdf.save-as: $ofil;
say "See output file: '$ofil'";

done-testing;
