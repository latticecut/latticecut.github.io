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
order: 2
updated: 2026-08-26
---

<section class="wardley-introduction" aria-labelledby="wardley-introduction-heading">
  <h2 id="wardley-introduction-heading">Topographical intelligence</h2>
  <p>A Wardley map starts with a user need, shows the components required to meet it and connects the dependencies between them. Each component is then placed according to how evolved it is—from novel and uncertain to commonplace and industrialised. The result is a landscape you can use to discuss movement, constraints and strategic choices.</p>
  <p class="wardley-resource-note">This toolkit brings together practical resources for drawing maps, reconstructing them from source material and exploring what they reveal.</p>
</section>

<section class="wardley-resources" aria-labelledby="wardley-resources-heading">
  <header class="wardley-section-header">
    <h2 id="wardley-resources-heading">Wardley-TikZ Resources</h2>
    <p>A LaTeX toolkit for drawing Wardley maps from structured, reusable source.</p>
  </header>

  <a class="wardley-toolkit-action" href="https://github.com/latticecut/wardley-tikz#readme">View the Wardley-TikZ toolkit &rarr;</a>

  <ul class="wardley-resource-list">
    <li class="wardley-resource-item">
      <a class="wardley-resource-link" href="{{ '/assets/projects/wardley-mapping/wardley-tikz-owm-round-trip.pdf' | relative_url }}">From OnlineWardleyMaps to Wardley-TikZ and Back</a>
      <span class="wardley-resource-meta">PDF tutorial &middot; 9 pages</span>
    </li>

    <li class="wardley-resource-item">
      <a class="wardley-resource-link" href="{{ '/assets/projects/wardley-mapping/wardley-tikz-manual.pdf' | relative_url }}">Download the manual</a>
      <span class="wardley-resource-meta">PDF &middot; 55 pages</span>
    </li>

    <li class="wardley-resource-item">
      <a class="wardley-resource-link" href="{{ '/assets/projects/wardley-mapping/wardley-reader-draft.pdf' | relative_url }}">Download the Wardley Reader draft</a>
      <span class="wardley-resource-meta">PDF &middot; 310 pages</span>
    </li>

    <li class="wardley-resource-item">
      <a class="wardley-resource-link" href="https://github.com/latticecut/wardley-tikz">Browse the source repository</a>
      <span class="wardley-resource-meta">GitHub</span>
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
