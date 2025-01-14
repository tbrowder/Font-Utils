unit module MyTestHelpers;

use File::Temp;

my $tdir = "test-dir";

sub file-isa-ascii(
    IO::Path $path,
    :$debug,
    --> Bool
    ) is export {

    # create a temp file for shell output
    my ($tfil, $fh);
    if $debug {
        $tfil = "$tdir/temp-ascii".IO;
        $fh   =  open $tfil, :w;
    }
    else {
        ($tfil, $fh) = tempfile;
    }
 
    shell "file $path > $tfil";
    my $string = $tfil.IO.slurp; #@lines.join(" ");

    if $string ~~ /:i ascii / {
        return True;
    }
    else {
        return False;
    }
}

sub file-isa-pdf(
    IO::Path $path,
    :$debug,
    --> Bool
    ) is export {

    # create a temp file for shell output
    my ($tfil, $fh);
    if $debug {
        $tfil = "$tdir/temp-pdf".IO;
        $fh   =  open $tfil, :w;
    }
    else {
        ($tfil, $fh) = tempfile;
    }
 
    shell "file $path > $tfil";
    my $res = slurp $tfil;
    if $res ~~ /^:i pdf / {
        return True;
    }
    else {
        return False;
    }
}

sub file-isa-ps(
    IO::Path $path,
    :$debug,
    --> Bool
    ) is export {

    # create a temp file for shell output
    my ($tfil, $fh);
    if $debug {
        $tfil = "$tdir/temp-ps".IO;
        $fh   =  open $tfil, :w;
    }
    else {
        ($tfil, $fh) = tempfile;
    }

    shell "file $path > $tfil";
    my $res = slurp $tfil;
    if $res ~~ /^:i postscript / {
        return True;
    }
    else {
        return False;
    }
}

our &mak-asc-fil is export = &make-ascii-file;
sub make-ascii-file(
    IO::Path $path,
    :$text = "some text",
    :$debug,
    ) is export {
    # creates or overwrites the $path
    my $fh = open $path, :w;
    $fh.say: $text;
    $fh.close;
}

our &mak-psf-fil is export = &make-ps-file;
sub make-ps-file(
    IO::Path $path,
    :$text = "some text",
    :$debug,
    ) is export {

    # create a temp ascii file
    my ($ascii-file, $fh);
    if $debug {
        $ascii-file = "$tdir/temp-asc".IO;
        $fh   =  open $ascii-file, :w;
        $fh.say: $text;
        $fh.close;
    }
    else {
        ($ascii-file, $fh) = tempfile;
    }

    # now create the PostScript file
    shell "a2ps -o '$path' '$ascii-file'";
}

our &mak-pdf-fil is export = &make-pdf-file;
sub make-pdf-file(
    IO::Path $path,
    :$text = "some text",
    :$debug,
    ) is export {

    # create a temp ascii file
    my ($ascii-file, $fh);
    if $debug {
        $ascii-file = "$tdir/temp-asc".IO;
        $fh         =  open $ascii-file, :w;
    }
    else {
        ($ascii-file, $fh) = tempfile;
    }

    $fh.say: $text;
    $fh.close;

    # create a temp PostScript file
    my ($ps-file, $fh2);
    if $debug {
        $ps-file = "$tdir/temp-ps".IO;
        $fh2     =  open $ps-file, :w;
    }
    else {
        ($ps-file, $fh2) = tempfile;
    }

    shell "a2ps -o '$ps-file' '$ascii-file'";

    # finally, create the pdf file
    shell "ps2pdf $ps-file $path";
}

