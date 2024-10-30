unit module Font::Utils;

use QueryOS;
use Font::FreeType;
use Font::FreeType::Glyph;
use File::Find;
use Text::Utils :strip-comment;
use Bin::Utils;

my $o = OS.new;
my $onam = $o.name;

# list of font file directories of primary
# interest on Debian (and Ubuntu)
our @fdirs is export;
with $onam {
    when /:i deb|ubu / {
        @fdirs = <
            /usr/share/fonts/opentype/freefont
            /usr/share/fonts/opentype/urw-base35
            /usr/share/fonts/opentype/ebgaramond
        >
    }
    default {
        die "FATAL: Unknown OS name: '$_'. Please file an issue."
    }
}

sub help() is export {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <mode> [...options...]

    Creates various font-related files based on the user's OS
    (recognized operating systems: Debian, Ubuntu, MacOS, Windows.
    This OS is '$onam'.

    Modes:
      show   - Show details of font files on STDOUT
      create - Create master lists for generating font data hashes and
               classes for a set of font directories
       
    Options:
      dir=X  - Where X is the desired font directory for investigation
    HERE
    exit;
}

# options
my $Rshow   = 0;
my $Rcreate = 0;
my $debug   = 0;
my $dir;

sub use-args(@*ARGS) is export {
    for @*ARGS {
        when /^ :i s / {
            ++$Rshow;
        }
        when /^ :i c / {
            ++$Rcreate;
        }
        when /^ :i 'dir=' (\S+) / {
            my $s = ~$0; # must be a directory
            if $s.IO.d {
                $dir = $s;
            }
            else {
                die qq:to/HERE/;
                FATAL: Unknown directory '$s'
                HERE
            }
        }
        when /^ :i d / {
            ++$debug;
        }
        default {
            die "FATAL: Uknown arg '$_'";
        }
    }

    if $debug {
        say "DEBUG is on";
    }

    if $Rcreate {
        my @dirs;
        if $dir.defined {
            @dirs.push: $dir;
        }
        else {
            @dirs = @fdirs;
        }

        for @dirs -> $dir {
            # need a name for the collection
            my $prefix = "Other";
            with $dir {
                when /:i freefont / {
                    $prefix = "FreeFonts";
                }
                when /:i urw / {
                    $prefix = "URW-Fonts";
                }
            }
            my $jnam = "$prefix.json";

            my @fils = find :$dir, :type<file>, :name(/:i '.' [o|t] tf $/);
            for @fils {
                my %h;
                %h<font-dir> = $dir;
                get-font-info $_, :%h, :$debug;
                if $debug {
                    say "DEBUG: \%h.gist:";
                    say %h.gist;
                    say "debug early exit"; exit;
           
                }
            }
        }
        exit;
    }

    if $Rshow {
        my @dirs;
        if $dir.defined {
            @dirs.push: $dir;
        }
        else {
            @dirs = @fdirs;
        }

        for @dirs -> $dir {
            my @fils = find :$dir, :type<file>, :name(/:i '.' [o|t] tf $/);
            for @fils {
                show-font-info $_, :$debug;
            }
        }
        exit;
    }
}

sub get-font-info($path, :%h!, :$debug) is export {
    my $filename = $path.Str; # David's sub REQUIRES a Str for the $filename
    my $face = Font::FreeType.new.face($filename);

    %h<basename>        = $path.IO.basename;
    %h<family-name>     = $face.family-name;
    %h<style-name>      = $face.style-name;
    %h<postscript-name> = $face.postscript-name;
    %h<is-bold>         = 1 if $face.is-bold;
    %h<is-italic>       = 1 if $face.is-italic;
    %h<font-format> = $face.font-format;

    if 1 or $debug {
        my $bi = 0;
        my $b  = 0;
        my $i  = 0;
        if %h<is-bold>:exists {
            $bi = 1;
            $b  = 1;
        }
        if %h<is-italic>:exists {
            $bi = 1;
            $i  = 1;
        }
        say "PS name: ", %h<postscript-name>;
        if $bi {
            say "  is-bold"   if $b;
            say "  is-italic" if $i;
        }

    }

}

sub show-font-info($path, :$debug) is export {
    my $filename = $path.Str; # David's sub REQUIRES a Str for the $filename
    my $face = Font::FreeType.new.face($filename);

    say "Path: $filename";
    my $bname = $path.IO.basename;
   
    say "  Basename: ", $bname;
    say "  Family name: ", $face.family-name;
    say "  Style name: ", $_
        with $face.style-name;
    say "  PostScript name: ", $_
        with $face.postscript-name;
    say "  Format: ", $_
        with $face.font-format;

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
