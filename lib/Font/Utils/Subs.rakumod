unit module Font::Utils::Subs;

use Font::Utils::Misc;

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
