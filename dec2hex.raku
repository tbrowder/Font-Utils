#!/usr/bin/env raku

my $d = @*ARGS.head;

my $h = dec2hex $d.UInt;
say "decimal:     $d";
say "hexadecimal: $h";

sub dec2hex(
    UInt $dec is copy,
    :$my, # use my method

    :$debug
    --> Str
    ) is export {
    my $hex = "";
    
    unless $my {
        return $dec.base: 16;
    }

    while $dec > 0 {

        my $q = $dec div 16;
        my $r = $dec mod 16;
        $dec = $q;

        # remainder should be < 16
        die "FATAL: remainder is > 15, '$r'" if $r > 15;
        if $r == 10 {
            $r = 'A';
        }
        elsif $r == 11 {
            $r = 'B';
        }
        elsif $r == 12 {
            $r = 'C';
        }
        elsif $r == 13 {
            $r = 'D';
        }
        elsif $r == 14 {
            $r = 'E';
        }
        elsif $r == 15 {
            $r = 'F';
        }
        else {
            $r = $r.Str;
        }

        $hex = $hex ~ $r;
       
        #my $h = $r.parse-base(16).chr;
    }
    $hex
}


