use OO::Monitors;

#unit class Font::Utils::FaceFreeType;
unit monitor Font::Utils::FaceFreeType;

#class FreeTypeFace is export {

use PDF::Font::Loader :load-font;

use Font::FreeType;
use Font::FreeType::SizeMetrics;  # size-metrics object

has PDF::Content::FontObj $.font is required; # a loaded font
has $.font-size is required; #  = 12; # not yet required;
has $.file is required;

# special use for URW fonts with wierd PostScript nakes
# default is the PostScript name
has $.adobe-name is rw = "";

has $.face;
has Font::FreeType::SizeMetrics $.sm;  # size-metrics object

submethod TWEAK {
    =begin comment
    $p    = $!file;
    if not $p.IO.e {
        die "FATAL: '$p' is not a file path";
    }
    $p    = $!font.file;
    =end comment
    $!face = $!font.face; # Font::FreeType.new.face: $!file.Str;
    $!face.set-char-size: $!font-size;
    $!sm = $!face.scaled-metrics;
}

#    method set-font-size(Numeric $size) {
#        $face.set-char-size: $size;
#        $sm = $face.scaled-metrics;
#    }

# methods from $size-metrics
method ascender {
    $!sm.ascender
}
method descender {
    $!sm.descender
}
method max-advance-width {
    $!sm.max-advance-width
}


# other methods
method adobe-name {
    $!adobe-name ?? $!adobe-name !! $!face.postscript-name;
}

method basename             { $!file.IO.basename        }


method rawname {
    # basename without a suffix
    my $rname = self.basename;
    $rname ~~ s:i/'.' [otf|ttf|pfb] $//;
    # sanity check
    if $rname.contains('.') {
        die qq:to/HERE/;
        FATAL: Unexpected font file with multiple periods
                          in its basename. Please file an issue.
        HERE
    }
    $rname;
}

method family-name          { $!face.family-name     }
method style-name           { $!face.style-name      }
method postscript-name      { $!face.postscript-name }
method font-format          { $!face.font-format     }
method num-glyphs           { $!face.num-glyphs      }
method bbox                 { $!face.bbox            }
#method height               { $!face.height          }
method height               { $!sm.height          }
#method leading              { $!face.height          } # alias
method leading              { $!sm.height          } # alias

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

method top-bearing(Str $s) {
    my $y = 0;
    $!face.for-glyphs($s, {
        my $t = .top-bearing;
        $y = $t if $t > $y;
    });
    $y
}

method bottom-bearing(Str $s) {
    my $y = 0;
    $!face.for-glyphs($s, {
        my $h = .height;
        my $t = .top-bearing;
        my $b = $h - $t;
        $y = $b if $b < $y;
    });
    $y
}

method left-bearing(Str $s) {
}
method right-bearing(Str $s) {
}
method string-bbox(Str $s) {
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
