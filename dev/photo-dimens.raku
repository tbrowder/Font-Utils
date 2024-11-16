#!/usr/bin/env raku

=begin comment
Missy's photos: 8-15/16 inches X 10-9/16 inches

Desired frame constraints: 4-7/8 inches X 7.0 inches
=end comment

# image
my @iargs = "8-15/16", "10-9/16";
# canvas
my @cargs = "4-7/8", "7.0";

=begin comment
    The output shows adjusted width or height based upon an
    optional constraint value: 'cw' or 'ch'. If both are entered,
    the 'cw' constraint is used.

    If any option is selected, only the selected unit's values are shown
    (default: inches).

    Options:
      units=X - Where X is one of: 'in', 'cm', 'mm' (default: 'in')
      cw=X    - Where X is the width constraint in the selected units
      ch=X    - Where X is the height constraint in the selected units
=end comment

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Shows the results of scaling an input image to the width
    or height of a canvas.

    The original dimensions, in inches, for the image are 
    {@iargs.head} x {@iargs.tail} and for the canvas are {@cargs.head} x {@cargs.tail}.

    HERE
    exit;
}

my $units = 'in';
my $debug = 0;
my $aspect-ratio;
my $ctype;
my $constraint;

my $width   = frac2dec @iargs.head;
my $height  = frac2dec @iargs.tail;
my $cwidth  = frac2dec @cargs.head;
my $cheight = frac2dec @cargs.tail;

=begin comment
my $width;
if $widthT ~~ / (\d+) '-' (\d+) '/' (\d+) / {
    my $int = ~$0;
    my $num = ~$1;
    my $den = ~$2;
    #$say "DEBUG: found good widthT: $int - $num / $den";
    #exit;
    my $dec = $num/$den;
    $width = $int + $dec;
}
else {
    $width = $widthT;
}
=end comment

=begin comment
for @*ARGS {
    when /^ :i [u|un|uni|unit|units] '=' (\S+) / {
        $units = ~$0;
    }
    when /^ :i d  / {
        ++$debug;
    }
    when /^ :i cw '=' (\S+) / {
        my $cval = ~$0;
        $ctype = 'w';
        $constraint      = $cval
    }
    when /^ :i ch '=' (\S+) / {
        if $constraint-type.defined and $constraint-type eq 'w' {
            ; # ignore
        }
        else {
            my $cval = ~$0;
            $ctype = 'h';
            $constraint      = $cval;
        }
    }
    default {
        die "FATAL: Unknown arg '$_'";
    }
}
=end comment

calc-canvas $width, $height, :ctype<w>, :constraint($cwidth), :$debug;
calc-canvas $width, $height, :ctype<h>, :constraint($cheight), :$debug;

sub frac2dec(
    Str $frac,
    :$debug,
    --> Numeric
    ) is export {

    my ($dec, $int, $num, $den);
    with $frac {
        when / (\d+) '-' (\d+) '/' (\d+) / {
            $int = ~$0;
            $num = ~$1;
            $den = ~$2;
            $dec = $num/$den;
            $dec = $int + $dec;
        }
        when / (\d+) / {
            $dec = +$0;
        }
        when / (\d+ '.' \d+?) / {
            $dec = +$0;
        }
        default {
            die "FATAL: Unrecognized dimen pattern '$_'"
        }
    }
    $dec
}

sub calc-canvas(
    $width, $height,
    :$ctype!,
    :$constraint!,
    :$debug,
) is export {

    my $aspect = $width/$height;
    my ($new-width, $new-height);

    if $ctype eq "w" {
        $new-width  = $constraint;
        $new-height = $new-width / $aspect;
    }
    else {
        $new-height = $constraint;
        $new-width  = $new-height * $aspect;
    }
    
    print qq:to/HERE/;
    ============================
    Inputs:
      units        : $units
      width        : $width
      height       : $height
      ctype        : $ctype
      constraint   : $constraint

    Outputs:
      aspect ratio : $aspect
      new width    : $new-width
      new height   : $new-height
    HERE
} 
