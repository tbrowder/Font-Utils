unit module Font::Utils::Misc;

# List keys and titles
constant %uni-titles is export = %(
    a => {
        title => "Basic Latin (ASCII) (symbols)",
        key   => "L-sym",
    },
    b => {
        title => "Basic Latin (ASCII) (alphanumerics)",
        key   => "L-chr";
    },
    c => {
        title => "Latin-1 Supplement",
        key   => "L-sup";
    },
    d => {
        title => "Latin Extended A",
        key   => "L-Ext-A";
    },
    e => {
        title => "Latin Extended B",
        key   => "L-Ext-B";
    },
    f => {
        title => "Latin Extended C",
        key   => "L-Ext-C";
    },
    g => {
        title => "Latin Extended D",
        key   => "L-Ext-D";
    },
    h => {
        title => "Latin Extended E",
        key   => "L-Ext-E";
    },
    i => {
        title => "Latin Extended F",
        key   => "L-Ext-F";
    },
    j => {
        title => "Latin Extended G",
        key   => "L-Ext-G";
    },
    k => {
        title => "Latin Additional",
        key   => "L-Additional";
    },
    l => {
        title => "Latin Ligatures",
        key   => "L-Ligatures";
    },
);

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
# TODO complete
L-Ext-F => "10780-10785 10787-107BA",

# Latin Extended G
# TODO complete
L-Ext-G => "1DF00-1DF1E 1DF25-1DF2A",

# Latin Additional
L-Additional => "1e00-1eff",

# Latin Ligatures (others in this group excluded)
L-Ligatures => "fb00-fb06",

);
