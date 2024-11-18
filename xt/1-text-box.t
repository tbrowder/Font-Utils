use Test;

use PDF::Font::Loader :load-font;
use PDF::API6;
use PDF::Lite;
use Font::Utils;

my $debug = 0;
my $ffile = "/usr/share/fonts/opentype/freefont/FreeSerif.otf";
my $pdf = PDF::Lite.new;
my $page = $pdf.add-page;

my ($o, $font, $text);

lives-ok {
   $font = load-font :file($ffile);
   $text = "";
   $o = text-box $text, :$font;
}, "default text-box object";

isa-ok $o, PDF::Content::Text::Box;
is $o.verbatim, False, "good False .verbatim";
is $o.width, 8.5*72;
is $o.height, 11*72;

$o = text-box $text, :$font, :width(6.5*72), :height(0);

my $gfx = $page.gfx;
$gfx.BeginText;
$o.render: $gfx;
$gfx.EndText;
$o.text = "Good night!";
$gfx.BeginText;
$o.render: $gfx;
$gfx.EndText;
$pdf.save-as: "xt-test1.pdf";


my $para1 = qq:to/HERE/;
HERE

my $para2 = qq:to/HERE/;
HERE


#say $o.content-width;
#say $o.content-height;


done-testing;

