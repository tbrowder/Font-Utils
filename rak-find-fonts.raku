#!/usr/bin/env raku

use rak;

my $rak = rak
#{.meets-the-test},
:find,
#:extensions<pbf otf ttf woff t1>,
:file(/'.' [pfb|t1|ttf|woff|otf] $/),
:paths</usr/share/fonts /Users ~/Library/Fonts>,
:absolute,
:is-readable,
#:encoding<ascii>,
:quietly,
:silently<err>,
#:unique,
;

for $rak.result -> (:key($path), :value(@found)) {
    if @found {
        say "$path:";
        say .key ~ ':' .value for @found;
    }
}
