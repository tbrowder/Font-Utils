use Test;

use File::Temp;

use Font::Utils;

use lib "./t";
use MyTestHelpers;

my $debug = 1;
my $tdir = $debug ?? mkdir("./test-dir") !! tempdir

my @tmpfils; # files to clean before and after
BEGIN {
@tmpfils = <
    permasc
    good.asc good2.asc good3.asc
    good.ps  good2.ps  good3.ps
      good.ps~ good2.ps~ good3.ps~
    good.pdf good2.pdf good3.pdf
>;
} # BEGIN
INIT { unless $debug { for @tmpfils { unlink $_ if $_.IO.f; } } }
END  { unless $debug { for @tmpfils { unlink $_ if $_.IO.f; } } }

my ($s1, $s2, $c1, $c2, @gchars, @words);

# create some known good ASCII files to start
# NOTE pdf files MUST have some text line(s)
my $perm-asc = "perma.asc".IO;
make-ascii-file $perm-asc;
isa-ok $perm-asc, IO::Path;

my $good-asc = "good.asc".IO;
make-ascii-file $good-asc;
isa-ok $good-asc, IO::Path;

my $good-ps = "good.ps".IO;
shell "a2ps -o '$good-ps' '$good-asc'";
isa-ok $good-ps, IO::Path;

shell "ps2pdf $good-ps";
my $good-pdf = "good.pdf".IO;
isa-ok $good-pdf, IO::Path;

#==================================
# test turning a text file into a PostScript file (.ps)
#   first the default
my $good2-asc = "good2.asc".IO;
copy $good-asc, $good2-asc;
isa-ok $good-asc, IO::Path;

my $good2-ps;
lives-ok {
    $good2-ps = asc2ps $good2-asc, :force;
}, "test 1, running asc2ps on file '$good2-asc'";
# expected output: "good2.ps";
is $good2-ps, "good2.ps";
isa-ok $good2-ps, IO::Path, "asc2ps: in: '$good2-asc', out: '$good2-ps'";

#   then try to overwrite an existing file
my $force = 1;
lives-ok {
    die unless $good2-ps.defined;
    asc2ps $good2-asc, :force;
}, "test 2, running asc2ps on file '$good2-asc'";

#   then a non-file
my $nofile = "some-string";
my $ps;
dies-ok {
     $ps = asc2ps $nofile;
}, "test 3, running asc2ps on file '$nofile'";

#==================================
# test ps2pdf
$ps = $nofile;
my $pdf0;
dies-ok {
     $pdf0 = ps2pdf $nofile;
}, "test 4, running ps2pdf '$nofile'";

# on an existing ps file
my $pdf;
lives-ok {
    $pdf = ps2pdf $good-ps, :force;
}
isa-ok $pdf, IO::Path;

# on an existing pdf file without force
die unless $pdf.defined;
dies-ok {
    $pdf = ps2pdf $good-ps;
}

# on an existing pdf file WITH force
lives-ok {
    $pdf = ps2pdf $good-ps, :force;
}
isa-ok $pdf, IO::Path;

#==================================
# test pdf2pdf
my $pdfout = "$tdir/pdfout.pdf"; # just a name
my $pdfin = $pdf; # known good;

# write to another pdf file
my $pdfout4 = "$tdir/file4.pdf"; #.IO;
dies-ok {
    pdf2pdf $pdfin, $pdfout4;
}, "running pdf2pdf on '$pdfin', out: '$pdfout4'";

# write to another pdf file
dies-ok {
    pdf2pdf $pdfin, $pdfout;
}, "running pdf2pdf on '$pdf'";

# attempt to overwrite the input file
# without force=true
dies-ok {
    pdf2pdf $pdfin;
}, "running pdf2pdf on '$pdfin'";

# overwrite the input file with Force=true
my $pdftest = "$tdir/pdftest.pdf".IO;
lives-ok {
    pdf2pdf $pdftest, :force;
}, "running pdf2pdf on '$pdftest'";
isa-ok $pdfin, IO::Path;
ok file-isa-pdf($pdftest);

done-testing; exit;
