use Test;

use PDF::Font::Loader;
use PDF::Content;

use Font::Utils;
use Font::Utils::Misc;

my $debug = 0;
my ($f1, $f2);

# test the user fonts insertion and access
is 1, 1;

$f1 = load-font-at-key 1;
isa-ok $f1, PDF::Content::FontObj;
$f2 = load-font-at-key 1;
isa-ok $f2, PDF::Content::FontObj;

done-testing;
