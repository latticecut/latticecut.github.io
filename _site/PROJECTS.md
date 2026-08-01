# Adding projects

Projects are Jekyll collection documents stored in `_projects`. A file named
`_projects/example.html` is published at `/projects/example/` and automatically
appears on the Projects landing page.

Use this front matter for an internally hosted project:

```yaml
---
title: Example project
summary: A short description shown on the Projects page.
type: Dashboard
status: Live
order: 10
updated: 2026-08-01
---
```

The document body can contain Markdown, HTML, CSS and JavaScript. Put larger or
reusable files in `assets/projects/example/` and reference them with
`{{ '/assets/projects/example/file.js' | relative_url }}`.

To list a microsite hosted elsewhere, add a collection document containing the
same metadata plus `external_url: https://example.com`. Its card will open the
external site in a new tab. Set `listed: false` for an internal project that
should have a working URL but should not appear on the directory page.
