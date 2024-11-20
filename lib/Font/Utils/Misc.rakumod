unit module Font::Utils::Misc;

# Need to export by a hash or class
constant %uni is export = %(

# Basic Latin (ASCII)
L-symbols => <21-2f 3a-40 5b-60 7b-7e>,
L-chars   => <30-39 41-5a 61-7a>,

# Latin-1 Supplement
L1-Sup-symbols => <a1-ac ae-bf>,
L1-Sup-chars   => <c0-ff>,

# Latin Extended A
L-Ext-A-chars  => <100-17f>,

# Latin Extended B
L-Ext-B-chars  => <180-24f>,

# Latin Extended C
L-Ext-C-chars  => <2c60-2c7f>,

# Latin Additional
L-Add-chars    => <1e00-1eff>,

# Latin Ligatures (others in this group excluded)
L-Lig-chars   => <fb00-fb06>,

);
