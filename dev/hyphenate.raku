#!/usr/bin/env raku

use PDF::Lite;
use PDF::Content;
use PDF::Content::Text::Box;

my PDF::Lite $pdf .= new;
my PDF::Lite::Page $page = $pdf.add-page;
my PDF::Content::Font::CoreFont $font .= load-font( :family<helvetica>, :weight<bold> );
my $hp = "\c[HYPHENATION POINT]";
my $text = "Lorem ipsum dolor sit a{$hp}met, consectetur ad{$hp}ip{$hp}isc{$hp}ing elit, sed do ei{$hp}us{$hp}mod tempor in{$hp}ci{$hp}di{$hp}dunt
ut la{$hp}bore et do{$hp}lore mag{$hp}na ali{$hp}qua.";

my PDF::Content::Text::Box $text-box .= new( :$text, :$font, :align<justify>, :width(180));
my PDF::Content $gfx = $page.gfx;
$gfx.say: $text-box, :position[10, 500];

# introspect and shorten last line
given $text-box.lines.tail {
    say sprintf("last line has %d atoms, content-width of %dpt, and word gap of %dpt",
                +.decoded,
                .content-width, .word-gap);
    .word-gap = 6;
}

$gfx.say: $text-box, :position[10, 350];

$pdf.save-as: "hyphenate.pdf";
