unit module Font::Utils::Subs;

use Font::Utils::Misc;

sub HexStr2Char(
    HexStr $hstr,
    :$debug
    --> Str
) is export {
    my $dec = hex2dec $hstr;
    $dec.chr;
}

sub dec2string(
    UInt $dec,
    :$debug,
    --> Str
) is export {
    $dec.chr;
}

sub hex2string(
    HexStr $hstr,
    :$debug
    --> Str
) is export {
    my $dec = hex2dec $hstr;
    $dec.chr;
}

sub is-font-file(
    $file,
    :$debug,
    --> Bool
    ) is export {
    # just a name check for now
    my $res = False;
    if $file ~~ /:i '.' [otf|ttf|pfb] $/ {
        $res = True;
    }
    $res
}

sub dec2hex(
    $dec,
    :$debug
    --> HexStr
    ) is export {
    $dec.base: 16;
}

sub hex2dec(
    HexStr $hex,
    :$debug,
    --> UInt
    ) is export {
    # converts an input hex string
    # to a decimal number
    parse-base $hex, 16;
}

sub in2ps($in) is export {
    $in * 72
}

sub in2cm($in) is export {
    $in * 2.54
}

sub cm2in($cm) is export {
    $cm / 2.54
}

sub cm2ps($cm) is export {
    cm2in($cm) * 72
}

sub deg2rad($degrees) is export {
    $degrees * pi / 180
}

sub rad2deg($radians) is export {
    $radians * 180 / pi
}
