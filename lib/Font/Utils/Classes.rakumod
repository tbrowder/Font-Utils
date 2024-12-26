unit module Font::Utils::Classes;

use Font::Utils::Misc;
use Font::Utils::Subs;

use OO::Monitors;

my $debug = 0;

our monitor Ignore is export {
    has UInt @.ignored;
    has UInt @.vignored;

    multi method insert-ignored(UInt $ord) {
        @.ignored.push: $ord;
    }
    multi method insert-ignored(HexStr $hex) {
        # convert to UInt
        my $ord = hex2dec $hex;
        @.ignored.push: $ord;
    }

    # do same for vignored
    multi method insert-vignored(UInt $ord) {
        @.vignored.push: $ord;
    }
    multi method insert-vignored(HexStr $hex) {
        # convert to UInt
        my $ord = hex2dec $hex;
        @.vignored.push: $ord;
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
