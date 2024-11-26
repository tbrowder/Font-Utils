unit module Font::Utils::Misc;

# Need to export by a hash or class
constant %uni is export = %(

# Basic Latin (ASCII)
L-symbols => "21-2f 3a-40 5b-60 7b-7e",
L-chars   => "30-39 41-5a 61-7a",

# Latin-1 Supplement
L-Sup-symbols => "a1-ac ae-bf",
L-Sup-chars   => "c0-ff",

# Latin Extended A
L-Ext-A-chars  => "100-17f",

# Latin Extended B
L-Ext-B-chars  => "180-24f",

# Latin Extended C
L-Ext-C-chars  => "2c60-2c7f",

# Latin Extended D
L-Ext-D-chars  => "a72-a7cd a7d0 a7d1 a7d3 a7d5-a7dc a7f2-a7ff",

# Latin Extended E
L-Ext-E-chars  => "ab30-ab6b",

# Latin Extended F
# Latin Extended G

# Latin Additional
L-Add-chars    => "1e00-1eff",

# Latin Ligatures (others in this group excluded)
L-Lig-chars   => "fb00-fb06",

);

=finish

L-Ext-A-chars
L-Ext-B-chars
L-Ext-C-chars
L-Ext-D-chars
L-Add-chars
L-Lig-chars
