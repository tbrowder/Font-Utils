use Test;

use Font::Utils;
use Font::Utils::Misc;
use Font::Utils::Subs;

my $debug = 0;

is 1, 1;

# Test all ways to convert to and from Unicode to
# chars and strings (mainly for reference)

my $d = 51;
my $h = "a1";
my $ds = dec2string $d;
say "decimal $d is string '$ds'" if $debug;

my $hs = hex2string $h;
say "hexadecimal $h is string '$hs'" if $debug;

done-testing;
