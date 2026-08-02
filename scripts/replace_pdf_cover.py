"""Replace the first page of a PDF while preserving the rest of the document."""

from pathlib import Path
import sys

from pypdf import PdfReader, PdfWriter


def main() -> None:
    if len(sys.argv) != 4:
        raise SystemExit("usage: replace_pdf_cover.py SOURCE COVER OUTPUT")

    source, cover, output = map(Path, sys.argv[1:])
    source_reader = PdfReader(source)
    cover_reader = PdfReader(cover)
    if len(cover_reader.pages) != 1:
        raise ValueError("cover PDF must contain exactly one page")

    writer = PdfWriter()
    writer.clone_document_from_reader(source_reader)
    writer.remove_page(0)
    writer.insert_page(cover_reader.pages[0], 0)

    with output.open("wb") as stream:
        writer.write(stream)


if __name__ == "__main__":
    main()
