# Proximal Value figures

These sources draw Figures 1–4 for the *Proximal Value* draft with the
Wardley-TikZ `structural` rendering profile. They are semantic, editable
Wardley maps; article-specific panel headings, gap guides, and assembly
contours use local TikZ only where Wardley-TikZ has no corresponding semantic
object.

Coordinates in Wardley commands are `[visibility,maturity]`. Coordinates in
local TikZ are `(maturity,visibility)`.

The source expects `wardley-tikz.sty` and its pinned `tikz-network.sty` to be
installed or present beside the figure files. With the local Wardley-TikZ
checkout, a temporary build can be prepared as follows:

```sh
cp /path/to/wardley-tikz/wardley-tikz.sty .
cp /path/to/wardley-tikz/tikz-network.sty .
tectonic --keep-logs --keep-intermediates figure-09.tex
tectonic --keep-logs --keep-intermediates figure-10.tex
tectonic --keep-logs --keep-intermediates figure-11.tex
tectonic --keep-logs --keep-intermediates figure-12.tex
```

The spacing is intentionally qualitative. These figures propose a visual
grammar for functional separation; they do not claim a calibrated coupling
measure for the database or jet-engine examples.
