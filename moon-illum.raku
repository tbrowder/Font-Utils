#!/usr/bin/env raku
use Math::Trig;

enum Orientation < Portrait Landscape >;
enum Paper < A4 A5 Legal Letter >;

# define which Moon illumination fraction we're talking about
enum Phase <Waxing Waning>;
Y
# The circle representing the Moon's 2D shape to an Earth observer:
my $r = 1;
# The area of the circle:
my $C2 = pi * $r^2;
# The half-circle area:
my $C = 0.5 * $C2;

sub ell-area($a, $b) {
    # returns the area of an ellipse given the major- and minor- axes
    $a * $b * pi
}

sub ell-b($area, $axis) {
    # returns the other axis given one of them
    # area = a b pi
    # a = area / (b pi)
    # a b = area / pi
    # b = area/a // pi
    ($area/$axis) * (1/pi)
}

my $go    = 0;
my $frac  = 0;
my $debug = 0;
my $test  = 0;
my ($paper,$left-margin,$right-margin,$top-margin,$bottom-margin,$orientation); # defined in BEGIN block at end);

constant mm-per-in = 25.4;
my %papers = [
    # all dimensions are in PS points (72 per inch)
    # these two values are set by sub set-paper:
    width  => 0,
    height => 0,

    # the value is the string to insert at the beginning of the PS doc
    Letter  => { width => 612, height => 792},
    Legal   => { width => 612, height => 1008},
    A4      => { width => 595, height => 842},
    A3      => { width => 842, height => 1190},
];

if not @*ARGS.elems {
    say qq:to/HERE/;
    Usage: {$*PROGRAM.IO.basename} frac | moon

    Modes
        Go       - produces a PS file of Moon phase images
        Frac     - shows a table of fractional Moon illumination data
        Test[=N] - for developer use

    Options
        Paper=X         - where X is the paper specification:
                            Letter (default), Legal, A4, or A3
        Margins=l,r,t,b - in inches: left,right,top,bottom (default 1,1,1,1)
        Orientation=X   - where X is p|P|l|L for Portrait or Landscape (default)
        Debug           - for developer use

    Note: Use only the first character (either case) of the mode or option.
    HERE
    exit;
}

my $paper-is-set = 0;
for @*ARGS {
    # note we accept either case for all modes and options
    # modes
    when /:i ^g/ {$go = 1}
    when /:i ^f/ {$frac = 1}
    when /:i ^t ['=' (\d+)]?/ {
        if $0.defined {
            $test = +$0;
            die "FATAL: The value of Test must be > 0" if $test < 1;
        }
        else {
            $test = 1;
        }
    }
    # options
    when /:i ^d/ {$debug = 1}
    when /:i ^'o=' (<[lp]>)/ {
        my $o = ~$0;
        $orientation = $o eq 'l' ?? Landscape !! Portrait;
        $paper-is-set = set-paper $paper, $orientation;
    }
    when /:i ^'p=' (\S+) / {
        $paper = ~$0;
        if not %papers{$paper}:exists {
            note "FATAL: paper '$paper' not recongnized.\nUse one of these:";
            note "  $_" for %papers.keys.sort;
            exit;
        }
        $paper-is-set = set-paper $paper, $orientation;
    }
    #   margins=l,r,t,b - in inches: left,right,top,bottom (default 1,1,1,1)
    when /:i ^'m=' (\S+) ',' (\S+) ',' (\S+) ',' (\S+) / {
        $left-margin   = +$0 * 72;
        $right-margin  = +$1 * 72;
        $top-margin    = +$2 * 72;
        $bottom-margin = +$3 * 72;
    }
    default {die "FATAL: Unknown arg '$_'"}
}
$orientation = Portrait if $test;
set-paper($paper, $orientation) if not $paper-is-set;

if 0 {
    say "DEBUG: test = $test";
    exit;
}

if $frac {
    my @v = 0, .1, .2, .3, .4, .5, .6, .7, .8, .9, 1;
    my $prev = 1;
    for @v {
        my $b = moon-ell-minor($_);
        my $delta = $prev.abs - $b.abs;
        say sprintf "for FA = %02.1f, b = % 02.8f, delta = % 02.8f", $_, $b, $delta;
        $prev = $b;
    }
    exit;
}
if $go {
    my $f   = 't.ps';
    my $pdf = 'lunar-month.pdf';
    show-lunar-month $f;

    # use Ghostscript fix for reproducible runs in ps2pdf
    my $gs-pdf-settings = "-dPDFSETTINGS=/prepress";
    # my $f   = 't.ps';
    shell "ps2pdf $gs-pdf-settings $f $pdf";

    say "Normal end.";
    say "See output file '$pdf'";
    exit;
}
if $test {
    my $f   = 't.ps';
    my $pdf = 'lunar-month.pdf';
    my $F = 0.5;
    show-phase $F, $f, :$test, :$debug;
    shell "ps2pdf $f $pdf";
    say "Normal end.";
    say "See test output file '$pdf' with frac $F";
    exit;
    exit;
}

# else
die "FATAL: No modes selected.";
exit;

##### SUBROUTINES #####
sub show-phase($F where { 0 <= $F <= 1 }, $fnam = 't.ps',
               :$phase = Waxing,
               :$hemi = 'N',
               :$test, :$debug) {
    my $fh = open $fnam, :w;
    my $sp = 1;
    #$sp = 0 if $test;
    ps-doc-prologue($fh, :setpagedevice($sp));
    $fh.say: '/tr9  {/Times-Roman 9 selectfont} bind def';
    $fh.say: 'tr9 % set default font';
    $fh.say: '0 setlinewidth % set default linewidth for boxing';

    # set defaults to the Cookbook bbox
    my ($x0, $x1, $y0, $y1) = (72, 544, 100, 544);

    if 0 {
        # create the images from the ellipse section of the Cookbook
        # add a thin bounding box around the figures
        # all in PS points
        # lower-left corner: 72, 100
        $x0 = 144 -  72; #  72
        $y0 = 150 -  50; # 100
        # upper-right corner: 544, 544
        $x1 = 400 + 144; # 544
        $y1 = 400 + 144; # 544
        $fh.say: "gsave newpath $x0 $y0 moveto $x1 $y0 lineto $x1 $y1 lineto $x0 $y1 lineto closepath stroke grestore";
        $fh.say: "gsave newpath $x0 $y1 moveto 10 -10 rmoveto (Cookbook bbox) show grestore";

        # draw the ellipses
        $fh.say: "newpath 144 400  72 144   0 360 ellipse stroke";
        $fh.say: "newpath 400 400 144  36   0 360 ellipse fill";
        $fh.say: "newpath 300 180 144  72  30 150 ellipse stroke";
        $fh.say: "newpath 480 150  30  50 270  90 ellipse fill";
    }

    if 0 and $test > 1 and $debug {
        $fh.say: "showpage";
        $fh.close;
        note "DEBUG: Early exit from test sub after cookbook ellipses are drawn.\nSee file '$fnam'.";
        exit;
    }

    # define the printed area for the page
    # all units in PS points
    my $width   = %papers<width>;
    my $height  = %papers<height>;

    my $hwidth  = $width  - ($right-margin + $left-margin);
    my $vheight = $height - ($top-margin + $y1); #top-margin   - $bottom-margin;
    my $cell-width  = $hwidth/5;   # PS points
    my $cell-height = $vheight; # $cell-width; # PS points

    # draw bbox around the cell for the Moon phase
    $x0 = $left-margin;
    $x1 = $x0 + $hwidth;
    $y0 = $y1; # the top of the Cookbook bbox
    $y1 = $height - $top-margin;

    # starting with the upper-left corner
    $fh.say: "$x0 $y1 $hwidth $vheight box" if not $debug;
    if 0 {
        $fh.say: "gsave newpath $x0 $y1 moveto 10 -10 rmoveto (Moon phase cell bbox) show grestore";
    }

    if 0 and $debug {
        $x0 /= 72; # inches$left-margin;
        $x1 /= 72; # inches$x0 + $hwidth;
        $y0 /= 72; # inches$y1; # the top of the Cookbook bbox
        $y1 /= 72; # inches$height - $top-margin;
        note "DEBUG: Moon phase bbox in inches: $x0, $y0        $x1, $y1";
    }

    # size of Moon
    my $min-space = $cell-width < $cell-height ?? $cell-width !! $cell-height;
    my $radius = $min-space * 0.5 - 0.1; # PS points
    my $font-size = 9; # PS points

    # for future use
    my $ca = 0; # crescent angle in degrees

    # outline the cell
    # starting with the upper-left corner

    if 1 { #$test { # > 2 {
        # start at the top-left corner of the Moon bbbox
        my ($x,$y) = ($x0,$y1);
        my $cx = $cell-width/2;
        my $cy = $cell-height/2;

        my @waxing = (0, 0.25, 0.5, 0.75, 1);
        for @waxing -> $f {
            $fh.say: "$x $y $cell-width $cell-height box";
            # create the Moon phase and center it in the cell
            # /moonPhase { % stack: cx cy radius illum-frac phase crescent-angle hemisphere
            $fh.say: "{$x+$cx} {$y-$cy} $radius $f ($phase) $ca ($hemi) moonPhase";

            # add text
            $fh.say: "gsave $x 6 add $y 10 sub moveto (Phase: $phase) show grestore";
            $fh.say: "gsave $x 6 add $y 20 sub moveto (Frac: $f) show grestore";
            $fh.say: "gsave $x 6 add $y 30 sub moveto (Dark: {1-$f}) show grestore";

            $x += $cell-width;
        }

        # next row down
        $x = $x0;
        my @waning = @waxing.reverse;
        $y -= $cell-height;
        my $p = Waning;
        for @waning -> $f {
            $fh.say: "$x $y $cell-width $cell-height box";
            # create the Moon phase and center it in the cell
            # /moonPhase { % stack: cx cy radius illum-frac phase crescent-angle hemisphere
            $fh.say: "{$x+$cx} {$y-$cy} $radius $f ($p) $ca ($hemi) moonPhase";

            # add text
            $fh.say: "gsave $x 6 add $y 10 sub moveto (Phase: $p) show grestore";
            $fh.say: "gsave $x 6 add $y 20 sub moveto (Frac: $f) show grestore";
            $fh.say: "gsave $x 6 add $y 30 sub moveto (Dark: {1-$f}) show grestore";

            $x += $cell-width;
        }

    }

    $fh.say: "showpage";
    $fh.close;


}

sub moon-ell-minor($F where { 0 <= $F <= 1 }) {
    # Given the Moon's fractional area of illumination, return the
    # length of the semi-minor axis b of the ellipse describing the
    # resulting boundary of one lune edge.  The calculation is for the
    # unit circle so the value will vary from zero to plus or minus
    # one.
    #
    # Range of fractional area:     1.0   0.5   0.0
    # Range of the semi-minor axis: 1.0   0.0   1.0

    # Given the area of the semicircular plane figure with constant area A, the semiellipsoid with
    #   variable area B = 0.5*pi*b, and the fractional area as F, we have
    #
    #   for the right half:
    #
    #     F = (A + B)/2A
    #
    #   and for the left half:
    #
    #     F = (A - B)/2A
    #
    my $A = 0.5 * pi;
    my $b = 0;
    given $F {
        when $_ > 0.5 {
            # the terminator line is in the right half of the Moon's surface
            $b = (2/pi) * ((2 *  $F * $A) - $A);
        }
        when $_ < 0.5 {
            # the terminator line is in the left half of the Moon's surface
            $b = -(2/pi) * ((2 * $F * $A) - $A);
        }
        # when the fractional area is 0.5, the minor axis is zero as the ellipse
        # has collapsed to a straight line
        default { $b = 0 }
    }
    return $b;
}


=begin comment

The boundary of the ellipse representing the boundary of the lit/unlit regions:

Its semi-major axis, a, is a constant of length r, the radius of the Moon representation.
Its semi-minor axis, b, varies from r to zero.
The formula for its area, LA, is a * b * pi. One-half its area is LA/2 we will call it L.
The fraction, F, of illumination varies from zero to one, so FC is
the area illuminated at any instant.

Show b in terms of a and L:

  LA = a b pi
  L = 1/2(a b pi) = b/2 * 1/2(a pi)
  b/2 = L // 1/2(a pi)
  b = 4L / (r pi)

We need the semi-minor axis of the ellipse for any
value of F.

Calculations:

The area, A, between the boundary of a circle and the interior ellipse with
semi-major axis less than or equal to the circle's radius is:

Let H = C/2 = constant

A = H - L
A = H - 1/2(r b pi)
A - H = -1/2(r b pi)
-(A - H) = 1/2(r b pi)
b = -(A - H)/(r pi)      [Eq. 1]

Given FA then we can solve for b:

b = -(FA - H)/(r pi)


The remaining area, B, is then:

B = H - A = L/2

For the waxing Moon to the first quarter, the total illuminated area is A. F = 0.5 at the first quarter.

We then solve the following equation for b:

  FA = C/2 - L/2

For the waxing Moon to the full Moon, the total illuminated area is C/2 + B. F = 1.0 at the full Moon.

We then solve the following equation for b:

  FA = C/2 + B = C/2 + L/2

For the waning Moon to the third quarter, the total illuminated area is C/2 - B. F = 0.5 at the third quarter.

For the waning Moon to the new Moon, the total illuminated area is C/2 - A. F = 0.0 at the new Moon.

=end comment

=begin comment
The Moon crescent angle, ca, from Stack Overflow, is calculated as:

Given az,el in degrees of the Sun (saz, sel) and Moon (maz, mel), calculate ca
where daz is the difference between the two azimuth angles:

  daz = saz - maz
  y = sin(deg2rad(daz)) * cos(deg2rad(sel))
  x = cos(deg2rad(mel)) * sin(deg2rad(mel))
  a = atan2(x,y)
  a = rad2deg(a)

The crescent angle, a, is the angle in degrees of the line from the Sun
to the Moon as seen in 2D from the Earth with 360 degrees
being "down" toward the "top" of the Moon as seen from the observer
on the Earth.

NOTE: I need to confirm this after seeing the images
produced with the formula.

=end comment
sub crescent-angle(:$saz!, :$sel!, :$maz!, :$mel!) {
    #my $daz = ($saz.abs - $maz.abs).abs;
    my $daz = $saz - $maz;
    my $y   = sin(deg2rad($daz)) * cos(deg2rad($sel));
    my $x   = cos(deg2rad($mel)) * sin(deg2rad($mel));
    my $ca  = atan2($x,$y);
    $ca     = rad2deg($ca);
}

##### subroutines #####

sub ps-doc-prologue($fh, :$setpagedevice) {
    $fh.say: '%!PS-ADOBE-3';
    setpagedevice($fh) if $setpagedevice;

    $fh.say: q:to/HERE/;
    %=======================================================================================
    % the key function for Moon phase images
    %=======================================================================================
    % from the PostScript Cookbook (with mods to enable reversing the arc's direction):
    /ellipsedict 8 dict def
    ellipsedict /mtrx matrix put
    /ellipse { % stack: cx cy xrad yrad startang endang (increase counterclockwise)
        % special modification:
        % if either radius is negative, it is made positive and arcn is used
        ellipsedict begin
        /endangle   exch def
        /startangle exch def
        /yrad exch def
        /xrad exch def
        /y exch def
        /x exch def

        % determine arc direction
        /isreverse false def % do not reverse the arc
            y 0 lt {
            /y y neg def
            /isreverse true def % DO reverse the arc
        } if
        x 0 lt {
            /x x neg def
            /isreverse true def % DO reverse the arc
        } if

        /savematrix mtrx currentmatrix def
        x y translate
        xrad yrad scale
        isreverse % true or false?
        {
            0 0 1 startangle endangle arcn
        }
        {
            0 0 1 startangle endangle arc
        }
        ifelse

        savematrix setmatrix
        end
    } def

    %=======================================================================================
    % TODO break this up into more manageable code, perhaps:
    %   a func for waxing and one for waning (with ifelse for hemisphere)
    %   a func each for new, 1/4, full, and 3/4 Moon
    /moonPhase { % stack: cx cy radius illum-frac phase crescent-angle hemisphere
        10 dict begin
        /hemi exch def    % a string: "N" or "S"
        /cangle exch def
        /phase exch def   % a string: "Waxing" or "Waning"
        /illum exch def
        /radius exch def
        /cy exch def
        /cx exch def

        % The Moon's phases are determined by the "terminator" line
        % separating the illuminated and dark portions of the Moon's
        % surface as observed from the surface of the Earth.
        %
        % In the northern hemisphere the terminator line appears
        % to move from right to left, while from an observer in
        % the southern hemisphere it appears to move from left to
        % right.
        %
        % Thus an image for any fraction of illumination and phase
        % is a reflection about the y axis for north versus south.

        0 setlinewidth

        % easier for me to think about by defining "dark"
        /dark 1 illum sub def
        gsave
        cx cy translate

        % we need to check this carefully:
        % rotate
        cangle rotate

        % draw the Moon circle and stroke
        % circle  =====
        newpath
        0 0   radius   0 360   arc
        stroke

        % Get the waxing or waning part correct first, then create
        % the other part and enclose in an ifelse block.

        % the "phase" input is a string: "Waxing" or "Waning"

        % WANING BEGIN ======================================
        phase (Waning) eq {
        % The darkness starts at the right side and gradually
        % covers the Moon's surface.

        % draw the dark part(s) and fill
        dark 0.5 gt
        {
            % GOOD AS IS ***********************************************
            % dark > 0.5
            % define a path of the right semi-circle closed
            % by the left semi-ellipse, then fill it
            newpath
            % semi-circle  =====
            % draw its path
            0 0   radius   270 90   arc
            fill

            % semi-ellipse =====
            % draw its path
            0 0   radius dark 0.5 sub 0.5 div mul radius 90 270   ellipse
            fill
            % GOOD AS IS ***********************************************
        }
        {
            % dark <= 0.5
            % use another ifelse
            dark 0.5 lt
            {
                % GOOD AS IS ************************************************
                % dark < 0.5
                % define a path of the right semi-circle
                % closed by the reversed right semi-ellipse, then fill it
                newpath
                % semi-circle  =====
                % draw its path
                0 0   radius   270 90   arc

                % semi-ellipse =====
                % use a reversed ellipse
                % draw its path
                0 0  radius 0.5 dark sub 0.5 div mul
                     % negate the radius to reverse the ellipse
                     neg
                     radius 90 270   ellipse
                fill
                % GOOD AS IS ************************************************
            }
            {
                % GOOD AS IS ************************************************
                % dark == 0.5
                % define a path of the closed right semi-circle, then fill it
                % semi-circle =====
                newpath
                % draw its path
                0 0   radius   270 90  arc
                fill
                % GOOD AS IS ************************************************
            }
            ifelse
        }
        ifelse
        } if
        % WANING END ========================================

        % WAXING BEGIN ======================================
        phase (Waxing) eq {
        % The total darkness starts decreasing at the right side
        % and gradually disappears from the Moon's surface to
        % reveal the Full Moon.

        % draw the dark part(s) and fill
        dark 0.5 gt
        {
            % dark > 0.5
            % define a path of the left semi-circle, then fill it
            newpath
            % semi-circle  =====
            % draw its path
            0 0   radius   90 270   arc
            fill

            % define the path of the right ellipse, the fill it-
            % semi-ellipse =====
            % draw its path
            0 0   radius dark 0.5 sub 0.5 div mul radius 270 90   ellipse
            fill
        }
        {
            % dark <= 0.5
            % use another ifelse
            dark 0.5 lt
            {
                % dark < 0.5
                % define a path of the left semi-circle
                % closed by the reversed left semi-ellipse
                newpath
                % semi-circle  =====
                % draw its path
                0 0   radius   270 90   arc

                % semi-ellipse =====
                % use a reversed ellipse
                % draw its path
                0 0  radius 0.5 dark sub 0.5 div mul
                     % negate the radius to reverse the ellipse
                     neg
                     radius 90 270   ellipse
                fill
            }
            {
                % dark == 0.5
                % define a path of the closed left semi-circle, then fill it
                % semi-circle =====
                newpath
                % draw its path
                0 0   radius 90 270 arc
                fill
            }
            ifelse
        }
        ifelse
        } if
        % WAXING END ========================================

        % cleanup
        grestore
        end
    } def

    %=======================================================================================
    %=======================================================================================
    % for convenience
    /i2p {72 mul} def
    /box { % stack: x y xlen ylen (upper-left corner coords, length of side)
        10 dict begin
        /ylen exch def
        /xlen exch def
        /y exch def
        /x exch def
        gsave
        newpath
        x y moveto
        0 ylen neg rlineto
        xlen 0 rlineto
        0 ylen rlineto
        closepath
        stroke
        grestore
        end
    } def
    HERE
}

sub show-lunar-month($fnam, :$hemi = 'N') {
    =begin comment
    # show 1..29 day lunar month with illuminated fraction being n/29 for 1..29
    #
    # days should be layed out to show the major phases
    # day phase (illum frac)
        1   0.0  new
        2     1
        6   0.5  first quarter
        7     6
        1   1.0  full
        2     9
        6   0.5  last quarter
        7     4
       21   0.0  new
    =end comment

    # space the blocks in 5 rows of 7, one-inch squares
    my $f = $fnam;

    my $fh = open $f, :w;
    my $sp = 1;
    $sp = 0 if $test;
    ps-doc-prologue($fh, :setpagedevice($sp));

    # define the printed area for the page
    my $width   = %papers<width>  / 72; # inches
    my $height  = %papers<height> / 72; # inches
    my $hwidth  = $width  - $right-margin - $left-margin;
    my $vheight = $height - $top-margin - $bottom-margin;

    # For show let's make a table beginning each row with a named phase
    # or pertinent interval marker.
    # idx         0   1   2   3   4
    constant @p = 0, 50, 100, 50, 0;
    constant $np = @p.elems;
    constant $nsteps = 7;

    my $cell-width  = $hwidth/$nsteps; # inches
    my $cell-height = $vheight/$np;    # inches
    my $row-height  = $cell-height;    # inches
    my $row-spacing = 0; # inches

    # size of Moon
    my $min-space = $cell-width < $cell-height ?? $cell-width !! $cell-height;
    my $radius = $min-space * 0.5 - 0.1; # inches
    my $font-size = 9; # PS points

    $fh.say: qq:to/HERE/;
    % start at the top-left corner inset by the (left-margin/top-margin) margins
    $left-margin i2p {$height - $top-margin} i2p translate
    1 setlinewidth
    HERE

    # for future use
    my $ca = 0; # crescent angle in degrees
    my $phase = Waxing;

    # we start the PS position on the page one inch in from the top-left corner
    my ($x, $y) = 0, 0;
    for @p.kv -> $i, $f {
        # let $f be the first F value for an interval for a row of F data (names and images)
        # let the F value for @p[$i+1] be the end of the interval
        # end the loop when > 3
        last if $i > 3;

        $fh.say: "% ROW $i ===========================================================";
        my $n = get-phase-name($i, $f);
        say "DEBUG: idx $i, value: $f, name: $n" if $debug;

        my $start = @p[$i];
        my $end   = @p[$i+1];
        my $step  = ($end - $start)/$nsteps;
        say "DEBUG: start '$start' end '$end'" if $debug;
        my $F = $f;
        for 0..^$nsteps {
            # outline the cell
            $fh.say: "$x i2p $y i2p $cell-width i2p $cell-height i2p box";
            # create the Moon phase and center it in the cell
            # /moonPhase { % stack: cx cy radius illum-frac phase crescent-angle hemisphere
            my $cx = $cell-width/2;  # inches
            my $cy = $cell-height/2; # inches

            $F += $step;
            $fh.say: "{$x+$cx} i2p {$y+$cy} i2p $radius i2p $F ($phase) $ca ($hemi) moonPhase";

            # add text
            # increment the horizontal position right by one cell width
            $x += $cell-width;
        }

        # increment the vertical position down one row height
        # move to beginning of the row
        $x  = 0;
        $y -= $row-height;
    }
    $fh.say: "showpage";
    $fh.close;
}

sub get-phase-name($i, # the phase increment index
                   $f, # the fraction of illumination
                  ) {
    # the phases are minimally divided into five increments ($i: 0..4)
    # within each increment we calculate a title as appropriate
    if $i < 3 {
        # new moon waxing to full illumination
        given $f {
            when $f ==   0 { "new moon" }
            when $f <   50 { "waxing crescent" }
            when $f ==  50 { "first quarter" }
            when $f <  100 { "waxing gibbous" }
            when $f == 100 { "full moon" }
            default { die "FATAL: Unexpected fractional illumination factor: $f"; }
        }
    }
    else {
        # full moon waning to total darkness
        given $f {
            when $f ==   0 { "new moon" }
            when $f <   50 { "waxing crescent" }
            when $f ==  50 { "third quarter" }
            when $f <  100 { "waning gibbous" }
            default { die "FATAL: Unexpected fractional illumination factor: $f"; }
        }
    }
}

sub setpagedevice($fh) {
    # sets the PostScript page device
    # prints as one line in the output file:
    $fh.print: "<</PageSize [{%papers<width>} {%papers<height>}]>> setpagedevice";
    $fh.say:   " % width x height (PS points): {%papers<name>} ({%papers<orient>})";
}

sub set-paper($paper, $orientation --> Int) {
    # sets width, height and other values the paper selected
    my $w = %papers{$paper}<width>;
    my $h = %papers{$paper}<height>;
    if $orientation eq Landscape {
        # swap hw
        ($w,$h) = ($h,$w);
    }
    %papers<width>  = $w; # PS points
    %papers<height> = $h; # PS points
    %papers<name>   = $paper;
    %papers<orient> = $orientation;

    return 1;
}

BEGIN {
    $paper = Letter;
    # margins are in inches x PS points per inch = PS points
    # and are measured as the distance from the respective edge
    $left-margin=$right-margin=$top-margin=$bottom-margin=1*72; # PS points
    $orientation = Landscape;
}
