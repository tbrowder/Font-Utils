unit module Font::Utils;

use QueryOS;

my $o = OS.new;
my $onam = $o.name;

# list of font file directories of primary
# interest on Debian (and Ubuntu)
our @fdirs is export;
with $onam {
    when /:i deb|ubu / {
        @fdirs = <
            /usr/share/fonts/opentype/freefonts
            /usr/share/fonts/opentype/urw-base35
            /usr/share/fonts/opentype/ebgaramond
        >
    }
    default {
        die "FATAL: Unknown OS name: '$_'. Please file an issue."
    }
}

sub help() is export {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <mode> [...options...]

    Creates various font-related files based on the user's OS
    (recognized operating systems: Debian, Ubuntu, MacOS, Windows.
    This OS is '$onam'.

    Modes:
      font-list
       
    Options:
      dir=X - Where X is the desired font directory
    HERE
    exit;
}

sub use-args(@args) is export {
    
}

