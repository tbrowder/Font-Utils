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

my $quote = q:to/HERE/;
The General is sorry to be informed that the foolish, and wicked
practice, of profane cursing and swearing (a Vice heretofore little
known in an American Army) is growing into fashion; he hopes the
officers will, by example, as well as influence, endeavour to check
it, and that both they, and the men will reflect, that we can have
little hopes of the blessing of Heaven on our Arms, if we insult it by
our impiety, and folly; added to this, it is a vice so mean and low,
without any temptation, that every man of sense, and character,
detests and despises it.
HERE

my $file = "/usr/share/fonts/opentype/freefont/FreeSerif.otf";

my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;

my ($width, $font, $text, $font-size);

$font-size = 12;
$width     = 6.5*72;
$font      = load-font :$file;

# get a FaceFreeType object for comparison
my $fo = Font::Utils::FaceFreeType.new: :$file, :$font-size, :$font;


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
is $tb.width, 6.5*72;
is $tb.height, 13.2, "height = line-spacing = font-size x leading";
is $tb.leading, 1.1, "leading: {$tb.leading}";
is $tb.font-height, 17.844, "font-height: {$tb.font-height}";
say "content-width: ", $tb.content-width;
say "content-height: ", $tb.content-height;

# render it as $page.text
$tb.text = $quote;
say "content-width: ", $tb.content-width;
say "content-height: ", $tb.content-height;

my @bbox;
$page.text: {
    # first line baseline
    .text-position = 72, 720;
    @bbox = .print: $tb;
}

# try cloning
my $tb2 = $tb.clone: :text($quote), :width(4*72);;
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
    .text-position = 72, 400;
    @bbox = .print: $tb2;
}
say "\@bbox = '{@bbox.gist}'";

# border it
my $g = $page.gfx;
$g.Save;
$g.SetLineWidth: 0;
$g.MoveTo: @bbox[0], @bbox[3]; # top left
$g.LineTo: @bbox[0], @bbox[1]; # bottom left
$g.LineTo: @bbox[2], @bbox[1]; # bottom right
$g.LineTo: @bbox[2], @bbox[3]; # top right
$g.ClosePath;
$g.Stroke;
$g.Restore;

# try another clone
my $tb3 = $tb.clone: :text($quote), :align<justify>, :width(4*72),
                     :word-wrap($fo.stringwidth(' '));
isa-ok $tb3, PDF::Content::Text::Box;
say "content-width: ", $tb3.content-width;
say "content-height: ", $tb3.content-height;
say "baseline-shift: ", $tb3.baseline-shift;
say "leading: ", $tb3.leading;

if 0 {
    # David's solution:
    given $tb3.lines.tail {
        # +.decoded,   # <== the original plus sign was removed
        .decoded,
        .content-width,
        .word-gap = 6; # <== this is trial and error (David's solution)
    };
}
else {
    # David's solution with my mod
    given $tb3.lines.tail {
        .decoded,        # <== the plus sign was removed
        .content-width,
        # .word-gap = 6; # <== this is trial and error (David's solution)
        .word-gap = $fo.stringwidth(' ');
    };
}


# I get the width of a ' ' character
# render it as $page.text
$page.text: {
    # first line baseline
    .text-position = 72, 200;
    @bbox = .print: $tb3;
}
say "\@bbox = '{@bbox.gist}'";



my $ofil = "xt1test-box.pdf";
$pdf.save-as: $ofil;
compress $ofil, :dpi(300), :quiet, :force;
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
