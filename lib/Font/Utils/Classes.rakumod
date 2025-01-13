unit module Font::Utils::Classes;


use Font::Utils::Misc;
use Font::Utils::Subs;

use OO::Monitors;

my $debug = 0;

# From my study of code-point properties, these should be printable
# chars:
my enum PrintChars (
    :P1<Lu>, :P2<Ll>, :P3<Lt>,
    :P4<Nd>, :P5<Nl>, :P6<No>,
    :P7<Pc>, :P8<Pd>, :P9<Ps>, :Pa<Pe>, :Pb<Pi>, :Pc<Pf>, :Pd<Po>,
    :Pe<Sm>, :Pf<Sc>,
);

# And these (from David) we will ignore:
my enum Control-Chars (
        :Control<Cc>,
        :Format<Cf>,
        :Surrogate<Cs>,
        :Private<Co>,
        :Unassigned<Cn>
 );

our monitor Ignore is export {
    use Font::FreeType;
    use Font::FreeType::Face;

    # Note the caller determines whether width or height is inserted

    has $.file is required; # The font file
    has $.width-limit  = True;
    has $.height-limit = True;

    # a list of UInts (the $char.ord value, referred to as $dec here)
    has @.ignored;

    my ($fo, $face, $dec);
    submethod TWEAK {
        $fo   = Font::FreeType.new;
        $face = $fo.face: $!file;
        FACE-CMAP: for $face.cmap {
            say ".cmap: {$_.gist}" if $debug;
            my $glyph-index = .key;
            # David's ($char = .value) yields the decimal code point
            #   i.e., $char = .ord (= $dec)
            my $char  = .value;
            my $glyph = $char.chr; # the Str of the glyph
            my $dec   = $char;
            my $hex   = dec2hex $dec;
            if $hex ~~ /:i A75C / {
                note "XDEBUG: found problem char: 'A75C'";
                say  "XDEBUG: found problem char: 'A75C'";
            }

            # I want only printable glyphs:
            if Control-Chars($char.uniprop) {
                # add it to the array
                note "DEBUG: ignoring hex code point '$hex'" if $debug;
                @!ignored.push: $dec;
                #next FACE-CMAP;
            }

            if not PrintChars($char.uniprop) {
                # add it to the array
                note "DEBUG: ignoring hex code point '$hex'" if $debug;
                @!ignored.push: $dec;
                #next FACE-CMAP;
            }

            #=begin comment
            my $width  = 0;
            my $height = 0;
            $face.forall-chars: $glyph, -> $g {
                # $g is the object of the binary glyph
                $width  = $g.width;
                $height = $g.height;
            }

            if $width == 0 {
                note "DEBUG: ignoring hex code point '$hex'" if $debug;
                @!ignored.push: $dec;
                #next FACE-CMAP;
            }
            if $height == 0 {
                note "DEBUG: ignoring hex code point '$hex'" if $debug;
                @!ignored.push: $dec;
                #next FACE-CMAP;
            }
            #=end comment
            say "DEBUG: printing hex code '$hex'";

            # Double check some other info from Uinicode.org
        }
    }

    =begin comment
    # Not needed now
    # build methods
    multi method insert-ignored(UInt $dec) {
        %.ignored{$dec} = 1;
    }
    multi method insert-ignored(HexStr $hex) {
        # convert to UInt
        my $dec = hex2dec $hex;
        %.ignored{$dec} = 1;
    }
    =end comment

    # interrogation methods
    multi method is-ignored(UInt $dec --> Bool) {
        #%.ignored{$dec}:exists
        $dec (<=) self.ignored
    }
    multi method is-ignored(HexStr $hex --> Bool) {
        # convert to UInt
        my $dec = hex2dec $hex.uc;
        #%.ignored{$dec}:exists
        $dec (<=) self.ignored
    }
}

our monitor Glyph-Row is export {
    has HexStr @.glyphs;
    method insert(HexStr $glyph) {
        note "DEBUG: hex: $glyph" if $debug > 2;
        @.glyphs.push: $glyph;
    }
}

our monitor Section is export {
    has Str  $.title;
    has UInt $.number; # 1...Nsections;
    # hexadecimal repr, number depends on
    # width of glyph-box and page content width
    has Glyph-Row @.glyph-rows;

    method insert(Glyph-Row $glyph-row) {
        self.glyph-rows.push($glyph-row);
    }
}
