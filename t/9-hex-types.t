use Test;

#use Font::Utils;
#use Font::Utils::Misc;
my $debug = 0;

subset HexStr of Str is export where { $_ ~~ 
    /^ 
        <[0..9a..fA..F]>+ 
    $/ 
}

subset HexStrRange of Str is export where { $_ ~~ 
    /^ 
        <[0..9a..fA..F]>+ '-' <[0..9a..fA..F]>+ 
    $/ 
}

subset HexStrRangeWords of Str is export where { $_ ~~ 
    /^ 
        \h*  # optional leading whitespace
             # interleaving HexStrRange and HexStr types
             # first instance is required
             [ [<[0..9a..fA..F]>+ '-' <[0..9a..fA..F]>+] | [<[0..9a..fA..F]>+] ]
    
             # following instances are optional
             [
               \h+ [ [<[0..9a..fA..F]>+ '-' <[0..9a..fA..F]>+] | [<[0..9a..fA..F]>+] ]
             ]?

        \h*  # optional trailing whitespace
    $/ 
}

my $s1 = "0a";
my $s2 = "0a-0d";
my $s3 = "0a-0d ";
my $s4 = "0a-0d f";

isa-ok $s1, HexStr, "HS input: |$s1|";
isa-ok $s2, HexStrRange, "HSR input: |$s2|";
nok ($s3 ~~ HexStrRange), "HSR input: |$s3|";
isa-ok $s4, HexStrRangeWords, "HSRW input: |$s4|";

done-testing;
