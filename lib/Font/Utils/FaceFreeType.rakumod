use OO::Monitors;

#unit class Font::Utils::FaceFreeType;
unit monitor Font::Utils::FaceFreeType;

use Font::Utils::Misc;
use Font::Utils::Subs;
use Font::Utils::Classes;

use PDF::Content;
use PDF::Font::Loader :load-font;

use Font::FreeType;
use Font::FreeType::SizeMetrics;  # size-metrics object

my $debug = 0;

has PDF::Content::FontObj $.font is required; # a loaded font
has $.font-size is required;

has $.file; # now avail in $font object when loaded

# special use for URW fonts with weird PostScript names
# default is the PostScript name
# if no PostScript name, use file basename (without the file extension: "rawname")
has $.adobe-name is rw = "";
has $.postscript-name is rw = "";

has $.face;
has Font::FreeType::SizeMetrics $.sm;  # size-metrics object
has $.rawname;
has $.basename;

# can turn off width check at object instantiation
has $width-check = True;
# can turn off height check at object instantiation
has $height-check = True;
#=begin comment
has @.ignored is rw;
has @.vignored is rw;
#=end comment
#has Ignore $.ignored;

submethod TWEAK {
    my $debug = 0;
    $!face = $!font.face; # Font::FreeType.new.face: $!file.Str;
    $!face.set-char-size: $!font-size;
    $!sm = $!face.scaled-metrics;
    $!file = $!font.file;
    $!basename = $!file.IO.basename;

    =begin comment
    # by default, create its own list of zero-width and zero-height
    #   code-points to ignore when creating sample pages
    for $!face.cmap {
        say ".cmap: {$_.gist}" if $debug;
        #last unless $width-check or $height-check;
        my $glyph-index = .key;
        # $char is the decimal code point for the glyph:
        #   i.e., $char = .ord
        my $char        = .value;
        my $glyph  = $char.chr; # the Str of the glyph
        my $width  = 0;
        my $height = 0;
        $!face.forall-chars: $glyph, -> $g {
            # $g is the object of the binary glyph
            $width  = $g.width;
            $height = $g.height;
        }
        my $prop        = $char.uniprop;
        my $name        = $char.uniname;
        my $ord         = $char;
        my $hex         = $ord.base(16);
        if $width-check and $width <= 0 {
            @!ignored.push: $ord;
        }
        if $height-check and $height <= 0 {
            @!vignored.push: $ord;
        }
        =begin comment
        say "glyph index: $glyph-index";
        say "       char: $char";
        say "    decimal: $ord";
        say "        hex: $hex";
        say "      width: $width";
        say "    uniname: $name";
        say "    uniprop: $prop";
        if $width == 0 {
            note "WARNING: glyph '$hex' == 0";
        }
        =end comment
        #say $prop;
        #%control-chars{$prop}.push($char.uniname)
        #    if Control-Chars($char.uniprop);
    }
    =end comment

    # create the rawname
    # basename without a suffix
    $!rawname = $!file.IO.basename;
    $!rawname ~~ s:i/'.' \S* $//; # [otf|ttf|pfb] $//;

    =begin comment
    # sanity check
    if $!rawname ~~ /'.'/ {
        die qq:to/HERE/;
        FATAL: Unexpected font file with multiple periods ({$!rawname})
                          in its basename. Please file an issue.
        HERE
    }
    =end comment

    if $!face.postscript-name.defined {
        $!postscript-name = $!face.postscript-name:
    }
    else {
        $!postscript-name = $!rawname;
    }

} # end of TWEAK

#    method set-font-size(Numeric $size) {
#        $face.set-char-size: $size;
#        $sm = $face.scaled-metrics;
#    }

# methods from $size-metrics
method ascender {
    # top of the entire font set of glyphs
    $!sm.ascender
}
method descender {
    # bottom of the entire font set of glyphs
    $!sm.descender
}
method max-advance-width {
    # largest advance-width value of the entire font set of glyphs
    $!sm.max-advance-width
}

method max-advance-height {
    # largest advance-height value of the entire font set of glyphs
    # (for fonts with vertical layouts)
    $!sm.max-advance-height
}

method bbox {
    # bounding box value of the entire font set of glyphs
    $!sm.bbox
}

# other methods
method adobe-name {
    $!adobe-name ?? $!adobe-name !! $!postscript-name;
}

method family-name          { $!face.family-name     }
method style-name           { $!face.style-name      }
method font-format          { $!face.font-format     }
method num-glyphs           { $!face.num-glyphs      }
method height               { $!sm.height            }
method leading              { $!sm.height            } # alias

method is-scalable          { $!face.is-scalable          ?? True !! False }
method is-fixed-width       { $!face.is-fixed-width       ?? True !! False }
method has-kerning          { $!face.has-kerning          ?? True !! False }
method is-bold              { $!face.is-bold              ?? True !! False }
method is-italic            { $!face.is-italic            ?? True !! False }
method is-sfnt              { $!face.is-sfnt              ?? True !! False }
method fixed-sizes          { $!face.fixed-sizes          ?? True !! False }
method scaled-metrics       { $!face.scaled-metrics       ?? True !! False }
method has-vertical-metrics { $!face.has-vertical-metrics ?? True !! False }
method has-glyph-names      { $!face.has-glyph-names      ?? True !! False }

method has-horizontal-metrics   {
    $!face.has-horizontal-metrics   ?? True !! False
}
method has-reliable-glyph-names {
    $!face.has-reliable-glyph-names ?? True !! False
}

method extension {
    my $ext = self.font-format;
    if self.font-format ~~ /:i open / {
        $ext = "otf";
    }
    elsif self.font-format ~~ /:i true / {
        $ext = "ttf";
    }
    elsif self.font-format ~~ /:i type \h+ 1 / {
        $ext = "pfb";
    }
    else {
        # remove spaces
        $ext ~~ s:g/\h//
    }
    $ext
}

#============================
# string methods

#method stringwidth(Str $s, :$font-size = 12) {
method stringwidth2(Str $s) {
    # this is David's version (but with fixed font size)
    # TODO should delete distance of last char bbox and hori-advance
    my $font-size = self.font-size;
    my $units-per-EM = $!face.units-per-EM;
    my $unscaled = sum $!face.for-glyphs($s, {.metrics.hori-advance });
    return $unscaled * $!font-size / $units-per-EM;
}

method stringwidth(Str $s) {
    # this is my version using methods from David's Glyph.rakumod
    # TODO adjust for left- and right-bearings of the bounding glyphs
    my $w = 0;
    $!face.for-glyphs($s, {
        my $x = .horizontal-advance;
        $w += $x;
    });
    $w
}

=begin comment
method get-ignored-object(
    Bool :$decimal
    --> Ignore) {

    my $ig = Ignore.new;

    for $!face.cmap {
        my $glyph-index = .key;
        # $char is the decimal code point for the glyph:
        #   i.e., $char = .ord
        my $char        = .value;
        my $glyph  = $char.chr; # the Str of the glyph
        my $width  = 0;
        my $height = 0;
        $!face.forall-chars: $glyph, -> $g {
            # $g is the object of the binary glyph
            $width  = $g.width;
            $height = $g.height;
        }
        my $prop        = $char.uniprop;
        my $name        = $char.uniname;
        my $ord         = $char;
        my $hex         = $ord.base(16);

        if $width-check and $width == 0 {
            if $decimal {
                @ignored.push: $ord;
            }
            else {
                @ignored.push: $hex;
            }
        }
        if $height-check and $height == 0 {
            if $decimal {
                @ignored.push: $ord;
            }
            else {
                @ignored.push: $hex;
            }
        }

        =begin comment
        say "glyph index: $glyph-index";
        say "       char: $char";
        say "    decimal: $ord";
        say "        hex: $hex";
        say "      width: $width";
        say "    uniname: $name";
        say "    uniprop: $prop";
        if $width == 0 {
            note "WARNING: glyph '$hex' == 0";
        }
        =end comment
    }
    @ignored.unique;

    $ig
}
=end comment


method get-ignored-list(Bool :$show-ord) {
    my @ignored;
    for $!face.cmap {
        my $glyph-index = .key;
        # $char is the decimal code point for the glyph:
        #   i.e., $char = .ord
        my $char        = .value;
        my $glyph  = $char.chr; # the Str of the glyph
        my $width  = 0;
        my $height = 0;
        $!face.forall-chars: $glyph, -> $g {
            # $g is the object of the binary glyph
            $width  = $g.width;
            $height = $g.height;
        }
        my $prop        = $char.uniprop;
        my $name        = $char.uniname;
        my $ord         = $char;
        my $hex         = $ord.base(16);
        if $width-check and $width == 0 {
            if $show-ord { @ignored.push: $ord;
            } else { @ignored.push: $hex; }
        }
        if $height-check and $height == 0 {
            if $show-ord { @ignored.push: $ord; }
            else { @ignored.push: $hex; }
        }
        =begin comment
        say "glyph index: $glyph-index";
        say "       char: $char";
        say "    decimal: $ord";
        say "        hex: $hex";
        say "      width: $width";
        say "    uniname: $name";
        say "    uniprop: $prop";
        if $width == 0 {
            note "WARNING: glyph '$hex' == 0";
        }
        =end comment
    }
    @ignored.unique;
}

method top-bearing(Str $s --> Numeric) {
    my $y = 0;
    for $s.comb -> $g {
        $!face.for-glyphs($g, {
            my $bbox = .bounding-box;
            # get the ury of the bbox
            my $ury   = $bbox[3];
            $y = $ury if $ury > $y;
        });
    }
    $y
}

method bottom-bearing(Str $s --> Numeric) {
    my $y = 0;
    for $s.comb -> $g {
        $!face.for-glyphs($g, {
            my $bbox = .bounding-box;
            # get the lly of the bbox
            my $lly = $bbox[1];
            $y = $lly if $lly < $y;
        });
    }
    $y
}

method left-bearing(Str $s --> Numeric) {
    my $x = 0;
    for $s.comb -> $g {
        $!face.for-glyphs($g, {
            my $bbox = .bounding-box;
            # get the llx of the bbox
            my $llx = $bbox[0];
            $x = $llx if $llx < $x;
        });
    }
    $x
}

method right-bearing(Str $s --> Numeric) {
    my $x = 0;
    for $s.comb -> $g {
        $!face.for-glyphs($g, {
            my $bbox = .bounding-box;
            # get the urx of the bbox
            my $urx = $bbox[2];
            $x = $urx if $urx > $x;
        });
    }
    $x
}

method string-bbox(Str $s --> List) {
    my ($LLX, $LLY, $URX, $URY) = 0, 0, 0, 0;
    for $s.comb -> $g {
        $!face.for-glyphs($g, {
            my $bbox = .bounding-box;
            my $llx = $bbox[0];
            my $lly = $bbox[1];
            $LLX = $llx if $llx < $LLX;
            $LLY = $lly if $lly < $LLY;


            my $urx = $bbox[2];
            my $ury = $bbox[3];
            $URX = $urx if $urx > $URX;
            $URY = $ury if $ury > $URY;
        });
    }
    $LLX, $LLY, $URX, $URY
}

=begin comment
multi method text-box(
    :$text,
    :$debug,
    --> List) {
    # the traditional Text::Box
}
=end comment

method lines-bbox(
    # from PDF::Content::Text::Box method render
    #| render a text box to a content stream at current or given text position
    @lines,
    :$line-height is copy,
    :$debug,
    --> List) {
    # simulates a Text::Box but preserves lines
    # get total width and height
    my $bwidth  = 0;
    my $bheight = 0;
    my $nlines  = @lines.elems;

    unless $line-height.defined {
        $line-height = self.height; #
    }

    for @lines.kv -> $i, $line {
        my $sw = self.stringwidth: $line;
        $bwidth = $sw if $sw > $bwidth;

        # get the height
        my $sh;
        if $i == 0 {
            # use top-bearing
            $sh = self.top-bearing: $line;
            if $nlines == 1 {
                # special case
                my $bb = self.bottom-bearing;
                $sh -= $bb;
            }
        }
        elsif $i == $nlines - 1 {  # the last line
            # use bottom bearing
            $sh = self.bottom-bearing: $line;
        }
        else {
            # use line-hight
            $sh = $line-height;
        }
        $bheight = $sh if $sh > $bheight;
    }
    0, 0, $bwidth, $bheight;
}

#method wrap-string(Str $s, :$font-size!, :$width! --> List) {
method wrap-string(Str $s, :$width! --> List) {
    my @lines; # to hold the $width size pieces
    # all the glyphs
    my @g = $s.comb;

    my $tstr = "";  # temp string for building the shorter lines
    while @g.elems {
        my $c = @g.shift;
        #if self.stringwidth(($tstr ~ $c), :$font-size) <= $width {
        if self.stringwidth($tstr ~ $c) <= $width {
            $tstr ~= $c;
        }
        else {
            @lines.push: $tstr;
            @g.unshift: $c; # so it can be used again
            $tstr = "";
        }
    }
    @lines;
}

=begin comment
# TODO make methods
# properties
with $face.charmap {
    @properties.push: 'enc:' ~ .key.subst(/^FT_ENCODING_/, '').lc
    with .encoding;
=end comment

#} # End of class FaceFreeType
