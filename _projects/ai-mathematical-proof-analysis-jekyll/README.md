# AI mathematical proof progress — Jekyll-ready microsite

This folder is a self-contained static clone of the microsite. It contains the
interactive dashboard, all datasets, images, the favicon, social-preview
images, and the downloadable PDF report. It does not require Node.js,
Cloudflare, OpenAI Sites, a database, or a server-side application runtime.

The bundled dashboard and raw-data download contain 126 audited result
packages through 2 August 2026. The PDF is retained as the clearly labelled
64-entry baseline report; later additions and corrections are recorded in the
dashboard analysis log and data files.

## Add it to an existing Jekyll site

Copy this entire folder into the desired directory in the Jekyll repository.
For example, placing it at:

```text
mathematical-proof-progress/
```

makes the microsite available at:

```text
https://example.github.io/mathematical-proof-progress/
```

The files use relative URLs, so you may rename the folder without rebuilding
the site. If this folder is copied into an existing Jekyll site, the parent
site's `_config.yml` remains authoritative; the nested copy here is harmless.

## Use it as a standalone Jekyll site

From this directory:

```bash
bundle install
bundle exec jekyll serve
```

Then open the local address printed by Jekyll, normally
`http://127.0.0.1:4000/`.

## GitHub Pages

Commit the folder to the GitHub Pages repository and publish through that
repository's existing Pages workflow. No custom build command is needed for
the microsite itself.

## One optional adjustment after placement

The Open Graph and X image metadata uses the production SuperLattice URL. If
the folder is published elsewhere, replace that image URL in `index.html` with
the new full public HTTPS URL for the best social-link preview compatibility.
