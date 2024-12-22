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

#my $file  = "Noto_Serif_JP/NotoSerifJP-VariableFont_wght.ttf";
#my $file  = "Noto_Serif_JP/static/NotoSerifJP-ExtraBold.ttf";
my $file  = "Noto_Serif_JP/static/NotoSerifJP-Bold.ttf";

my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;

my ($fo, $fo2, $tb, $tb2, $font, $text, $font-size);
my ($font2, $font-size2, @bbox);

$font       = load-font :$file;
$font-size  = 16;

$fo  = Font::Utils::FaceFreeType.new: :$font, :$font-size;

isa-ok $fo, Font::Utils::FaceFreeType;

# create a sample glyph page
my %opts;

is 1, 1;

$text = qq:to/HERE/;
3059-305D
306B-306F
HERE

my @lines = $text.lines;
#.say for @lines;

is @lines.elems, 2;

my $ofil = "my-haranga-sample.pdf";  # define output file name
make-sample-page $text, :$font, :text-is-hex, :$page, :$debug;
$pdf.save-as: $ofil;
say "See output file: '$ofil'";

done-testing;
