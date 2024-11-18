use Test;

use PDF::Font::Loader :load-font;

use Font::Utils;

my $debug = 0;
my $ffile = "/usr/share/fonts/opentype/freefont/FreeSerif.otf";

my ($o, $font, $text);

lives-ok {
   $font = load-font :file($ffile);
   $text = "";
   $o = text-box $text, :$font;
   
}, "default text-box object";

done-testing;

