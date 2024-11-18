unit module Font::Utils;

=begin comment
# freefont locations by OS
my $Ld = "/usr/share/fonts/opentype/freefont";
my $Md = "/opt/homebrew/Caskroom/font-freefont/20120503/freefont-20120503";
my $Wd = "/usr/share/fonts/opentype/freefont";
=end comment

use MacOS::NativeLib "*";
use QueryOS;
use Font::FreeType;
use Font::FreeType::Glyph;
use File::Find;
use Text::Utils :strip-comment;
use Bin::Utils;
use YAMLish;
use PDF::Lite;
use PDF::API6;
use PDF::Content::Color :ColorName, :color;
use PDF::Content::XObject;
use PDF::Tags;
use PDF::Content::Text::Box;
use Compress::PDF;

class FreeTypeFace is export {
    use Font::FreeType;

    has $.file is required;

    my $p;
    my $face;

    submethod TWEAK {
        $p    = $!file;
        $face = Font::FreeType.new.face: $!file.Str;
    }

    method basename             { $p.IO.basename        }
    method family-name          { $face.family-name     }
    method style-name           { $face.style-name      }
    method postscript-name      { $face.postscript-name }
    method font-format          { $face.font-format     }
    method num-glyphs           { $face.num-glyphs      }
    method bbox                 { $face.bbox            }
    method height               { $face.height          }
    method leading              { $face.height          } # alias

    # size and glyph info
    #method set-font-size($size) { $face.

    method is-scalable          { $face.is-scalable          ?? True !! False }
    method is-fixed-width       { $face.is-fixed-width       ?? True !! False }
    method has-kerning          { $face.has-kerning          ?? True !! False }
    method is-bold              { $face.is-bold              ?? True !! False }
    method is-italic            { $face.is-italic            ?? True !! False }
    method is-sfnt              { $face.is-sfnt              ?? True !! False }
    method fixed-sizes          { $face.fixed-sizes          ?? True !! False }
    method scaled-metrics       { $face.scaled-metrics       ?? True !! False }
    method has-vertical-metrics { $face.has-vertical-metrics ?? True !! False }
    method has-glyph-names      { $face.has-glyph-names      ?? True !! False }

    method has-horizontal-metrics   { 
        $face.has-horizontal-metrics   ?? True !! False
    }
    method has-reliable-glyph-names { 
        $face.has-reliable-glyph-names ?? True !! False 
    }

=begin comment
    # TODO make methods
    # properties
    with $face.charmap {
        @properties.push: 'enc:' ~ .key.subst(/^FT_ENCODING_/, '').lc
            with .encoding;
=end comment

}

my $o = OS.new;
my $onam = $o.name;

# use list of font file directories of primary
# interest on Debian (and Ubuntu)
our @fdirs is export;
with $onam {
    when /:i deb|ubu / {
        @fdirs = <
            /usr/share/fonts/opentype/freefont
        >;
        =begin comment
        =end comment

        #   /usr/share/fonts/opentype/linux-libertine
        #   /usr/share/fonts/opentype/cantarell
    }
    when /:i macos / {
        @fdirs = <
            /opt/homebrew/Caskroom/font-freefont/20120503/freefont-20120503
        >;
    }
    when /:i windows / {
        @fdirs = <
            /usr/share/fonts/opentype/freefont
        >;
    }
    default {
        die "FATAL: Unhandled OS name: '$_'. Please file an issue."
    }
}

sub help() is export {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <mode> ...font files...

    Provides various programs and routines to aid working with
    fonts. The first argument is the desired operation.
    Remaining arguments are expected to be a set of font files
    or files containing lists of files and directories to
    investigate. 

    Optional arguments for the 'sample' mode may be mixed in
    with them. See the README for details.

    The 'sample' mode can take one or more 'key=value' options 
    as shown below.

    All of the modes can take an 'eg' option to use a font
    file on the user's system to demonstrate its use with a random
    font (in order, the font type searched for is: .otf, .ttf,
    .pfb, .woff).

    Modes:
      list   - List family and font names in a font file
      show   - Show details of font files
      sample - Create a PDF document showing samples of
                 selected fonts

    Options:
      eg     - For all modes, use a single random local font
      ng=X   - Where X is the maximum number of glyphs to show
      m=A4   - A4 media
      o=L    - Landscape orientation
      s=X    - Where X is the font size
      of=X   - Where X is the name of the output file

    HERE
    exit;
}

# modes and options
my $Rshow   = 0;
my $Rlist   = 0;
my $Rsample = 0;
my $debug   = 0;
my $dir;

sub use-args(@args is copy) is export {
    my $mode = @args.shift;

    with $mode {
        when /^ :i L / {
            ++$Rlist;
        }
        when /^ :i sh / {
            ++$Rshow;
        }
        when /^ :i sa / {
            ++$Rsample;
        }
        default {
            if $mode ~~ /^ :i s/ {
                say "FATAL: Uknown mode '$_'";
                say "  (did you mean 'show' or 'sample'?)";
            }
            else {
                say "FATAL: Uknown mode '$_'";
            }
            exit;
        }
    }

    # remaining args are a mixed bag
    my @dirs; 
    my @fils; 
    my %opts;

    for @args {
        when /^ :i eg $/ {
            # use App::Rak to find a local font file
            my $f = find-local-font;
            @fils.push: $f;
        }
        when /^ :i (\w+) '=' (\w+) / {
            my $key = ~$0;
            my $val = ~$1;
            # decode later
            %opts{$key} = $val;
        }
        when $_.IO.d {
            say "'$_' is a directory";
            @dirs.push: $_;
        }
        when $_.IO.f {
            say "'$_' is a file";
            # handle it here
            my @lines = $_.IO.lines;
            if not @lines.elems {
                note qq:to/HERE/;
                WARNING: File '$_' is empty, skipping it.
                HERE
                next;
            }
            for @lines -> $line {
                my @w = $line.words;
                for @w -> $w {
                    # should be a file name or a directory
                    if $w.IO.d {
                        @dirs.push: $w;
                    }
                    elsif $w.IO.f {
                        @fils.push: $w;
                    }
                    else { 
                        note qq:to/HERE/;
                        WARNING: word '$w' in file '$_' is not a file or a directory
                        HERE
                    }
                }
            }
        }
        when /^ :i d / {
            ++$debug;
        }
        default {
            die "FATAL: Uknown option '$_'";
        }
    } # end of arg handling

    # take care of @fils, @dirs, and %opts
    my @DIRS;
    my @FILS;
    for @dirs {
        say "DEBUG: trying a dummy file '$_'";
        my $o = FreeTypeFace.new: :file($_);
    }
    for @fils {
        say "DEBUG: trying a dummy file '$_'";
        my $o = FreeTypeFace.new: :file($_);
    }

    if $debug {
        say "DEBUG is on";
    }

    if $Rshow {
        my @dirs;
        if $dir.defined {
            @dirs.push: $dir;
        }
        else {
            @dirs = @fdirs;
        }

        my %fam; # keyed by family name
        my %nam; # keyed by postscript name

        for @dirs -> $dir {
            my @fils = find :$dir, :type<file>, :name(/:i '.' [o|t] tf $/);
            for @fils {
                my $o = FreeTypeFace.new: :file($_);
                my $nam = $o.postscript-name;
                my $fam = $o.family-name;
                %fam{$fam} = 1;
                %nam{$nam} = $_;

         #      say "name: {$o.postscript-name}";
         #      say "  family: {$o.family-name}";

                #show-font-info $_, :$debug;
            }
        }

        my @fams = %fam.keys.sort;
        my @nams = %nam.keys.sort;
        my $idx;

        say "Font family names:";
        $idx = 0;
        for @fams {
            ++$idx;
            say "$idx   $_";
        }

        say "Font PostScript  names:";
        $idx = 0;
        for @nams {
            ++$idx;
            say "$idx   $_";
        }

        say "End of mode 'show'" if 1;
        exit;
    } # end of $Rshow

    if $Rlist {
        say "End of mode 'list'" if 1;
        exit;
    } # end of $Rlist

    if $Rsample {
        say "End of mode 'sample'" if 1;
        exit;
    } # end of $Rlist




}

sub get-font-info(
    $path, 
    :$debug 
    --> FreeTypeFace
    ) is export {

    my $file = $path.Str; # David's sub REQUIRES a Str for the $filename
    my $o = FreeTypeFace.new: :$file;
}

sub show-font-info(
    $path, 
    :$debug
    ) is export {

    my $file = $path.Str; # David's sub REQUIRES a Str for the $filename
    my $face = Font::FreeType.new.face($file);

    say "Path: $file";
    my $bname = $path.IO.basename;

    say "  Basename: ", $bname;
    say "  Family name: ", $face.family-name;
    say "  Style name: ", $_
        with $face.style-name;
    say "  PostScript name: ", $_
        with $face.postscript-name;
    say "  Format: ", $_
        with $face.font-format;

    # properties
    my @properties;
    @properties.push: '  Bold' if $face.is-bold;
    @properties.push: '  Italic' if $face.is-italic;
    say @properties.join: '  ' if @properties;
    @properties = ();
    @properties.push: 'Scalable'    if $face.is-scalable;
    @properties.push: 'Fixed width' if $face.is-fixed-width;
    @properties.push: 'Kerning'     if $face.has-kerning;
    @properties.push: 'Glyph names' ~
                      ($face.has-reliable-glyph-names ?? '' !! ' (unreliable)')
      if $face.has-glyph-names;
    @properties.push: 'SFNT'        if $face.is-sfnt;
    @properties.push: 'Horizontal'  if $face.has-horizontal-metrics;
    @properties.push: 'Vertical'    if $face.has-vertical-metrics;
    with $face.charmap {
        @properties.push: 'enc:' ~ .key.subst(/^FT_ENCODING_/, '').lc
            with .encoding;
    }
    #say @properties.join: '  ' if @properties;
    my $prop = @properties.join(' ');
    say "  $prop";

    say "  Units per em: ", $face.units-per-EM if $face.units-per-EM;
    if $face.is-scalable {
        with $face.bounding-box -> $bb {
            say sprintf('  Global BBox: (%d,%d):(%d,%d)',
                        <x-min y-min x-max y-max>.map({ $bb."$_"() }) );
        }
        say "  Ascent: ", $face.ascender;
        say "  Descent: ", $face.descender;
        say "  Text height: ", $face.height;
    }
    say "  Number of glyphs: ", $face.num-glyphs;
    say "  Number of faces: ", $face.num-faces
      if $face.num-faces > 1;
    if $face.fixed-sizes {
        say "  Fixed sizes:";
        for $face.fixed-sizes -> $size {
            say "    ",
            <size width height x-res y-res>\
                .grep({ $size."$_"(:dpi)})\
                .map({ sprintf "$_ %g", $size."$_"(:dpi) })\
                .join: ", ";
        }
    }
}

sub hex2dec(
    $hex, 
    :$debug
    ) is export {
    # converts an input hex sring to a decimal number
    my $dec = parse-base $hex, 16;
    $dec;
}

sub X(
    $font-file,
    :$text is copy,
    :$size,
    :$nglyphs = 0,
    :$width!,      #= max length of a line of text of font F and size S
    :$debug,
    --> Str        #= with line breaks per input params
    ) is export {
}

sub pdf-font-samples(
    # given a list of font files and a text string
    # prints PDF pages in the given font sizes
    @fonts,
    :$text is copy,           #= if not defined, use glyphs in sequence from 100
    :$ngyphs = 0,             #= use a number > 0 to limit num of glyphs shown
    :$size  = 12,
    :$media = 'Letter',
    :$orientation = 'portrait',
    :$margins = 72,
    :$ofil = "font-samples.pdf",
    :$debug,
    ) is export {

    if not $text.defined {
    }

    # start the document
    my $pdf  = PDF::Lite.new;
    if $media.contains( 'let', :i) {
        $pdf.media-box = (0, 0, 8.5*72, 11.0*72);
    }
    else {
        # A4 w x h = 210 mm x 297 mm
        # 25.4 mm per inch
        $pdf.media-box = (0, 0, 210 / 25.4 * 72, 297 / 25.4 * 72);
    }

    my $page;
    my $next-font-index = 0;

    # print the pages(s)
    while $next-font-index < @fonts.elems {
        $page = $pdf.add-page;
        $page.media-box = $pdf.media-box;
        $next-font-index = make-page $next-font-index, @fonts,
           :$page, :$size, :$orientation, :$margins, :$debug;
    }


} # sub pdf-font-samples

sub make-page(
              $next-font-index is copy,
              @fonts,
              PDF::Lite::Page :$page!,
              :$size,
              :$orientation,
              :$margins,
              :$debug,
              --> UInt
) is export {
    # we must keep track of how many fonts were shown
    # on the page and return a suitable reference

    # some references 
    my ($ulx, $uly, $pwidth, $pheight);

    =begin comment
    my $up = $font.underlne-position;
    my $ut = $font.underlne-thickness;
    note "Underline position:  $up";
    note "Underline thickness: $ut";
    =end comment

    # portrait is default
    # use the page media-box
    $pwidth  = $page.media-box[2];
    $pheight = $page.media-box[3];
    if $orientation.contains('land', :i) {
        # need a transformation
        die "FATAL: Tom, fix this";
        return
        $pwidth  = $page.media-box[3];
        $pheight = $page.media-box[2];
    }
    $ulx = 0;
    $uly = $pheight;

    my (@bbox, @position);

=begin comment
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

#        =begin comment
#        # TODO file bug report: @bbox does NOT recognize results of
#        #   :align (and probably :valign)
#        # y positions are correct, must adjust x left by 1/2 width
#        .MoveTo(@bbox[0], @bbox[1]);
#        .LineTo(@bbox[2], @bbox[1]);
#        =end comment
        my $bwidth = @bbox[2] - @bbox[0];
        my $bxL = @bbox[0] - 0.5 * $bwidth;
        my $bxR = $bxL + $bwidth;

#        =begin comment
#        # wait until underline can be centered easily
#
#        # underline the title
#        # underline thickness, from docfont
#        my $ut = $sm.underline-thickness; # 0.703125;
#        # underline position, from docfont
#        my $up = $sm.underline-position; # -0.664064;
#        .Save;
#        .SetStrokeGray(0);
#        .SetLineWidth($ut);
#        # y positions are correct, must adjust x left by 1/2 width
#        .MoveTo($bxL, $y + $up);
#        .LineTo($bxR, $y + $up);
#        .CloseStroke;
#        .Restore;
#        =end comment

        # show the text font value
        $y -= 2* $dh;

        $y -= 2* $dh;

        for %h.keys.sort -> $k {
            my $country-code = $k.uc;
            my $lang = %h{$k}<lang>;
            my $text = %h{$k}<text>;

#            =begin comment
#            @position = [$x, $y];
#            my $words = qq:to/HERE/;
#            -------------------------
#              Country code: {$k.uc}
#                  Language: $lang
#                  Text:     $text
#            -------------------------
#            =end comment

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
=end comment

    $next-font-index;

} # sub make-page

sub rescale(
    $font,
    :$debug,
    --> Numeric
    ) is export {
    # Given a font object with its size setting (.size) and a string of text you
    # want to be an actual height X, returns the calculated setting
    # size to achieve that top bearing.
} # sub rescale(


sub write-line(
    $page,
    :$font!,  # DocFont object
    :$text!,
    :$x!, :$y!,
    :$align = "left", # left, right, center
    :$valign = "baseline", # baseline, top, bottom
    :$debug,
) is export {

    $page.text: -> $txt {
        $txt.font = $font.font, $font.size;
        $txt.text-position = [$x, $y];
        # collect bounding box info:
        my ($x0, $y0, $x1, $y1) = $txt.say: $text, :$align, :kern;
        # bearings from baseline origin:
        my $tb = $y1 - $y;
        my $bb = $y0 - $y;
        my $lb = $x0 - $x;
	my $rb = $x1 - $x;
        my $width  = $rb - $lb;
        my $height = $tb - $bb;
        if $debug {
            say "bbox: llx, lly, urx, ury = $x0, $y0, $x1, $y1";
            say " width, height = $width, $height";
            say " lb, rb, tb, bb = $lb, $rb, $tb, $bb";
        }
    }
} # sub write-line

sub dec2string($declist, :$debug --> Str) is export {
    # Given a list of space-separated decimal code points, convert 
    # them to a string representation.
    my @list;
    if $declist ~~ Str {
        @list = $declist.words;
    }
    else {
        @list = @($declist);
    }
    my $s = "";
    NUM: for @list -> $dec {
        say "DEBUG: dec '$dec'" if $debug;
        if $dec.contains('-') {
            # it's a range
            my @ends = $dec.split('-');
            my $a = @ends.head.Int;
            my $b = @ends.tail.Int;
            say "DEBUG: range: $a .. $b" if $debug;
            for $a..$b {
                say "char decimal value '$_'" if 0 or $debug;
                # get its hex value
                #my $hex = $_.base(16);
                # get its char
                my $c = $_.chr;
                say "   its character: '$c'" if 0 or $debug;
                $s ~= $c
            }
            next NUM;
        }
 
        say "char decimal value '$dec'" if $debug;
        # get its char
        my $c = $dec.chr;
        say "   its character: '$c'" if $debug;
        $s ~= $c
    }
    $s

} # sub dec2string

sub hex2string($hexlist, :$debug --> Str) is export {
    # Given a list of space-separated hexadecimal code points, convert 
    # them to a string representation.
    my @list;
    if $hexlist ~~ Str {
        @list = $hexlist.words;
    }
    else {
        @list = @($hexlist);
    }
    my $s = "";
    NUM: for @list -> $hex {
        say "DEBUG: hex '$hex'" if $debug;
        if $hex.contains('-') {
            # it's a range
            # careful, have to convert the range to decimal
            my @ends = $hex.split('-');
            my $a = @ends.head;
            my $b = @ends.tail;
            # convert from hex to decimal
            my $aa = parse-base "$a", 16;
            my $bb = parse-base "$b", 16;
            note "DEBUG: range hex: '$a' .. '$b'" if $debug;
            note "DEBUG: range dec: '$aa' .. '$bb'" if $debug;
            for $aa..$bb {
                say "char decimal value '$_'" if 0 or $debug;
                # get its char
                my $c = $_.chr;
                say "   its character: '$c'" if 0 or $debug;
                $s ~= $c;
            }
            next NUM;
        }

        say "char hex value '$hex'" if $debug;
        # convert from hex to decimal
        my $x = parse-base "$hex", 16;
        # get its char
        my $c = $x.chr;
        say "   its character: '$c'" if $debug;
        $s ~= $c
    }
    $s
} # sub hex2string


sub find-local-font {
    # TODO awaiting working 'rak'
    # my $f = 
}

sub deg2rad($degrees) {
    $degrees * pi / 180
}
sub rad2deg($radians) {
    $radians * 180 / pi
}

our &draw-box-clip = &draw-rectangle-clip;
sub draw-rectangle-clip(
    :$llx!,
    :$lly!,
    :$width!,
    :$height!,
    :$page!,
    :$stroke-color = (color Black),
    :$fill-color   = (color White),
    :$linewidth = 0,
    :$fill is copy,
    :$stroke is copy,
    :$clip is copy,
    :$debug,
    ) is export {

    $fill   = 0 if not $fill.defined;
    $stroke = 0 if not $stroke.defined;
    $clip   = 0 if not $clip.defined;
    # what if none are defined?
    if $clip {
        # MUST NOT TRANSFORM OR TRANSLATE
        ($fill, $stroke) = 0, 0;
    }
    else {
        # make stroke the default
        $stroke = 1 if not ($fill or $stroke);
    }
    if $debug {
        say "   Drawing a circle...";
        if $fill {
            say "     Filling with color $fill-color...";
        }
        if $stroke {
            say "     Stroking with color $stroke-color...";
        }
        if $clip {
            say "     Clipping the circle";
        }
        else {
            say "     NOT clipping the circle";
        }
    }
    my $g = $page.gfx;
    $g.Save if not $clip; # CRITICAL
    # NO translation
    if not $clip {
        $g.SetLineWidth: $linewidth;
        $g.StrokeColor = $stroke-color;
        $g.FillColor   = $fill-color;
    }
    # draw the path
    $g.MoveTo: $llx, $lly;
    $g.LineTo: $llx+$width, $lly;
    $g.LineTo: $llx+$width, $lly+$height;
    $g.LineTo: $llx       , $lly+$height;
    $g.ClosePath;
    if not $clip {
        if $fill and $stroke {
            $g.FillStroke;
        }
        elsif $fill {
            $g.Fill;
        }
        elsif $stroke {
            $g.Stroke;
        }
        else {
            die "FATAL: Unknown drawing status";
        }
        $g.Restore;
    }
    else {
        $g.Clip;
        $g.EndPath;
    }

} # sub draw-rectangle-clip

sub find-local-font-file(
    :$debug,
    ) is export {

    # Find the first installed font file in the
    # local file system for and example use.
    use paths;
    my $font-file = 0;
    my @dirs  = </usr/share/fonts /Users ~/Library/Fonts>;
    for @dirs -> $dir {
        for paths($dir) -> $path {
            # take the first of the set of known types handled by PDF 
            # libraries (in order of preference)
            if $path ~~ /:i otf|ttf|woff|pfb $/ {
                $font-file = $path;
                say "Font file: $path" if $debug;
                last;
            }
        }
    }
    if not $font-file {
        note "WARNING: No suitable font file was found."
    }
    $font-file
}

sub text-box(
    $text = "",
    :$font!, # fontobj from PDF::Font::Loader
    :$font-size = 12,
    # optional args with defaults
    :$squish = False,
    :$kern = True,
    :$align = <left>, # center, right, justify, start, end
    :$valign = <bottom>, # top, center, bottom
    :$width = 8.5*72,  # default is Letter width in portrait orientation
    :$height = 11*72,  # default is Letter height in portrait orientation
    :$indent = 0;
    :$verbatim = False,
    # optional args that depend on definedness
    :$bidi,
    
) is export {
    my PDF::Content::Text::Box $tb .= new:
        :$text,
        :$font, :$font-size, :$kern, # <== note font information is rw
        :$squish, :$valign,
        :$align, :$width, :$height,
        :$indent,
        :$verbatim, 
    ;
    # the text box object has these rw attributes:
    #   constrain-height
    #   constrain-width
    #   
    $tb
}

sub print-text-box(
    # text-box
    $x is copy, $y is copy,
    :$text!,
    :$page!,
    # defaults
    :$font-size = 12,
    :$fnt = "t", # key to %fonts, value is the loaded font
    # optional constraints
    :$width,
    :$height,
    ) is export {

    # A text-box is resusable with new text only. All other
    # attributes are rw but font and font-size are fixed.

} # sub print-text-box

sub print-text-line(
    ) is export {

    =begin comment
    $page.graphics: {
        my $gb = "GBUMC";
        my $tx = $cx;
        my $ty = $cy + ($height * 0.5) - $line1Y;
        .transform: :translate($tx, $ty); # where $x/$y is the desired reference point
        .FillColor = color White; #rgb(0, 0, 0); # color Black
        .font = %fonts<hb>, #.core-font('HelveticaBold'),
                 $line1size; # the size
        .print: $gb, :align<center>, :valign<center>;
    }
    =end comment

} # print-text-line

=finish

# to be exported when the new repo is created
sub help is export {
	print qq:to/HERE/;
Usage: {$*PROGRAM.basename} <mode>

	       Modes:
	       a - all
	       p - print PDF of font samples
	       d - download example programs
	       L - download licenses
	       s - show /resources contents
	       HERE
	       exit
}

sub with-args(@args) is export {
	for @args {
when /:i a / {
	       exec-d;
	       exec-p;
	       exec-L;
	       exec-s;
       }
when /:i d / {
	       exec-d
       }
when /:i p / {
	       exec-p
       }
when /:i L / {
	       exec-L
       }
when /:i s / {
	       exec-s
       }
       default {
	       say "ERROR: Unknown arg '$_'";
       }
	}
}

# local subs, non-exported
sub exec-d() {
	say "Downloading example programs...";
}
sub exec-p() {
	say "Downloading a PDF with font samples...";
}
sub exec-L() {
	say "Downloading font licenses...";
}
sub exec-s() {
	say "List of /resources:";
	my %h = get-resources-hash;
	my %m = get-meta-hash;
	my @arr = @(%m<resources>);
	for @arr.sort -> $k {
		say "  $k";
	}
}
