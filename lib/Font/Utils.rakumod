unit module Font::Utils;

=begin comment
# freefont locations by OS
my $Ld = "/usr/share/fonts/opentype/freefont";

my $Md = "/opt/homebrew/Caskroom/font-freefont/20120503/freefont-20120503";
my $Wd = "/usr/share/fonts/opentype/freefont";
=end comment

use QueryOS;
use Font::FreeType;
use Font::FreeType::Glyph;
use File::Find;
use Text::Utils :strip-comment;
use Bin::Utils;
use YAMLish;
use PDF::Lite;

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
    @properties.push: 'SFNT'        if $face.is-sfnt;
    @properties.push: 'Horizontal'  if $face.has-horizontal-metrics;
    @properties.push: 'Vertical'    if $face.has-vertical-metrics;
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

    Modes:
      list   - List family and font names in a font file
      show   - Show details of font files
      sample - Create a PDF document showing samples of
                 selected fonts
    Options:

    HERE
    exit;
}

# options
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
            die "FATAL: Uknown mode '$_'";
        }
    }

    # remaining args are a mixed bag
    my @dirs; 
    my @fils; 
    my %opts;

    for @args {
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

        exit;
    }
}

sub get-font-info(
    $path, 
    :$debug 
    --> FreeTypeFace) is export {

    my $file = $path.Str; # David's sub REQUIRES a Str for the $filename
    my $o = FreeTypeFace.new: :$file;
}

sub show-font-info($path, :$debug) is export {
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

sub hex2dec($hex, :$debug) is export {
    # converts an input hex sring to a decimal number
    my $dec = parse-base $hex, 16;
    $dec;
}

sub pdf-font-samples(
    # given a list of font files and a text string
    # prints PDF pages in the given font sizes
    @fonts,
    :$text!,
    :$size  = 12,
    :$media = 'Letter',
    :$orientation = 'portrait',
    :$margins = 72,
    :$debug,
    ) is export {
} # sub pdf-font-samples

sub make-page(
              PDF::Lite :$pdf!,
              PDF::Lite::Page :$page!,
              :$font!,
              :$font-size = 10,
              :$title-font!,
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
    $cx = 0.5 * ($page.media-box[2] - $page.media-box[0]);
    $cy = 0.5 * ($page.media-box[3] - $page.media-box[1]);

    if not $landscape {
        die "FATAL: Tom, fix this";
        return
    }

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


sub to-string($cplist, :$debug --> Str) is export {
    # Given a list of hex codepoints, convert them to a string repr
    # the first item in the list may be a string label
    my @list;
    if $cplist ~~ Str {
        @list = $cplist.words;
    }
    else {
        @list = @($cplist);
    }
    if @list.head ~~ Str { @list.shift };
    my $s = "";
    for @list -> $cpair {
        say "char pair '$cpair'" if $debug;
        # convert from hex to decimal
        my $x = parse-base $cpair, 16;
        # get its char
        my $c = $x.chr;
        say "   its character: '$c'" if $debug;
        $s ~= $c
    }
    $s
} # sub to-string($cplist, :$debug --> Str) is export {


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
