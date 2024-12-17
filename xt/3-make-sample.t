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

my $debug = 1;

my $file  = "/usr/share/fonts/opentype/freefont/FreeSerif.otf";
my $file2 = "/usr/share/fonts/opentype/freefont/FreeSans.otf";

my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;

my ($fo, $fo2, $tb, $tb2, $font, $text, $font-size);
my ($font2, $font-size2, @bbox);

$font      = load-font :$file;
$font2     = load-font :file($file2);

$font-size  = 16;
$font-size2 =  8;

$fo  = Font::Utils::FaceFreeType.new: :$font, :$font-size;
$fo2 = Font::Utils::FaceFreeType.new: :font($font2) :font-size($font-size2);

isa-ok $fo, Font::Utils::FaceFreeType;
isa-ok $fo2, Font::Utils::FaceFreeType;

# create a sample glyph page
my %opts;
%opts<ng> = 15; # show max of X glyphs per section
%opts<ns> = 0;  # show only X sections
%opts<sn> = 0;  # show only section X
%opts<of> = "my-test.pdf";  # define output file name
make-font-sample-doc $file, :%opts, :$debug;

done-testing;

=finish

glyph box
my $ulx = 72;
my $uly = 10*72;
my $hex = "A734"; # Latin Extended-D
# these dimensions are good for the fonts being used
$font-size  = 19,
$font-size2 = 6,

$fo  = Font::Utils::FaceFreeType.new: :$font, :$font-size;
$fo2 = Font::Utils::FaceFreeType.new: :font($font2) :font-size($font-size2);

my %opts;
%opts<b> = 1;  # any value is ok, :exists is True
%opts<n> = 50; # number of glyphs to show
@bbox = make-glyph-box
    $ulx, $uly, # upper-left corner of the glyph box
    :$fo,       # the loaded font being sampled
    :$fo2,      # the loaded mono font used for the hex code
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
compress $ofil, :quiet, :dpi(300);
say "See output file: '$ofil'";

done-testing;
