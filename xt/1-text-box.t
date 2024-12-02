use Test;

use PDF::API6; # <== required for $page
use PDF::Content;	
use PDF::Font::Loader :load-font;
use PDF::Lite;
use PDF::Content::Text::Box;

use Font::Utils;
use Font::Utils::Misc;

my $debug = 0;

my $file = "/usr/share/fonts/opentype/freefont/FreeSerif.otf";

my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;

my ($width, $font, $text, $font-size);

$font-size = 12;
$width     = 8.5*72;
$font      = load-font :$file;

# get a FaceFreeFont object for comparison
my $fo = FreeTypeFace.new: :$file, :$font-size;


# a reusable text box:  with filled text
# but initially empty
my PDF::Content::Text::Box $tb .= new(
    :text(""), 
    # <== note font information is rw
    :$font, :$font-size,
    :align<left>, 
    :$width
);

isa-ok $tb, PDF::Content::Text::Box;
is $tb.width, 8.5*72;
is $tb.height, 13.2, "height = line-spacing = font-size x leading";
is $tb.leading, 1.1, "leading: {$tb.leading}";
is $tb.font-height, 17.844, "font-height: {$tb.font-height}";

# render it as $page.text
$tb.text = "Howdy";
$page.text: {
    # first line baseline
    .text-position = 72, 720; 
    .print: $tb;
}

# try cloning
my $tb2 = $tb.clone: :text("More");
isa-ok $tb2, PDF::Content::Text::Box;
say "content-width: ", $tb2.content-width;
say "content-height: ", $tb2.content-height;
say "baseline-shift: ", $tb2.baseline-shift;
say "leading: ", $tb2.leading;


# render it as $page.text
$page.text: {
    # first line baseline
    .text-position = 72, 600; 
    .print: $tb2;

    .text-position = 72, 500;
    my @bbox = .print($tb2);
    say "\@bbox = '{@bbox.gist}'";
}

my $ofil = "xt-test-box.pdf";
$pdf.save-as: $ofil;
say "See output file: '$ofil'"; 

done-testing;

=finish

#$tb = text-box $text, :$font, :width(6.5*72);

#=begin comment
# render
my $g = $page.gfx;
$g.Save;
$g.BeginText;
$g.text-position = [72, 10*72];
my $txt = "Good night!";
$g.print: $txt
#$g.say();

my @c = %uni<L-chr>.words;
my $c = hex2string @c;
$c ~= $c;
# break the string into individual chars
$c = $c.comb.join("| ");

#:$o = text-box $c, :$font, :width(6.5*72);
$g.print: $tb;
$g.EndText;
$g.Restore;
say "text: ", $c;
say "text-box width: ", $tb.width;
say "text-box content-width: ", $tb.content-width;
say "text-box height: ", $tb.height;
say "text-box content-height: ", $tb.content-height;
#my @lines = @($o.Str.lines);
my @lines = @($tb.lines);
#my @lines = @($tb.lines.Str); #.text;
say "text-box lines:";
say " {$_.text}" for @lines;
#say "text box:", $o;

$pdf.save-as: "xt-test1.pdf";

my $para1 = qq:to/HERE/;
HERE

my $para2 = qq:to/HERE/;
HERE


#say $o.content-width;
#say $o.content-height;
#=end comment

done-testing;
