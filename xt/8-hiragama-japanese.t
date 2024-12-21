use Test;


use OO::Monitors;

use PDF::API6; # <== required for $page
use PDF::Content;
use PDF::Font::Loader :load-font;
use PDF::Lite;
use PDF::Content::Text::Box;

use Compress::PDF;
use Font::Utils;
use Font::Utils::FaceFreeType;
use Font::Utils::Misc;

my $debug    = 0;
my $compress = 0;

my $file  = "Noto_Serif_JP/NotoSerifJP-VariableFont_wght.ttf";
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

is 1, 1;

%opts<of> = "my-test-sample.pdf";  # define output file name
make-font-sample-doc $file, :%opts, :$debug;

done-testing;
