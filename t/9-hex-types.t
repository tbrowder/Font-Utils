use Test;

#use Font::Utils;
use Font::Utils::Misc;

my $debug = 0;

if 1 {
# A single token: no whitespace allowed.
# Ultimately, all HexStrRange objects will
# be converted to a list of HexStr objects.
subset HexStr of Str is export where { $_ ~~
    /^
        <[0..9a..fA..F]>+
    $/
}

# A single token: no whitespace allowed
subset HexStrRange of Str is export where { $_ ~~
    /^
        <[0..9a..fA..F]>+ '-' <[0..9a..fA..F]>+
    $/
}

# One or more tokens in a string, demarked by whitespace.
# The string will be converted to individual HexStrRange and
# HexStr tokens with the .words method.
# Then the entire list will be converted to HexStr tokens.
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
}

my $s1 = "0a";
my $s2 = "0a-0d";
my $s3 = "0a-0d ";
my $s4 = " 0a-0d  f  ";

isa-ok $s1, HexStr, "HS input: |$s1|";
isa-ok $s2, HexStrRange, "HSR input: |$s2|";
nok ($s3 ~~ HexStrRange), "HSR input: |$s3|";
isa-ok $s4, HexStrRangeWords, "HSRW input: |$s4|";

#my HexStr @hexstrs = HexStrRangeWords2HexStr $s4;

done-testing;
