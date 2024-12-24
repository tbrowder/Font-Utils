use Test;

use Font::Utils;

my $debug = 0;

# test the various modes
my ($p, $proc, $out, $err);

$proc = run "bin/* list", :$out;

done-testing;
