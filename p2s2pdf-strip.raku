#!/usr/bin/env raku
use PDF::Reader;

#| strip non-deterministic data from ps2pdf output.
#| Ensure multiple runs produce exactly the same binary output
#| see https://www.mail-archive.com/debian-user@lists.debian.org/msg763682.html
sub MAIN(
    Str $file-in,               #= input PDF
    Str $file-out = $file-in,   #= output PDF (optional)
    Str :$id = "wôBÚ¦Øå³§\x[9D]¡tõpÍ\x[16]",
    ) {

    CATCH {
        when X::PDF { note .message; exit 1; }
    }

    my PDF::Reader $reader .= new.open($file-in);

    given $reader.trailer {
        .<ID> = [$id, $id];
        with .<Info> {
            .<CreationDate>:delete;
            .<ModDate>:delete;
        }
        with .<Root> {
            .<Metadata>:delete;
        }
    }
    $reader.save-as($file-out, :rebuild);
}

