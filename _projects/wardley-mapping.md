---
title: Wardley Mapping
summary: A growing collection of resources for drawing, reconstructing and exploring Wardley maps.
thumbnail: /assets/projects/wardley-mapping/wardley-map-layers-hero-font-firasans-square.png
image: /assets/projects/wardley-mapping/wardley-map-layers-hero-font-firasans.png
image_alt: Three bold, exploded and aligned Wardley Map planes show the landscape, team ownership and strategic movement.
hero_image: /assets/projects/wardley-mapping/wardley-map-layers-hero-font-firasans.png
hero_image_alt: Three bold, exploded and aligned Wardley Map planes show the online-photo-service landscape, team ownership regions and strategic movements, joined by dashed registration rods.
hero_image_width: 2400
hero_image_height: 2330
hero_image_credit: Adapted from Simon Wardley, Finding a path (CC BY-SA 4.0), rendered with Wardley-TikZ and tikz-network.
hide_hero_caption: true
type: Toolkit
status: Live
order: 2
updated: 2026-08-24
---

<section class="wardley-introduction" aria-labelledby="wardley-introduction-heading">
  <h2 id="wardley-introduction-heading">Topographical intelligence</h2>
  <p>A Wardley map starts with a user need, shows the components required to meet it and connects the dependencies between them. Each component is then placed according to how evolved it is—from novel and uncertain to commonplace and industrialised. The result is a landscape you can use to discuss movement, constraints and strategic choices.</p>
  <p class="wardley-resource-note">This toolkit brings together practical resources for drawing maps, reconstructing them from source material and exploring what they reveal.</p>
  <p class="wardley-artwork-credit">Hero artwork adapted from Simon Wardley, <cite>Finding a path</cite> (CC BY-SA 4.0), rendered with Wardley-TikZ and tikz-network.</p>
</section>

<section class="wardley-resources" aria-labelledby="wardley-resources-heading">
  <header class="wardley-section-header">
    <p class="wardley-section-kicker">Resources</p>
    <h2 id="wardley-resources-heading">Wardley-TikZ</h2>
    <p>The drawing toolkit, its manual and the complete project source are available here.</p>
  </header>

  <ul class="wardley-resource-list">
    <li class="wardley-resource-item">
      <div>
        <p class="wardley-resource-format">Toolkit</p>
        <h3>Wardley-TikZ toolkit</h3>
        <p>A LaTeX toolkit for drawing Wardley maps from structured, reusable source.</p>
      </div>
      <a class="project-status wardley-resource-action" href="https://github.com/latticecut/wardley-tikz#readme">View toolkit</a>
    </li>

    <li class="wardley-resource-item">
      <div>
        <p class="wardley-resource-format">PDF</p>
        <h3>Wardley-TikZ manual</h3>
        <p>A guide to installing the toolkit and building, styling and adapting maps.</p>
      </div>
      <a class="project-status wardley-resource-action" href="{{ '/assets/projects/wardley-mapping/wardley-tikz-manual.pdf' | relative_url }}">Download PDF</a>
    </li>

    <li class="wardley-resource-item">
      <div>
        <p class="wardley-resource-format">Git</p>
        <h3>Toolkit repository</h3>
        <p>Source code, examples, tests and the portable Wardley Map agent skill.</p>
      </div>
      <a class="project-status wardley-resource-action" href="https://github.com/latticecut/wardley-tikz">Browse source</a>
    </li>
  </ul>
</section>

{% assign wardley_posts = site.categories.wardleymaps | where: "lang", "en" %}
{% if wardley_posts.size > 0 %}
<section class="wardley-writing" aria-labelledby="wardley-writing-heading">
  <header class="wardley-section-header">
    <p class="wardley-section-kicker">Writing</p>
    <h2 id="wardley-writing-heading">Wardley Mapping essays</h2>
    <p>Essays that examine particular ideas from Wardley Mapping in more detail.</p>
  </header>

  <ul class="post-list wardley-writing-list">
    {% for post in wardley_posts %}
      {% include post-list-item.html post=post reading_label="min read" date_format="%b %-d, %Y" %}
    {% endfor %}
  </ul>
</section>
{% endif %}
