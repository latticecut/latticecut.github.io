from __future__ import annotations

import csv
import shutil
from collections import Counter, defaultdict
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[2]
ANALYSIS = ROOT / "analyses" / "difficulty"
WEBSITE_DATA = ROOT / "website" / "public" / "data"
REPORT = ROOT / "report"

LEDGER = ANALYSIS / "ledger_entries.csv"
BATCHES = (
    ANALYSIS / "scoring_batch_2025.csv",
    ANALYSIS / "scoring_batch_2026a.csv",
    ANALYSIS / "scoring_batch_2026b.csv",
)

SCORE_FIELDS = ("prior_target", "advance", "scope", "resistance")
RATIONALE_FIELDS = (
    "prior_rationale",
    "advance_rationale",
    "scope_rationale",
    "resistance_rationale",
    "age_rationale",
)


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as stream:
        return list(csv.DictReader(stream))


def write_csv(path: Path, rows: list[dict[str, object]], fields: list[str]) -> None:
    with path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def yes(value: str) -> bool:
    return value.strip().lower() in {"1", "true", "yes", "y"}


def number(value: str) -> float | None:
    try:
        return float(value)
    except (TypeError, ValueError):
        return None


def latex(value: object) -> str:
    text = str(value or "").replace("\\", " ")
    replacements = {
        "&": r"\&",
        "%": r"\%",
        "$": r"\$",
        "#": r"\#",
        "_": r"\_",
        "{": r"\{",
        "}": r"\}",
        "~": r"\textasciitilde{}",
        "^": r"\textasciicircum{}",
    }
    for source, target in replacements.items():
        text = text.replace(source, target)
    return " ".join(text.split())


def load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "/System/Library/Fonts/HelveticaNeue.ttc",
        "/System/Library/Fonts/Helvetica.ttc",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for candidate in candidates:
        try:
            return ImageFont.truetype(candidate, size=size, index=1 if bold and candidate.endswith(".ttc") else 0)
        except OSError:
            continue
    return ImageFont.load_default()


def draw_chart(
    months: list[dict[str, object]],
    output: Path,
    *,
    shares: bool,
    cumulative_line: bool = False,
) -> None:
    width, height = 1800, 980
    left, right, top, bottom = 120, 110 if cumulative_line else 60, 140, 145
    plot_w, plot_h = width - left - right, height - top - bottom
    image = Image.new("RGB", (width, height), "white")
    draw = ImageDraw.Draw(image)
    title_font = load_font(38)
    small_font = load_font(19)
    ink = "#424242"
    muted = "#828282"
    line = "#e8e8e8"
    colors = {"Expected": "#b8b8b8", "Difficult": "#2a7ae2", "Superhuman": "#7b2cbf"}

    if shares:
        title = "Monthly challenge-category share"
    elif cumulative_line:
        title = "Monthly audited results and cumulative total"
    else:
        title = "Monthly audited results by challenge category"
    draw.text((left, 40), title, fill=ink, font=title_font)
    legend_x = left
    for label in ("Expected", "Difficult", "Superhuman"):
        draw.rectangle((legend_x, 100, legend_x + 20, 120), fill=colors[label])
        draw.text((legend_x + 30, 96), label, fill=ink, font=small_font)
        legend_x += 200
    if cumulative_line:
        draw.line((legend_x, 110, legend_x + 34, 110), fill=ink, width=5)
        draw.ellipse((legend_x + 12, 104, legend_x + 24, 116), fill=ink)
        draw.text((legend_x + 44, 96), "Cumulative total", fill=ink, font=small_font)

    max_value = 100 if shares else max(1, max(int(row["total"]) for row in months))
    steps = 5
    for step in range(steps + 1):
        value = max_value * step / steps
        y = top + plot_h - plot_h * step / steps
        draw.line((left, y, left + plot_w, y), fill=line, width=2)
        label = f"{value:.0f}%" if shares else f"{value:.0f}"
        draw.text((left - 18, y), label, fill=muted, font=small_font, anchor="rm")

    slot = plot_w / len(months)
    bar_w = slot * 0.62
    for index, row in enumerate(months):
        x0 = left + index * slot + (slot - bar_w) / 2
        x1 = x0 + bar_w
        total = int(row["total"])
        if total:
            values = {
                "Expected": int(row["expected"]),
                "Difficult": int(row["difficult"]),
                "Superhuman": int(row["superhuman"]),
            }
            cumulative = 0.0
            for label in ("Expected", "Difficult", "Superhuman"):
                raw = values[label]
                amount = raw / total * 100 if shares else raw
                y1 = top + plot_h - plot_h * cumulative / max_value
                cumulative += amount
                y0 = top + plot_h - plot_h * cumulative / max_value
                draw.rectangle((x0, y0, x1, y1), fill=colors[label])
            if not shares:
                draw.text(((x0 + x1) / 2, top + plot_h - plot_h * total / max_value - 8),
                          str(total), fill=ink, font=small_font, anchor="mb")
        period = str(row["period"])
        year, month = period.split("-")
        month_names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        label = month_names[int(month) - 1]
        if index == 0 or month == "01":
            label += f"\n{year}"
        draw.multiline_text(((x0 + x1) / 2, top + plot_h + 18), label, fill=ink,
                            font=small_font, anchor="ma", align="center", spacing=2)

    if cumulative_line:
        cumulative_values: list[int] = []
        running_total = 0
        for row in months:
            running_total += int(row["total"])
            cumulative_values.append(running_total)
        cumulative_max = max(1, cumulative_values[-1])
        points = []
        for index, value in enumerate(cumulative_values):
            x = left + (index + 0.5) * slot
            y = top + plot_h - plot_h * value / cumulative_max
            points.append((x, y))
        if len(points) > 1:
            draw.line(points, fill=ink, width=5, joint="curve")
        for x, y in points:
            draw.ellipse((x - 6, y - 6, x + 6, y + 6), fill=ink)
        for step in range(steps + 1):
            value = cumulative_max * step / steps
            y = top + plot_h - plot_h * step / steps
            draw.text((left + plot_w + 18, y), f"{value:.0f}", fill=muted,
                      font=small_font, anchor="lm")

    draw.line((left, top + plot_h, left + plot_w, top + plot_h), fill=ink, width=2)
    image.save(output, optimize=True)


def draw_social_data_portrait(months: list[dict[str, object]], output: Path) -> None:
    """Render the latest seven months as a compact, graph-free block city."""
    width, height = 1800, 945
    image = Image.new("RGB", (width, height), "#fdfdfd")
    draw = ImageDraw.Draw(image)

    ink = "#424242"
    muted = "#828282"
    line = "#e8e8e8"
    pale = "#f6f6f6"
    colors = {"Expected": "#b8b8b8", "Difficult": "#2a7ae2", "Superhuman": "#7b2cbf"}

    brand_font = load_font(25)
    eyebrow_font = load_font(16, bold=True)
    title_font = load_font(66)
    metric_font = load_font(21, bold=True)
    note_font = load_font(17)
    month_font = load_font(14, bold=True)

    recent_months = months[-7:]
    if len(recent_months) != 7:
        raise ValueError("Social-card cityscape requires seven monthly records")
    category_totals = {
        label: sum(int(row[label.lower()]) for row in recent_months)
        for label in ("Expected", "Difficult", "Superhuman")
    }
    result_total = sum(category_totals.values())
    if result_total != sum(int(row["total"]) for row in recent_months):
        raise ValueError("Social-card category totals do not match monthly totals")

    draw.rectangle((0, 0, width, 6), fill=ink)
    draw.text((90, 54), "SuperLattice", fill=ink, font=brand_font)
    draw.text((1710, 61), "DATA CITY · RECENT ACTIVITY", fill=muted,
              font=eyebrow_font, anchor="ra")
    draw.line((90, 112, 1710, 112), fill=line, width=2)

    draw.text((90, 162), "AI and mathematical\nproof progress", fill=ink,
              font=title_font, spacing=3)

    metric_y = 610
    metric_x = 92
    for label in ("Expected", "Difficult", "Superhuman"):
        draw.rounded_rectangle((metric_x, metric_y, metric_x + 22, metric_y + 22),
                               radius=4, fill=colors[label])
        draw.text((metric_x + 34, metric_y - 1), label, fill=ink, font=metric_font)
        metric_x += 180 if label == "Expected" else 190

    draw.rounded_rectangle((90, 690, 645, 783), radius=8, fill=pale)
    draw.text((112, 711), "ONE BLOCK = ONE AUDITED RESULT", fill=ink, font=eyebrow_font)
    draw.multiline_text((112, 739),
                        "Recent monthly clusters form one compact block city.\nA hollow foundation marks an inactive month.",
                        fill=muted, font=note_font, spacing=3)

    # Months sit edge-to-edge on one shared street. Counts determine the mass
    # of each building; categories determine its blocks' colours.
    tile_size, tile_gap, cluster_gap = 50, 7, 8
    ground = 782
    month_names = ("JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL",
                   "AUG", "SEP", "OCT", "NOV", "DEC")
    highlights = {"Expected": "#cecece", "Difficult": "#4c91ea", "Superhuman": "#9149cc"}
    category_fields = (("Expected", "expected"), ("Difficult", "difficult"),
                       ("Superhuman", "superhuman"))

    cluster_specs: list[dict[str, object]] = []
    for row in recent_months:
        total = int(row["total"])
        if total == 0:
            columns = 0
            cluster_width = 30
        elif total == 1:
            columns = 1
        elif total <= 4:
            columns = 2
        elif total <= 9:
            columns = 3
        elif total <= 16:
            columns = 4
        else:
            columns = 5
        if total:
            cluster_width = columns * tile_size + (columns - 1) * tile_gap
        cluster_specs.append({"row": row, "total": total, "columns": columns,
                              "width": cluster_width})

    city_width = sum(float(spec["width"]) for spec in cluster_specs) + cluster_gap * 6
    cursor_x = 1710 - city_width
    draw.rounded_rectangle((cursor_x - 18, ground - 4, 1720, ground + 58),
                           radius=10, fill=pale)

    for spec in cluster_specs:
        row = spec["row"]
        total = int(spec["total"])
        columns = int(spec["columns"])
        cluster_width = float(spec["width"])
        centre_x = cursor_x + cluster_width / 2
        tile_index = 0
        for label, field in category_fields:
            for _ in range(int(row[field])):
                row_index = tile_index // columns
                column = tile_index % columns
                row_count = min(columns, total - row_index * columns)
                row_width = row_count * tile_size + max(row_count - 1, 0) * tile_gap
                x0 = centre_x - row_width / 2 + column * (tile_size + tile_gap)
                y0 = ground - tile_size - row_index * (tile_size + tile_gap)
                draw.rounded_rectangle((x0 + 5, y0 + 5, x0 + tile_size + 5,
                                        y0 + tile_size + 5), radius=4, fill="#e6e6e6")
                draw.rounded_rectangle((x0, y0, x0 + tile_size, y0 + tile_size),
                                       radius=3, fill=colors[label])
                draw.line((x0 + 6, y0 + 6, x0 + tile_size - 6, y0 + 6),
                          fill=highlights[label], width=3)
                tile_index += 1
        if total == 0:
            draw.rounded_rectangle((centre_x - 14, ground - 10, centre_x + 14, ground - 2),
                                   radius=3, fill="#fdfdfd", outline="#c9c9c9", width=2)

        month_number = int(str(row["period"]).split("-")[1])
        draw.text((centre_x, ground + 27), month_names[month_number - 1], fill=muted,
                  font=month_font, anchor="mm")
        cursor_x += cluster_width + cluster_gap

    image.save(output, optimize=True)


def write_data_city_svg(months: list[dict[str, object]], output: Path) -> None:
    """Write a tightly fitted, text-free vector city from the latest data."""
    recent_months = months[-7:]
    if len(recent_months) != 7:
        raise ValueError("Data-city SVG requires seven monthly records")

    colors = {"Expected": "#b8b8b8", "Difficult": "#2a7ae2", "Superhuman": "#7b2cbf"}
    highlights = {"Expected": "#cecece", "Difficult": "#4c91ea", "Superhuman": "#9149cc"}
    category_fields = (("Expected", "expected"), ("Difficult", "difficult"),
                       ("Superhuman", "superhuman"))
    tile_size, tile_gap, cluster_gap = 50, 7, 8
    padding, shadow_offset = 7, 5

    clusters: list[dict[str, object]] = []
    for row in recent_months:
        total = int(row["total"])
        if total == 0:
            continue
        if total == 1:
            columns = 1
        elif total <= 4:
            columns = 2
        elif total <= 9:
            columns = 3
        elif total <= 16:
            columns = 4
        else:
            columns = 5
        rows = (total + columns - 1) // columns
        cluster_width = columns * tile_size + (columns - 1) * tile_gap
        cluster_height = rows * tile_size + (rows - 1) * tile_gap
        clusters.append({"row": row, "total": total, "columns": columns,
                         "width": cluster_width, "height": cluster_height})

    city_width = sum(int(cluster["width"]) for cluster in clusters)
    city_width += cluster_gap * max(len(clusters) - 1, 0)
    city_height = max(int(cluster["height"]) for cluster in clusters)
    width = city_width + 2 * padding + shadow_offset
    height = city_height + 2 * padding + shadow_offset
    ground = padding + city_height
    cursor_x = padding
    block_count = 0

    svg = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" '
        f'width="{width}" height="{height}" fill="none">',
    ]
    for cluster in clusters:
        row = cluster["row"]
        total = int(cluster["total"])
        columns = int(cluster["columns"])
        cluster_width = int(cluster["width"])
        centre_x = cursor_x + cluster_width / 2
        tile_index = 0
        svg.append(f'  <g data-period="{row["period"]}">')
        for label, field in category_fields:
            for _ in range(int(row[field])):
                row_index = tile_index // columns
                column = tile_index % columns
                row_count = min(columns, total - row_index * columns)
                row_width = row_count * tile_size + max(row_count - 1, 0) * tile_gap
                x = centre_x - row_width / 2 + column * (tile_size + tile_gap)
                y = ground - tile_size - row_index * (tile_size + tile_gap)
                svg.append(
                    f'    <rect x="{x + shadow_offset:g}" y="{y + shadow_offset:g}" '
                    f'width="{tile_size}" height="{tile_size}" rx="4" fill="#e6e6e6"/>'
                )
                svg.append(
                    f'    <rect x="{x:g}" y="{y:g}" width="{tile_size}" height="{tile_size}" '
                    f'rx="3" fill="{colors[label]}"/>'
                )
                svg.append(
                    f'    <path d="M{x + 6:g} {y + 6:g}H{x + tile_size - 6:g}" '
                    f'stroke="{highlights[label]}" stroke-width="3" stroke-linecap="round"/>'
                )
                tile_index += 1
                block_count += 1
        svg.append("  </g>")
        cursor_x += cluster_width + cluster_gap
    svg.append("</svg>")

    expected_blocks = sum(int(row["total"]) for row in recent_months)
    if block_count != expected_blocks:
        raise ValueError(f"Data-city SVG block mismatch: {block_count} != {expected_blocks}")
    output.write_text("\n".join(svg) + "\n", encoding="utf-8")


ledger_rows = read_csv(LEDGER)
ledger_by_id = {row["id"]: row for row in ledger_rows}
if len(ledger_by_id) != 64:
    raise ValueError(f"Expected 64 unique ledger entries, found {len(ledger_by_id)}")

assessment_rows: list[dict[str, str]] = []
for path in BATCHES:
    if not path.exists():
        raise FileNotFoundError(f"Missing scoring batch: {path}")
    assessment_rows.extend(read_csv(path))

assessment_by_id: dict[str, dict[str, str]] = {}
for row in assessment_rows:
    entry_id = row["id"]
    if entry_id in assessment_by_id:
        raise ValueError(f"Duplicate scored ID: {entry_id}")
    assessment_by_id[entry_id] = row

missing = set(ledger_by_id) - set(assessment_by_id)
extra = set(assessment_by_id) - set(ledger_by_id)
if missing or extra:
    raise ValueError(f"Scoring coverage mismatch; missing={sorted(missing)}, extra={sorted(extra)}")

merged: list[dict[str, object]] = []
for ledger in ledger_rows:
    scored = assessment_by_id[ledger["id"]]
    components = {field: int(scored[field]) for field in SCORE_FIELDS}
    if components["prior_target"] not in (0, 1) or components["advance"] not in (0, 1, 2):
        raise ValueError(f"Invalid component score for {ledger['id']}: {components}")
    if components["scope"] not in (0, 1) or components["resistance"] not in (0, 1):
        raise ValueError(f"Invalid component score for {ledger['id']}: {components}")
    score = sum(components.values())
    if score != int(scored["score"]):
        raise ValueError(f"Score arithmetic mismatch for {ledger['id']}: {score} != {scored['score']}")
    provisional = yes(scored.get("provisional", ""))
    framing_text = scored.get("framing_year", "").strip()
    solution_text = scored.get("solution_year", "").strip()
    framing_year = int(framing_text) if framing_text else None
    solution_year = int(solution_text) if solution_text else None
    if framing_year is not None and solution_year is not None and solution_year < framing_year:
        raise ValueError(f"Solution predates framing for {ledger['id']}")
    age = (
        (solution_year - framing_year) / 10
        if framing_year is not None and solution_year is not None
        else None
    )
    reported_age = number(scored.get("age_decades", ""))
    if reported_age is not None and (age is None or abs(reported_age - age) > 0.051):
        raise ValueError(
            f"Duration mismatch for {ledger['id']}: reported={reported_age}, derived={age}"
        )
    superhuman = (
        components["prior_target"] == 1
        and components["advance"] == 2
        and not provisional
        and age is not None
        and age >= 1.0
    )
    category = "Superhuman" if superhuman else "Difficult" if score >= 3 else "Expected"
    merged.append({
        "id": ledger["id"],
        "period": ledger["period"],
        **components,
        "difficulty_score": score,
        "category": category,
        "framing_year": framing_text,
        "solution_year": solution_text,
        "age_decades": f"{age:.1f}" if age is not None else "",
        "provisional": "1" if provisional else "0",
        "description": ledger["description"],
        "anchor_claim": scored.get("anchor_claim", ""),
        **{field: scored.get(field, "") for field in RATIONALE_FIELDS},
        "coding_confidence": scored.get("coding_confidence", ""),
    })

output_fields = [
    "id", "period", "prior_target", "advance", "scope", "resistance",
    "difficulty_score", "category", "framing_year", "solution_year", "age_decades",
    "provisional", "description", "anchor_claim", *RATIONALE_FIELDS, "coding_confidence",
]
write_csv(ANALYSIS / "difficulty_assessments.csv", merged, output_fields)
write_csv(ANALYSIS / "difficulty_scored_entries.csv", merged, output_fields)
write_csv(WEBSITE_DATA / "difficulty_scored_entries.csv", merged, output_fields)

periods = read_csv(REPORT / "takeoff_counts_jan2025.csv")
by_period: dict[str, list[dict[str, object]]] = defaultdict(list)
for row in merged:
    by_period[str(row["period"])].append(row)

monthly: list[dict[str, object]] = []
for source in periods:
    period = source["period"][:7]
    entries = by_period[period]
    counts = Counter(str(row["category"]) for row in entries)
    total = len(entries)
    monthly.append({
        "period": period,
        "expected": counts["Expected"],
        "difficult": counts["Difficult"],
        "superhuman": counts["Superhuman"],
        "total": total,
        "non_expected_share": f"{(counts['Difficult'] + counts['Superhuman']) / total:.6f}" if total else "0.000000",
        "mean_score": f"{sum(int(row['difficulty_score']) for row in entries) / total:.3f}" if total else "0.000",
    })

monthly_fields = ["period", "expected", "difficult", "superhuman", "total", "non_expected_share", "mean_score"]
write_csv(ANALYSIS / "difficulty_monthly_breakdown.csv", monthly, monthly_fields)
write_csv(WEBSITE_DATA / "difficulty_monthly_breakdown.csv", monthly, monthly_fields)

method = (
    "Hybrid research-challenge metric. D = P + A + S + R (0-5). "
    "P prior target (0/1): the exact question, conjecture, record, or quantitative frontier is documented in a source predating the AI work. "
    "A advance (0-2): 0 narrow or unquantified extension; 1 material improvement, new theorem, construction, counterexample, or substantial subcase; 2 complete proof/disproof, classification, matching optimum, sharp endpoint, or removal of the central condition. "
    "S scope (0/1): a uniform or worst-case result over an unbounded or genuinely general class. "
    "R demonstrated resistance (0/1): at least two independent pre-solution attempts at the exact target, or a predeclared target-specific comparison with at least five independent runs or systems and no more than 20 percent success. "
    "Expected has D=0-2; Difficult has D=3-5. Superhuman overrides the base label when P=1, A=2, the claim is non-provisional, and at least 1.0 decade elapsed from precise problem framing to solution. A=2 operationalizes complete settlement of the anchor claim; it is not a publication-status judgment. Duration is derived mechanically from the recorded framing and solution years. "
    "Verification, AI autonomy, prestige, proof length, and compute are recorded separately and do not add difficulty points."
)
for path in (ANALYSIS / "difficulty_method.txt", WEBSITE_DATA / "difficulty_method.txt"):
    path.write_text(method + "\n", encoding="utf-8")

draw_chart(monthly, ANALYSIS / "figure1_stacked_challenge_counts.png", shares=False)
draw_chart(monthly, ANALYSIS / "figure1_stacked_challenge_share.png", shares=True)
draw_chart(
    monthly,
    REPORT / "cumulative_takeoff_jan2025.png",
    shares=False,
    cumulative_line=True,
)
portrait = WEBSITE_DATA.parent / "og-data-portrait.png"
draw_social_data_portrait(monthly, portrait)
shutil.copyfile(portrait, REPORT / portrait.name)
data_city = WEBSITE_DATA.parent / "data-city.svg"
write_data_city_svg(monthly, data_city)
shutil.copyfile(data_city, REPORT / data_city.name)

counts = Counter(str(row["category"]) for row in merged)
mean_score = sum(int(row["difficulty_score"]) for row in merged) / len(merged)
(REPORT / "difficulty_summary.tex").write_text(
    "\n".join([
        rf"\newcommand{{\ExpectedCount}}{{{counts['Expected']}}}",
        rf"\newcommand{{\DifficultCount}}{{{counts['Difficult']}}}",
        rf"\newcommand{{\SuperhumanCount}}{{{counts['Superhuman']}}}",
        rf"\newcommand{{\MeanDifficultyScore}}{{{mean_score:.1f}}}",
        rf"\newcommand{{\TotalScoredEntries}}{{{len(merged)}}}",
        "",
    ]),
    encoding="utf-8",
)

lines = [
    r"\begin{landscape}",
    r"\section{Entry-level challenge scores}",
    r"\fontsize{7.5}{8.6}\selectfont",
    r"\setlength{\tabcolsep}{3.0pt}",
    r"\renewcommand{\arraystretch}{1.08}",
    r"\begin{longtable}{@{}L{14mm}L{91mm}C{25mm}C{12mm}L{43mm}@{}}",
    r"\caption{Hybrid challenge scores for all audited ledger entries. Components are prior target (P), advance (A), scope (S), and demonstrated resistance (R).}\label{tab:difficulty-scores}\\",
    r"\toprule",
    r"\textbf{ID} & \textbf{Anchor claim} & \textbf{P/A/S/R} & \textbf{Score} & \textbf{Category} \\",
    r"\midrule",
    r"\endfirsthead",
    r"\multicolumn{5}{l}{\textit{Table \thetable{} continued from previous page}}\\",
    r"\toprule",
    r"\textbf{ID} & \textbf{Anchor claim} & \textbf{P/A/S/R} & \textbf{Score} & \textbf{Category} \\",
    r"\midrule",
    r"\endhead",
    r"\midrule\multicolumn{5}{r}{\textit{Continued on next page}}\\",
    r"\endfoot",
    r"\bottomrule",
    r"\endlastfoot",
]
for index, row in enumerate(merged):
    category = str(row["category"])
    if category == "Superhuman":
        category += f" ({row['age_decades']} decades)"
    if str(row["provisional"]) == "1":
        category += " (provisional)"
    component_text = "/".join(str(row[field]) for field in SCORE_FIELDS)
    prefix = r"\rowcolor{PaleBlue}" if index % 2 else ""
    if prefix:
        lines.append(prefix)
    lines.append(
        f"{latex(row['id'])} & {latex(row['anchor_claim'])} & {component_text} & "
        f"{row['difficulty_score']} & {latex(category)} \\\\" 
    )
lines.extend([r"\end{longtable}", r"\end{landscape}", ""])
(REPORT / "difficulty_scores_table.tex").write_text("\n".join(lines), encoding="utf-8")

print(
    f"Scored {len(merged)} entries: Expected={counts['Expected']}, "
    f"Difficult={counts['Difficult']}, Superhuman={counts['Superhuman']}, mean={mean_score:.2f}"
)
