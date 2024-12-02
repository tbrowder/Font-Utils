unit module Font::Utils::Misc;

# Need to export by a hash or class
constant %uni is export = %(

# Basic Latin (ASCII)
L-sym => "21-2f 3a-40 5b-60 7b-7e",
L-chr => "30-39 41-5a 61-7a",

# Latin-1 Supplement
L-Sup => "a1-ac ae-bf c0-ff",

# Latin Extended A
L-Ext-A => "100-17f",

# Latin Extended B
L-Ext-B => "180-24f",

# Latin Extended C
L-Ext-C => "2c60-2c7f",

# Latin Extended D
L-Ext-D => "a72-a7cd a7d0 a7d1 a7d3 a7d5-a7dc a7f2-a7ff",

# Latin Extended E
L-Ext-E => "ab30-ab6b",

# Latin Extended F
L-Ext-F => "",

# Latin Extended G
L-Ext-G => "",

# Latin Additional
L-Additional => "1e00-1eff",

# Latin Ligatures (others in this group excluded)
L-Ligatures => "fb00-fb06",

);
