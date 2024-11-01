[![Actions Status](https://github.com/tbrowder/Font-Utils/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/Font-Utils/actions) [![Actions Status](https://github.com/tbrowder/Font-Utils/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/Font-Utils/actions) [![Actions Status](https://github.com/tbrowder/Font-Utils/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/Font-Utils/actions)

NAME
====

**Font::Utils** - Provides routines and programs to interrogate font directories and individual font files. 

**NOTE**: The intent is for this module to work on Linux, MacOS, and Windows. Please file an issue if you need it on your OS. The package requires use of the 'PDF::Font::Loader:ver<0.8.8>' which has recently been ported to those two systems.

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

**Font::Utils** contains the following installed program:

font-utils
----------

Modes:

  * list $directory | @dirs, :$out = $*OUT

    Uses routine `list` to provide a list of font families and their fonts in the input directories.

  * show $file | @files | @dirs, :$out = $*OUT

    Uses routine `show` to provide a list of each input font's attributes.

  * sample @fonts | @dirs, :$text, :$media = 'Letter', :$orientation = 'Portrait', :$linespacing = 16, :$nglyphs, :$out = "sample.pdf"

    Uses routine `sample` to create a PDF document showing each input font at a default size of 12 points on Letter paper in Portrait orientation.

    If no text is supplied, and no specific number of glyphs is entered, the sample will show as many glyphs as can be shown on a single line of the alphanumeric glyphs in that font.

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2024 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

