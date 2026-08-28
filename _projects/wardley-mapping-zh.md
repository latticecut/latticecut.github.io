---
title: 沃德利地图
summary: 一个持续扩充的资源集合，用于绘制、重建和探索沃德利地图。
ref: wardley-mapping
lang: zh
permalink: /项目/沃德利地图/
thumbnail: /assets/projects/wardley-mapping/wardley-map-layers-hero-font-firasans-square.png
image: /assets/projects/wardley-mapping/wardley-map-layers-hero-font-firasans.png
image_alt: 三个醒目、分层展开且对齐的沃德利地图图层，分别展示业务版图、团队责任区和战略动向。
hero_image: /assets/projects/wardley-mapping/wardley-map-layers-hero-font-firasans.png
hero_image_alt: 三个醒目、分层展开且对齐的沃德利地图图层，展示在线照片服务的业务版图、团队责任区和战略动向，并由虚线定位线连接。
hero_image_width: 2400
hero_image_height: 2330
hero_image_credit: 改编自 Simon Wardley 的 Finding a path（CC BY-SA 4.0），使用 Wardley-TikZ 与 tikz-network 渲染。
hide_hero_caption: true
type: 工具包
order: 2
updated: 2026-08-26
---

<section class="wardley-introduction" aria-labelledby="wardley-introduction-heading">
  <h2 id="wardley-introduction-heading">地形情报</h2>
  <p>沃德利地图从用户需求出发，展示满足该需求所需的组件，并连接它们之间的依赖关系。随后，再根据各组件的演化程度来确定其位置——从新颖且充满不确定性，直至普及并实现工业化。所得的业务版图可用于讨论演变、制约因素与战略选择。</p>
  <p class="wardley-resource-note">本工具包汇集了绘制地图、根据原始资料重建地图，以及探索地图所揭示信息的实用资源。</p>
</section>

<section class="wardley-resources" aria-labelledby="wardley-resources-heading">
  <header class="wardley-section-header">
    <h2 id="wardley-resources-heading">Wardley-TikZ 资源</h2>
    <p>一套使用结构化、可复用源代码绘制沃德利地图的 LaTeX 工具包。</p>
  </header>

  <a class="wardley-toolkit-action" href="https://github.com/latticecut/wardley-tikz#readme">查看 Wardley-TikZ 工具包 &rarr;</a>

  <ul class="wardley-resource-list">
    <li class="wardley-resource-item">
      <div class="wardley-resource-copy">
        <span class="wardley-resource-link wardley-resource-link-pending">OnlineWardleyMaps 与 Wardley-TikZ 往返转换</span>
        <a class="wardley-resource-translation" href="{{ '/assets/projects/wardley-mapping/wardley-tikz-owm-round-trip.pdf' | relative_url }}" hreflang="en" type="application/pdf">查看英文 PDF &rarr;</a>
      </div>
      <span class="wardley-resource-meta">简体中文 PDF 教程 &middot; 即将推出</span>
    </li>

    <li class="wardley-resource-item">
      <div class="wardley-resource-copy">
        <span class="wardley-resource-link wardley-resource-link-pending">Wardley-TikZ 手册</span>
        <a class="wardley-resource-translation" href="{{ '/assets/projects/wardley-mapping/wardley-tikz-manual.pdf' | relative_url }}" hreflang="en" type="application/pdf">查看英文 PDF &rarr;</a>
      </div>
      <span class="wardley-resource-meta">简体中文 PDF &middot; 即将推出</span>
    </li>

    <li class="wardley-resource-item">
      <div class="wardley-resource-copy">
        <span class="wardley-resource-link wardley-resource-link-pending">《Wardley Maps: Topographical Intelligence in Business》中文版——Simon Wardley，第 1–10 章（编订版）</span>
        <a class="wardley-resource-translation" href="{{ '/assets/projects/wardley-mapping/wardley-reader-draft.pdf' | relative_url }}" hreflang="en" type="application/pdf">查看英文 PDF &rarr;</a>
      </div>
      <span class="wardley-resource-meta">简体中文 PDF &middot; 即将推出</span>
    </li>

    <li class="wardley-resource-item">
      <a class="wardley-resource-link" href="https://github.com/latticecut/wardley-tikz">浏览源代码仓库</a>
      <span class="wardley-resource-meta">GitHub &middot; 英文</span>
    </li>
  </ul>
</section>

{% assign wardley_posts = site.categories.wardleymaps | where: "lang", "zh" %}
{% if wardley_posts.size > 0 %}
<section class="wardley-writing" aria-labelledby="wardley-writing-heading">
  <header class="wardley-section-header">
    <p class="wardley-section-kicker">文章</p>
    <h2 id="wardley-writing-heading">沃德利地图文章</h2>
    <p>深入讨论沃德利地图中特定概念的文章。</p>
  </header>

  <ul class="post-list wardley-writing-list">
    {% for post in wardley_posts %}
      {% include post-list-item.html post=post reading_label="分钟阅读" date_format="%Y年%-m月%-d日" %}
    {% endfor %}
  </ul>
</section>
{% endif %}
