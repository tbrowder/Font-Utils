[![Actions Status](https://github.com/tbrowder/Font-Utils/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/Font-Utils/actions) [![Actions Status](https://github.com/tbrowder/Font-Utils/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/Font-Utils/actions) [![Actions Status](https://github.com/tbrowder/Font-Utils/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/Font-Utils/actions)

NAME
====

**Font::Utils** - Provides routines and programs to interrogate font directories and individual font files. 

**NOTE**: The intent is for this module to work on Linux, MacOS, and Windows. Please file an issue if you need it on your OS. The package requires use of the 'PDF::Font::Loader:ver<0.8.9>' which has recently been ported to those two systems.

SYNOPSIS
========

```raku
use Font::Utils;
my $dir = "/usr/share/fonts/opentype/cantarell
font-utils list $dir;
font-utils show $font-file;
font-utils sample $font-file;
```

DESCRIPTION
===========

**Font::Utils** contains the following installed program, classes, and routines:

Program
-------

### font-utils

    font-utils <mode> [...options...]

### Modes

#### list

`list $directory, :$out = $*OUT`

Uses routine `list` to provide a list of font families and their fonts in the input directory. Any other entry will show the user's list.

#### show 

`show $font-file, :$out = $*OUT`

Uses routine `show` to provide a list of the input font's attributes.

#### sample

    sample $font-file, :$media = 'Letter', 
                            :$out = "sample.pdf"

Uses routine `sample` to create a PDF document showing each input font at a default size of 12 points on Letter paper in Portrait orientation.

If no text is supplied, and no specific number of glyphs is entered, the sample will show as many glyphs as can be shown on a single line of the alphanumeric glyphs in that font.

Classes
-------

### FreeFontFace

`class FreeFontFace {...}`

Contains all the attributes obtained in the `$face` object created by module 'Font::FreeFont' from a font file.

Routines
--------

### hex2string

    sub hex2string(
        $code-point-list, 
        --> Str) is export {...}

Given a list of hexadecimal code points, convert them to a string. You may indicate a range of code points by separating the end points with a hyphen. For example:

    my @symbols = "21-2f 3a-40 5b-60 7b-7e";
    my $s = hex2string @symbols;
    say $s;
    !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~

### dec2string

    sub dec2string(
        $code-point-list, 
        --> Str) is export {...}

Given a list of decimal code points, convert them to a string. You may indicate a range of code points by separating the end points with a hyphen. For example:

    my @symbols = "33-47 58-64 91-96 123-126";
    my $s = dec2string @symbols;
    say $s;
    !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~

### write-line

    sub write-line(
        $page,
        :$font!,  # DocFont object
        :$text!,
        :$x!, :$y!,
        :$align = "left", # left, right, center
        :$valign = "baseline", # baseline, top, bottom
        :$debug,
    ) is export {

### rescale

    sub rescale(
        $font,
        :$debug,
        --> Numeric
        ) is export {...}

Given a font object with its size setting (.size) and a string of text you want to be an actual height X, returns the calculated setting size to achieve that top bearing.

### hex2dec

    sub hex2dec(
        Str $hex
        --> Numeric
        ) is export {...}

Converts an input hex string to a decimal number.

### text-box

    sub text-box(
        Str $text,
        :$font!,      #= fixed at creation
        :$font-size!, #= fixed at creation
        # variable args
        :$ulx, :$ull, #= upper-left corner coordinates
        :$width, :$height,


        --> PDF::Contents::Text::Box
        ) is export {...}

Given a chunk of text, a font object and font size, returns a text-box object that can be interrogated and manipulated and reused to print text boxes on a PDF page. Some parameters are fixed as marked in the signature above, but the rest can be changed upon reuse.

Fixed parameters:

Variable parameters:

Data
----

Included with the module is a hash (`%uni`) with the hexadecimal code points for the following named sets of Unicode glyphs:

<table class="pod-table">
<thead><tr>
<th>Set name</th> <th>Hash key</th>
</tr></thead>
<tbody>
<tr> <td>Basic Latin (ASCII)</td> <td>(two sets)</td> </tr> <tr> <td>+ Symbols</td> <td>L-sym</td> </tr> <tr> <td>+ Characters</td> <td>L-chr</td> </tr> <tr> <td>Latin-1 Supplement</td> <td>L1-Sup</td> </tr> <tr> <td>Latin Extended A</td> <td>L-Ext-A</td> </tr> <tr> <td>Latin Extended B</td> <td>L-Ext-B</td> </tr> <tr> <td>Latin Extended C</td> <td>L-Ext-C</td> </tr> <tr> <td>Latin Extended D</td> <td>L-Ext-D</td> </tr> <tr> <td>Latin Extended E</td> <td>L-Ext-E</td> </tr> <tr> <td>Latin Additional</td> <td>L-Additional</td> </tr> <tr> <td>Latin Ligatures</td> <td>L-Ligatures</td> </tr>
</tbody>
</table>

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2024 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

