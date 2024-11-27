#!/usr/bin/env raku

my $d = @*ARGS.head;

my $h = dec2hex $d.UInt;
say "decimal:     $d";
say "hexadecimal: $h";

sub dec2hex(
    UInt $dec is copy,

    :$debug
    --> Str
    ) is export {
    my $hex = "";
    while $dec > 0 {

        my $q = $dec div 16;
        my $r = $dec mod 16;
        $dec = $q;

        # remainder should be < 16
        $r = $r.Str;
        $hex = $hex ~ $r;
       
        #my $h = $r.parse-base(16).chr;
    }
    $hex
}


