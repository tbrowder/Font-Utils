unit module Font::Utils::FontX;

=begin comment
# List font family, file type, and specific glyphs to ignore if desired
constant %special-ignores is export = %(

# for now use family name and file type
FreeSerif => {
    type => {
        otf  => "",
        ttf  => "",
    }
},
FreeSans => {
},
FreeMono => {
},

# end of %special-ignores hash:
);
=end comment
