[![Actions Status](https://github.com/tbrowder/Font-Utils/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/Font-Utils/actions) [![Actions Status](https://github.com/tbrowder/Font-Utils/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/Font-Utils/actions) [![Actions Status](https://github.com/tbrowder/Font-Utils/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/Font-Utils/actions)

NAME
====

**Font::Utils** - Provides routines and programs to interrogate font directories and individual font files. 

**NOTE**: The intent is for this module to work on Linux, MacOS, and Windows. Please file an issue if you need it on your OS. The package requires use of the 'PDF::Font::Loader:ver<0.8.9+>' which has recently been ported to those two systems.

SYNOPSIS
========

```raku
use Font::Utils;
my $dir = "/usr/share/fonts/opentype/freefont
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

    $ font-utils <mode> [...options...]

### Modes

#### list

`list $directory, :$out = $*OUT`

Uses routine `list` to provide a list of font families and their fonts in the input directory. Any other entry will show the user's font list: '\$HOME/.Font-Utils/font-files.list'.

#### show 

`show $font-file, :$out = $*OUT`

Uses routine `show` to provide a list of the input font's attributes.

#### sample

    sample $font-file, :$media = 'Letter', 
                            :$out = "sample.pdf"

Uses routine `sample` to create a PDF document showing the input font at a default size of 12 points on Letter paper in Portrait orientation. The glyphs printed will be from the Latin blocks as shown at [https://unicode.org](https://unicode.org). 

Note not all fonts have valid glyphs for each code point. This module attempts to block those glyphs that are not normally used for printing such as controls and various glyph modifiers, but ultimately each font may have substitute glyphs the user may not want to see in the sample. Thus the user can block use of code points by hex number in his '$HOME/.Font-Utils/font-ignores.list' file. That file looks like this:

    # family | type | hex code points to ignore (case insensitive)
    FreeSerif  otf  ac0-acf d123 e200-f390 # <= note ranges of codes

The author has included some entries for fonts he uses, but the user can modify it at will. After initial creation, it will not be modified by this package.

Classes
-------

### class FaceFreeFont

Contains all the attributes obtained in the `$face` object created by module 'Font::FreeFont' from a font file loaded with the 'load-font routine of module 'PDF::Font::Loader'. In addition, it adds most of the font interrogation methods from its 'Font::FreeType' $face object.

The class is instantiated by two required attributes:

  * $font - the font object created by 'PDF::Font::Loader' from a font file.

  * $font-size - the desired font size in points (72 points = 1 inch).

There is one other important attribute that affect the object creation and its method that selects glyphs to use from the font file:

  * - has $.limit-glyphs = False;

When True, several checks are made to eliminate some glyphs at creation time. Any glyph that has zero width or height is ignored for the samples. Glyphs that are known control characters or space related are ignored. (But the user can always declare glyphs to be ignored at all times for certain conditions.)

### Other classes

The rollowing classes aren't user classes and won't be discussed. Peruse the source code for more information:

  * class Glyp-Str 

  * class Glyph-Row

  * class Section

  * class Ignore

Routines
--------

In Raku font handling we are constantly dealing with various font and typesetting parameter conversions such as length and angle units, and decimal and hexidecimal glyph code points. Those required for module internals and testing are incLuded. Some of those routines are duplicated in other modules, but having them close is useful.

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

Note that the Free Fonts do not cover all those glyphs, but the Noto fonts do cover most if you need the largest coverage. The Free Fonts are more attractive to my eyes, but that is an artistic decision. You can most always find a suitable free or paid font if you look for it. See [https://monotype.com](https://monotype.com) as a good example where I found a MICR bank font file for personal desktop use for a very reasonable price (about the same as a couple of six-packs of my favorite IPA).

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2024 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

