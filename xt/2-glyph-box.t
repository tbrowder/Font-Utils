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

my ($fo, $fo2, $tb, $tb2, $font, $text, $font-size);
my ($font2, $font-size2, @bbox);

# dimensions of a Unicode glyph box:
#   hex code font height: 0.15 cm
$font      = load-font :$file;
$font2     = load-font :file($file2);

#=begin comment
## get two FreeTypeFace objects for use as needed
#$fo  = FreeTypeFace.new: :$file, :font-size(16);
#$fo2 = FreeTypeFace.new: :$file, :font-size(8);
#=end comment

# create a glyph box
my $ulx = 72;
my $uly = 10*72;
my $hex = "A734"; # Latin Extended-D
# these dimensions are good for the fonts being used
$font-size  = 19,
$font-size2 = 6,
@bbox = make-glyph-box
    $ulx, $uly, # upper-left corner of the glyph box
    :$font,     # the loaded font being sampled
    :$font2,    # the loaded mono font used for the hex code
    :$hex,      # char to be shown
    :$font-size,
    :$font-size2,
    # the actual box dimensions and baselines are hard-coded in the
    # sub and are a trial-match with a page printed from the Unicode
    # page on their website (Latin Extended-D)
#=begin comment
#    # these are not needed for normal use:
#    :$fo,       # the font being sampled
#    :$fo2,      # the mono font used for the hex code
#=end comment

    :$page;

say @bbox.gist if $debug;

my $ofil = "xt2glyph-box.pdf";

$pdf.save-as: $ofil;
say "See output file: '$ofil'";

done-testing;
