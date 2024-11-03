#!/usr/bin/env raku

use PDF::Lite;
use PDF::Content::Page :PageSizes, :&to-landscape;
use PDF::Font::Loader :load-font;
use QueryOS;

my $os = QueryOS.new;

use lib "../lib";
use FontFactory;
use FontFactory::Classes;
use FontFactory::X::FontHashes;

my %n = %FontFactory::X::FontHashes::number;

my $ofil = "Gnu-FontFactory-samples.pdf";

my $pdf = PDF::Lite.new;

# TODO: add page numbers upper right of page

my $face2 = 0; #  = "FreeSerifBold";
my $face3 = 0; #  = "FreeSerif";
my $f2 = "FreeSerifBold.otf";
my $f3 = "FreeSerif.otf";

my %m = %(PageSizes.enums);
my @m = %m.keys.sort;

#=== move this code chunk WAY up
my $debug = 0;
if not @*ARGS.elems {
    my $p = $*PROGRAM.basename;

    print qq:to/HERE/;
    Usage: $p <mode> [options]

    Modes
      print  - Create a PDF of the default text samples

    Options
      A4     - Use A4 paper instead of the default US Letter
               for the sample output file:
                   $ofil

    See more information about pangrams and a large list of them
    for many languages at 'https:://clagnut.com'.
    HERE
    exit
}
#=== move code chunk above WAY up

my ($text, $page);

my $m1 = 'Letter';
my $m2 = 'A4';
my $media = $m1; # the default
my $landscape = True;

# find attributes:
# NOT using find-font

for @*ARGS {
    # one/two char options
    when /^:i a4?/ {
        $media = $m2;
    }
    # single char options
    default {
        note "FATAL: Unknown argument '$_'";
    }
}

my $font       = load-font :file($font-file);
my $title-font = load-font :file($title-font-file);

$pdf.media-box = %(PageSizes.enums){$media};

$page = $pdf.add-page;
make-page :$pdf, :$page, :$font, :$title-font, :$media, :%h, :landscape(True), :font-name($default-font-stem);

} # end of pages loop

# end the document
$pdf.save-as: $ofil;
#my $landscape = False;
say "See output file: $ofil";

#====================================
# subroutines
sub make-page(
              PDF::Lite :$pdf!,
              PDF::Lite::Page :$page!,
              :$font!,
              :$font-size = 10,
              :$title-font!,
              :$media!,
              :$landscape = False,
              :$font-name!,
              :%h!, # data
) is export {
    my ($cx, $cy);

    =begin comment
    my $up = $font.underlne-position;
    my $ut = $font.underlne-thickness;
    note "Underline position:  $up";
    note "Underline thickness: $ut";
    =end comment

    # portrait
    # use the page media-box
    $page.media-box = %(PageSizes.enums){$media};
    $cx = 0.5 * ($page.media-box[2] - $page.media-box[0]);
    $cy = 0.5 * ($page.media-box[3] - $page.media-box[1]);

    if not $landscape {
        die "FATAL: Tom, fix this";
        return
    }

    my (@bbox, @position);
    $page.graphics: {
        .Save;
        .transform: :translate($page.media-box[2], $page.media-box[1]);
        .transform: :rotate(90 * pi/180); # left (ccw) 90 degrees

        # is this right? yes, the media-box values haven't changed,
        # just its orientation with the transformations
        my $w = $page.media-box[3] - $page.media-box[1];
        my $h = $page.media-box[2] - $page.media-box[0];
        $cx = $w * 0.5;

        # get the font's values from FontFactory
        my ($leading, $height, $dh);
        $leading = $height = $dh = $sm.height; #1.3 * $font-size;

        # use 1-inch margins left and right, 1/2-in top and bottom
        # left
        my $Lx = 0 + 72;
        my $x = $Lx;
        # top baseline
        my $Ty = $h - 36 - $dh; # should be adjusted for leading for the font/size
        my $y = $Ty;

        # start at the top left and work down by leading
        #@position = [$lx, $by];
        #my @bbox = .print: "Fourth page (with transformation and rotation)", :@position, :$font,
        #              :align<center>, :valign<center>;

        # print a page title
        my $ptitle = "FontFactory Language Samples for Font: $font-name";
        @position = [$cx, $y];
        @bbox = .print: $ptitle, :@position,
                       :font($title-font), :font-size(16), :align<center>, :kern;
my $pn = "Page $curr-page of $npages"; # upper-right, right-justified
        @position = [$rx, $y];
        @bbox = .print: $pn, :@position,
                       :font($pn-font), :font-size(10), :align<right>, :kern;

        if 1 {
            note "DEBUG: \@bbox with :align\<center>: {@bbox.raku}";
        }

        =begin comment
        # TODO file bug report: @bbox does NOT recognize results of
        #   :align (and probably :valign)
        # y positions are correct, must adjust x left by 1/2 width
        .MoveTo(@bbox[0], @bbox[1]);
        .LineTo(@bbox[2], @bbox[1]);
        =end comment
        my $bwidth = @bbox[2] - @bbox[0];
        my $bxL = @bbox[0] - 0.5 * $bwidth;
        my $bxR = $bxL + $bwidth;

        =begin comment
        # wait until underline can be centered easily

        # underline the title
        # underline thickness, from docfont
        my $ut = $sm.underline-thickness; # 0.703125;
        # underline position, from docfont
        my $up = $sm.underline-position; # -0.664064;
        .Save;
        .SetStrokeGray(0);
        .SetLineWidth($ut);
        # y positions are correct, must adjust x left by 1/2 width
        .MoveTo($bxL, $y + $up);
        .LineTo($bxR, $y + $up);
        .CloseStroke;
        .Restore;
        =end comment

        # show the text font value
        $y -= 2* $dh;

        $y -= 2* $dh;

        for %h.keys.sort -> $k {
            my $country-code = $k.uc;
            my $lang = %h{$k}<lang>;
            my $text = %h{$k}<text>;

            =begin comment
            @position = [$x, $y];
            my $words = qq:to/HERE/;
            -------------------------
              Country code: {$k.uc}
                  Language: $lang
                  Text:     $text
            -------------------------
            =end comment

            # print the dashed in one piece
            my $dline = "-------------------------";
            @bbox = .print: $dline, :position[$x, $y], :$font, :$font-size,
                            :align<left>, :kern; #, default: :valign<bottom>;

            # use the @bbox for vertical adjustment [1, 3];
            $y -= @bbox[3] - @bbox[1];

            #  Country code / Language: {$k.uc} / German
            @bbox = .print: "{$k.uc} - Language: $lang", :position[$x, $y],
                    :$font, :$font-size, :align<left>, :!kern;

            # use the @bbox for vertical adjustment [1, 3];
            $y -= @bbox[3] - @bbox[1];

            # print the line data in two pieces
            #     Text:     $text
            @bbox = .print: "Text: $text", :position[$x, $y],
                    :$font, :$font-size, :align<left>, :kern;

            # use the @bbox for vertical adjustment [1, 3];
            $y -= @bbox[3] - @bbox[1];
        }
        # add a closing dashed line
        # print the dashed in one piece
        my $dline = "-------------------------";
        @bbox = .print: $dline, :position[$x, $y], :$font, :$font-size,
                :align<left>, :kern; #, default: :valign<bottom>;

        #=== end of all data to be printed on this page
        .Restore; # end of all data to be printed on this page
    }
}

BEGIN {
%default-samples = [
    # keyed by two-character ISO language code
    #     key => {
    #         lang => "",
    #         text => "",
    #         font => "",
    #     }
    nl => {
        lang => 'Dutch',
        text => 'Quizdeltagerne spiste jordbær med fløde, mens cirkusklovnen Walther spillede pålofon.',
        font => "",
    },
    en => {
        lang => 'English',
        text => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz 0123456789 Oo Fi fi fii Wa',
    },
    fr => {
        lang => 'French',
        text => 'Quizdeltagerne spiste jordbær med fløde, mens cirkusklovnen Walther spillede på xylofon.',
        font => "",
    },
    de => {
        lang => 'German',
        text => 'Zwölf Boxkämpfer jagen Viktor quer über den großen Sylter Deich.',
        font => "",
    },
    id => {
        lang => 'Indonesian',
        text => 'Saya lihat foto Hamengkubuwono XV bersama enam zebra purba cantik yang jatuh dari Al Quranmu.',
        font => "",
    },
    it => {
        lang => 'Italian',
        text => 'Ma la volpe, col suo balzo, ha raggiunto il quieto Fido.',
        font => "",
    },
    nb => {
        lang => 'Norwegian (Bokmål)',
        text => 'En god stil må først og fremst være klar. Den må være passende. Aristoteles.',
        font => "",
    },
    nn => {
        lang => 'Norwegian (Nyorsk)',
        text => "NONE YET",
        font => "",
    },
    pl => {
        lang => 'Polish',
        text => 'Pchnąć w tę łódź jeża lub ośm skrzyń fig.',
        font => "",
    },
    ro => {
        lang => 'Romanian',
        text => 'Agera vulpe maronie sare peste câinele cel leneş.',
        font => "",
    },
    ru => {
        lang => 'Russian',
        text => 'Съешь ещё этих мягких французских булок да выпей же чаю.',
        font => "",
    },
    es => {
        lang => 'Spanish',
        text => 'El veloz murciélago hindú comía feliz cardillo y kiwi. La cigüeña tocaba el saxofón detrás del palenque de paja.',
        font => "",
    },
    uk => {
        lang => 'Ukranian',
        text => 'Чуєш їх, доцю, га? Кумедна ж ти, прощайся без ґольфів!',
        font => "",
    },
];
} # end BEGIN
