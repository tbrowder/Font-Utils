use Test;

use PDF::API6; # <== required for $page
use PDF::Content;
use PDF::Font::Loader :load-font;
use PDF::Lite;
use PDF::Content::Text::Box;

use Compress::PDF;
use Font::Utils;
use Font::Utils::FaceFreeType;
use Font::Utils::Misc;

my $debug = 0;

my $file   = "/usr/share/fonts/opentype/freefont/FreeSerif.otf";
my $fileHC = "/usr/share/fonts/opentype/freefont/FreeSans.otf";

my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;

my ($fo, $foHC, $tb, $tb2, $font, $text, $font-size);
my ($fontHC, $font-sizeHC, @bbox);

# dimensions of a Unicode glyph box:
#   hex code font height: 0.15 cm
$font      = load-font :$file;
$fontHC    = load-font :file($fileHC);

# create a glyph box
my $ulx = 72;
my $uly = 10*72;
my $hex = "A734"; # Latin Extended-D
# these dimensions are good for the fonts being used
$font-size   = 19,
$font-sizeHC = 6,

$fo   = Font::Utils::FaceFreeType.new: :$font, :$font-size;
$foHC = Font::Utils::FaceFreeType.new: :font($fontHC) :font-size($font-sizeHC);

my %opts;
%opts<b> = 1; # any value is ok, :exists is True
@bbox = make-glyph-box
    $ulx, $uly, # upper-left corner of the glyph box
    :$fo,       # the loaded font being sampled
    :$foHC,     # the loaded mono font used for the hex code
    :$hex,      # char to be shown
    # the actual box dimensions and baselines are hard-coded as
    # global constants and are a trial-match with a page printed 
    # from the Unicode # page on their website (Latin Extended-D)
    :%opts,
    :$debug,
    :$page;

say @bbox.gist if $debug;

my $ofil = "xt2glyph-box.pdf";

$pdf.save-as: $ofil;
compress $ofil, :quiet, :force, :dpi(300);
say "See output file: '$ofil'";

done-testing;
