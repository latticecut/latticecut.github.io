# A blog to help me get some ideas down in written down

A blog using on Jekyll, a simple, blog-aware, static site generator perfect for personal, project, or organization sites.

Think of it like a file-based CMS, without all the complexity. I used this tutorial to get started: http://jmcglone.com/guides/github-pages/ I used this tutorial to create a multilingual site: https://www.sylvaindurand.org/making-jekyll-multilingual/

You can find out more info about customizing your Jekyll theme, as well as basic Jekyll usage documentation at [jekyllrb.com](http://jekyllrb.com/)

You can find this multilanguage theme at :
{% include icon-github.html username="sylvaindurand" %} /
[multilingual-jekyll](https://github.com/sylvaindurand/multilingual-jekyll)

You can find the original source code for the Jekyll new theme at:
{% include icon-github.html username="jglovier" %} /
[jekyll-new](https://github.com/jglovier/jekyll-new)

You can find the source code for Jekyll at
{% include icon-github.html username="jekyll" %} /
[jekyll](https://github.com/jekyll/jekyll)

If you build this site locally from a path that contains spaces, use `./scripts/build-site.sh`. It mirrors the repo into a temporary no-spaces directory, installs the pinned gems there, runs Jekyll, and syncs the refreshed `_site` output back.

The same build creates or refreshes a standalone PDF for every published essay
and checks that every download link resolves. It uses an installed Chrome or
Chromium browser; set `CHROME_PATH` if the browser executable is not in a
standard macOS or Linux location. Unchanged PDFs are kept as-is, while changes
to an essay, its local images, the shared layout, or the print styles trigger a
fresh export. Chinese exports also require an embeddable CJK font; common macOS
and Linux locations are detected automatically, or `CJK_FONT_PATH` can point to
a suitable TTF, OTF, or TTC file.

To preview changes locally, run `./scripts/serve-site.sh`, then open
http://127.0.0.1:4000/. Jekyll watches the source files and rebuilds the preview
when they change; stop the server with Control-C. Pass `--livereload` if you
also want the browser to refresh automatically.

The AI mathematics project is generated from the source application in the
Mathematics Progress workspace. Its portable static build is exported to both
`projects/ai-math/` and `_projects/ai-mathematical-proof-analysis-jekyll/`.
After an export, run `ruby scripts/refresh_ai_math_data.rb` to validate the
current corpus, synchronize the two data copies, rebuild the data-city graphic
and create the downloadable bundle. Do not use the older
`update_ai_math_site_shell_2026_08_02.rb` minified-bundle patcher for taxonomy
changes.
