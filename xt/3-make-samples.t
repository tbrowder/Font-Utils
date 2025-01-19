use Test;

use OO::Monitors;

use QueryOS;
my $os = OS.new;

use PDF::API6; # <== required for $page
use PDF::Content;
use PDF::Font::Loader :load-font, :find-font;
use PDF::Lite;
use PDF::Content::Text::Box;

use Compress::PDF;
use Font::Utils;
use Font::Utils::FaceFreeType;
use Font::Utils::Misc;
use Font::Utils::Subs;

my $debug    = 0;
my $compress = 0;

my ($file, $fileHC, $file3, $ofil);

my $ftest1 = 1; # all noto ttf (OK)
my $ftest2 = 0; # all freefont otf (lots of missing glyphs)
my $ftest3 = 0; # all freefont ttf (almost OK)

if $os.is-windows {
    $file    = "/usr/share/fonts/truetype/noto/NotoSerif-Regular.ttf";
    # this is the font for showing hex codes:
    $fileHC  = "/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf";
}
else {
    if $ftest1 {
        $file   = "/usr/share/fonts/truetype/noto/NotoSerif-Regular.ttf";
        # this is the font for showing hex codes:
        $fileHC = "/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf";
    }
    elsif $ftest2 {
        $file  = "/usr/share/fonts/opentype/freefont/FreeSerif.otf";
        # this is the font for showing hex codes:
        $fileHC = "/usr/share/fonts/opentype/freefont/FreeSans.otf";
    }
    elsif $ftest3 {
        $file  = "/usr/share/fonts/truetype/freefont/FreeSerif.ttf";
        # this is the font for showing hex codes:
        $fileHC = "/usr/share/fonts/truetype/freefont/FreeSans.ttf";
    }
    else {
        note "FATAL: Unknown '\$ftest' number (not defined or listed)";
    }

}

my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;

my ($fo, $foHC, $tb, $tb2, $font, $text, $font-size);
my ($fontHC, $font-sizeHC, @bbox);

$font      = load-font :$file;
$fontHC    = load-font :file($fileHC);

$font-size   = 16;
$font-sizeHC =  8;

$fo   = Font::Utils::FaceFreeType.new: :$font, :$font-size;
$foHC = Font::Utils::FaceFreeType.new: :font($fontHC) :font-size($font-sizeHC);

my @ignored = $fo.ignored;

isa-ok $fo, Font::Utils::FaceFreeType;
isa-ok $foHC, Font::Utils::FaceFreeType;

# create a sample glyph page
my %opts;

my $test1 = 0;
my $test2 = 1;
my $test3 = 0;

is 1, 1;

if $test1 {
    %opts<ng> = 15;  # show max of N glyphs per section
    %opts<ns> = 2;   # show only first N sections
    %opts<sn> = 1,3;  # show only "X,Y,..Z" sections
    %opts<of> = "test1-sample.pdf";  # define output file name
    make-font-sample-doc $file, :%opts, :$debug;
} # $test1

if $test2 {
    # use basename in title
    my $f = $file;
    my $bnam = $f.IO.basename;
    my $ofilX = "{$bnam}-sample";
    $ofilX ~~ s:g/'.'/-/;
    $ofilX = $ofilX ~ '.pdf';
    %opts = %();
    %opts<of> = $ofilX ;  # define output file name
    %opts<sn> = "1,2,3,4,5,6,7,8,9,10,11,12";
    make-font-sample-doc $f, :%opts, :$debug;

    =begin comment
    unless $os.is-windows {
        # sample the Free Font
        $f = $file3;
        $bnam = $f.IO.basename;
        my $ofilX = "{$bnam}-sample";
        $ofilX ~~ s:g/'.'/-/;
        $ofilX = $ofilX ~ '.pdf';
        %opts = %();
        %opts<of> = $ofilX ;  # define output file name
        %opts<sn> = "1,2,3,4,5,6,7,8,9,10,11,12";
        make-font-sample-doc $f, :%opts, :$debug;
    }
    =end comment

} # $test2

if $test3 {
    # complete sections individually
    %opts<ng> = 0; # show max of N glyphs per section
    %opts<ns> = 0; # show only first sections
    %opts<sn> = "1,2,3"; # show only "X,Y,..Z" sections
    %opts<of> = "test3-sample.pdf";  # define output file name
    for 1..12 -> $n {
        %opts<sn> = $n.Str;  # show only section $n
        %opts<of> = "section-sample$n.pdf";  # define output file name
        make-font-sample-doc $file, :%opts, :$debug;
    }
} # $test3

done-testing;

=finish

# glyph box
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

if $compress {
    compress $ofil, :quiet, :dpi(300);
}

say "See output file: '$ofil'";

done-testing;
