# AI mathematical proof progress — Jekyll-ready microsite

This folder is a self-contained static clone of the microsite. It contains the
interactive dashboard, all datasets, images, the favicon, social-preview
images, and the downloadable PDF report. It does not require Node.js,
Cloudflare, OpenAI Sites, a database, or a server-side application runtime.

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

The Open Graph and X image metadata currently uses a relative image URL so the
folder remains portable. Once the final public URL is known, replace
`./og-data-portrait.png` in `index.html` with the full public HTTPS URL for the
best social-link preview compatibility.
