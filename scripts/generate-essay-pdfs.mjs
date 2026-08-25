#!/usr/bin/env node

import { spawn } from "node:child_process";
import { createHash } from "node:crypto";
import { constants as fsConstants } from "node:fs";
import {
  accessSync,
  copyFileSync,
  existsSync,
  mkdtempSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  renameSync,
  rmSync,
  statSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { basename, dirname, extname, isAbsolute, join, relative, resolve, sep } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const scriptPath = fileURLToPath(import.meta.url);
const repoRoot = resolve(dirname(scriptPath), "..");
const manifestVersion = 2;

function parseArguments(argv) {
  const options = {
    site: join(repoRoot, "_site"),
    source: repoRoot,
    origin: "https://www.amaams.co.uk",
    browser: process.env.CHROME_PATH || "",
    concurrency: 3,
    force: false,
    verifyOnly: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === "--force") {
      options.force = true;
    } else if (argument === "--verify-only") {
      options.verifyOnly = true;
    } else if (["--site", "--source", "--origin", "--browser", "--concurrency"].includes(argument)) {
      const value = argv[index + 1];
      if (!value) throw new Error(`Missing value for ${argument}`);
      options[argument.slice(2).replace("-", "")] = argument === "--concurrency" ? Number(value) : value;
      index += 1;
    } else {
      throw new Error(`Unknown argument: ${argument}`);
    }
  }

  options.site = resolve(options.site);
  options.source = resolve(options.source);
  options.origin = options.origin.replace(/\/$/, "");
  if (!Number.isInteger(options.concurrency) || options.concurrency < 1) {
    throw new Error("--concurrency must be a positive integer");
  }
  return options;
}

function walkFiles(root, predicate = () => true) {
  if (!existsSync(root)) return [];
  const files = [];
  const pending = [root];
  while (pending.length > 0) {
    const current = pending.pop();
    for (const entry of readdirSync(current, { withFileTypes: true })) {
      const path = join(current, entry.name);
      if (entry.isDirectory()) pending.push(path);
      else if (entry.isFile() && predicate(path)) files.push(path);
    }
  }
  return files;
}

function decodeHtmlAttribute(value) {
  return value
    .replace(/&amp;/g, "&")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">");
}

function safePath(root, webPath) {
  let decoded;
  try {
    decoded = decodeURIComponent(webPath.split(/[?#]/, 1)[0]);
  } catch {
    throw new Error(`Invalid encoded path: ${webPath}`);
  }
  const target = resolve(root, decoded.replace(/^\/+/, ""));
  if (target !== root && !target.startsWith(`${root}${sep}`)) {
    throw new Error(`Path escapes its root: ${webPath}`);
  }
  return target;
}

function discoverEssays(siteRoot) {
  const essays = [];
  const seenOutputs = new Set();
  let postCount = 0;
  for (const htmlPath of walkFiles(siteRoot, (path) => extname(path).toLowerCase() === ".html")) {
    const html = readFileSync(htmlPath, "utf8");
    const isPost = /<article\b[^>]*\bitemtype\s*=\s*(["'])http:\/\/schema\.org\/BlogPosting\1/i.test(html);
    const matches = [...html.matchAll(/<a\b[^>]*\bdata-essay-pdf(?:=(?:"[^"]*"|'[^']*'|[^\s>]+))?[^>]*>/gi)];
    if (isPost) {
      postCount += 1;
      if (matches.length !== 1) {
        throw new Error(`Expected exactly one essay PDF link in post page ${htmlPath}; found ${matches.length}`);
      }
    } else if (matches.length > 0) {
      throw new Error(`Essay PDF link found outside a post page: ${htmlPath}`);
    }

    for (const match of matches) {
      const tag = match[0];
      const hrefMatch = tag.match(/\bhref\s*=\s*(["'])(.*?)\1/i);
      const sourceMatch = tag.match(/\bdata-essay-source\s*=\s*(["'])(.*?)\1/i);
      if (!hrefMatch || !sourceMatch) throw new Error(`Incomplete essay PDF metadata in ${htmlPath}`);
      const href = decodeHtmlAttribute(hrefMatch[2]);
      const source = decodeHtmlAttribute(sourceMatch[2]);
      if (!href.startsWith("/assets/essay-pdfs/") || !href.endsWith(".pdf")) {
        throw new Error(`Unexpected essay PDF path in ${htmlPath}: ${href}`);
      }
      if (seenOutputs.has(href)) throw new Error(`Duplicate essay PDF output: ${href}`);
      seenOutputs.add(href);
      essays.push({ html, htmlPath, href, source, isChinese: /<html\b[^>]*\blang=["']zh["']/i.test(html) });
    }
  }
  essays.sort((left, right) => left.href.localeCompare(right.href, "en"));
  if (essays.length === 0) throw new Error(`No essay PDF links found under ${siteRoot}`);
  if (essays.length !== postCount) {
    throw new Error(`Post/PDF link mismatch under ${siteRoot}: ${postCount} posts, ${essays.length} links`);
  }
  return essays;
}

function findBrowser(explicitPath) {
  const absoluteCandidates = [
    explicitPath,
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Chromium.app/Contents/MacOS/Chromium",
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge",
  ].filter(Boolean);
  for (const candidate of absoluteCandidates) {
    try {
      accessSync(candidate, fsConstants.X_OK);
      return candidate;
    } catch {
      // Try the next browser.
    }
  }

  const commandCandidates = [explicitPath, "google-chrome", "chromium", "chromium-browser", "microsoft-edge"].filter(Boolean);
  for (const command of commandCandidates) {
    if (isAbsolute(command)) continue;
    for (const directory of (process.env.PATH || "").split(":")) {
      const candidate = join(directory, command);
      try {
        accessSync(candidate, fsConstants.X_OK);
        return candidate;
      } catch {
        // Try the next PATH entry.
      }
    }
  }
  throw new Error("No supported Chrome or Chromium executable found. Set CHROME_PATH to its executable.");
}

function findCjkFont() {
  const candidates = [
    process.env.CJK_FONT_PATH,
    "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
    "/System/Library/Fonts/Hiragino Sans GB.ttc",
    "/System/Library/Fonts/STHeiti Medium.ttc",
    "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",
    "/usr/share/fonts/opentype/noto/NotoSansCJKsc-Regular.otf",
    "/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc",
  ].filter(Boolean);
  for (const candidate of candidates) {
    try {
      accessSync(candidate, fsConstants.R_OK);
      return candidate;
    } catch {
      // Try the next known CJK font.
    }
  }
  throw new Error("No embeddable CJK font found. Set CJK_FONT_PATH to a Chinese-capable TTF, OTF, or TTC font.");
}

function referencedLocalAssets(html, root) {
  const paths = new Set();
  for (const match of html.matchAll(/\b(?:src|poster)\s*=\s*(["'])(\/[^"]*?)\1/gi)) {
    paths.add(safePath(root, decodeHtmlAttribute(match[2])));
  }
  for (const match of html.matchAll(/<link\b[^>]*\brel\s*=\s*(["'])stylesheet\1[^>]*>/gi)) {
    const hrefMatch = match[0].match(/\bhref\s*=\s*(["'])(\/.*?)\1/i);
    if (hrefMatch) paths.add(safePath(root, decodeHtmlAttribute(hrefMatch[2])));
  }
  return [...paths];
}

function digestFile(path) {
  return createHash("sha256").update(readFileSync(path)).digest("hex");
}

function rendererFingerprint(browserPath, cjkFontPath) {
  const browser = statSync(browserPath);
  const fingerprint = {
    browser: `${basename(browserPath)}:${browser.size}:${Math.trunc(browser.mtimeMs)}`,
    generator: digestFile(scriptPath),
  };
  if (cjkFontPath) fingerprint.cjkFont = `${basename(cjkFontPath)}:${digestFile(cjkFontPath)}`;
  return JSON.stringify(fingerprint);
}

function essayFingerprint(essay, options, renderer) {
  const hash = createHash("sha256");
  hash.update(`essay-pdf-manifest-v${manifestVersion}\0`);
  hash.update(options.origin);
  hash.update("\0");
  hash.update(renderer);
  hash.update("\0");
  hash.update(essay.html);
  const assets = referencedLocalAssets(essay.html, options.site).sort();
  for (const assetPath of assets) {
    hash.update("\0");
    hash.update(relative(options.site, assetPath));
    hash.update("\0");
    hash.update(readFileSync(assetPath));
  }
  return hash.digest("hex");
}

function manifestPath(root) {
  return join(root, "assets", "essay-pdfs", "manifest.json");
}

function readManifest(root) {
  const path = manifestPath(root);
  if (!existsSync(path)) return { version: manifestVersion, entries: {} };
  try {
    const parsed = JSON.parse(readFileSync(path, "utf8"));
    if (parsed.version !== manifestVersion || typeof parsed.entries !== "object") throw new Error("version mismatch");
    return parsed;
  } catch {
    return { version: manifestVersion, entries: {} };
  }
}

function writeManifest(root, entries) {
  const path = manifestPath(root);
  mkdirSync(dirname(path), { recursive: true });
  const stagingPath = `${path}.new-${process.pid}`;
  writeFileSync(stagingPath, `${JSON.stringify({ version: manifestVersion, entries }, null, 2)}\n`);
  renameSync(stagingPath, path);
}

function localizeResources(html, siteRoot, origin, cjkFontPath) {
  let localized = html.replace(/<head(\s[^>]*)?>/i, (tag) => `${tag}\n  <base href="${origin}/">`);
  localized = localized.replace(/\b(src|poster)\s*=\s*(["'])(\/.*?)\2/gi, (_match, attribute, quote, webPath) => {
    const assetPath = safePath(siteRoot, decodeHtmlAttribute(webPath));
    return `${attribute}=${quote}${pathToFileURL(assetPath).href}${quote}`;
  });
  localized = localized.replace(/<link\b[^>]*\brel\s*=\s*(["'])stylesheet\1[^>]*>/gi, (tag) => {
    return tag.replace(/\bhref\s*=\s*(["'])(\/.*?)\1/i, (_match, quote, webPath) => {
      const assetPath = safePath(siteRoot, decodeHtmlAttribute(webPath));
      return `href=${quote}${pathToFileURL(assetPath).href}${quote}`;
    });
  });
  if (cjkFontPath && /<html\b[^>]*\blang=["']zh["']/i.test(localized)) {
    const fontUrl = pathToFileURL(cjkFontPath).href;
    const fontStyle = `<style>
      @font-face {
        font-family: "Essay CJK";
        src: url("${fontUrl}") format("truetype");
        font-style: normal;
        font-weight: 400;
        font-display: block;
      }
      @font-face {
        font-family: "Essay CJK";
        src: url("${fontUrl}") format("truetype");
        font-style: normal;
        font-weight: 700;
        font-display: block;
      }
      html[lang="zh"] body,
      html[lang="zh"] body * {
        font-family: "Essay CJK", sans-serif !important;
      }
    </style>`;
    localized = localized.replace(/<\/head>/i, `  ${fontStyle}\n</head>`);
  }
  return localized;
}

function validateResources(essay, siteRoot) {
  const missing = referencedLocalAssets(essay.html, siteRoot).filter((path) => !existsSync(path));
  if (missing.length > 0) {
    throw new Error(`Missing local resource(s) for ${essay.htmlPath}: ${missing.join(", ")}`);
  }
}

function validatePdf(path, requireEmbeddedUnicodeFont = false) {
  if (!existsSync(path)) throw new Error(`PDF was not created: ${path}`);
  const data = readFileSync(path);
  if (data.length < 4096 || data.subarray(0, 5).toString("ascii") !== "%PDF-") {
    throw new Error(`Invalid or empty PDF: ${path}`);
  }
  const tail = data.subarray(Math.max(0, data.length - 8192)).toString("latin1");
  const trailer = tail.match(/startxref\s+(\d+)\s+%%EOF\s*$/);
  if (!trailer) throw new Error(`PDF has no complete xref trailer: ${path}`);
  const xrefOffset = Number(trailer[1]);
  if (!Number.isSafeInteger(xrefOffset) || xrefOffset <= 0 || xrefOffset >= data.length) {
    throw new Error(`PDF has an invalid xref offset: ${path}`);
  }
  const xrefTarget = data.subarray(xrefOffset, Math.min(data.length, xrefOffset + 48)).toString("latin1");
  if (!/^(?:xref|\d+\s+\d+\s+obj\b)/.test(xrefTarget)) {
    throw new Error(`PDF xref target is invalid: ${path}`);
  }
  if (requireEmbeddedUnicodeFont) {
    const source = data.toString("latin1");
    if (!/\/FontFile(?:2|3)?\b/.test(source) || !/\/ToUnicode\b/.test(source)) {
      throw new Error(`Chinese PDF does not contain an embedded Unicode font: ${path}`);
    }
    const baseFonts = [...source.matchAll(/\/BaseFont\s*\/([^\s/<>()\[\]]+)/g)].map((match) => match[1]);
    if (!baseFonts.some((font) => /(?:Arial.*Unicode|Noto.*CJK|Hiragino|Heiti|Song|Kai|PingFang|WenQuan|CJK)/i.test(font))) {
      throw new Error(`Chinese PDF does not use the configured CJK font: ${path}`);
    }
  }
}

function isValidPdf(path, requireEmbeddedUnicodeFont = false) {
  try {
    validatePdf(path, requireEmbeddedUnicodeFont);
    return true;
  } catch {
    return false;
  }
}

function expectedPdfPaths(essays, root) {
  return new Set(essays.map((essay) => safePath(root, essay.href)));
}

function actualPdfPaths(root) {
  return new Set(walkFiles(join(root, "assets", "essay-pdfs"), (path) => extname(path).toLowerCase() === ".pdf"));
}

function verifyOutputSet(essays, root) {
  const expected = expectedPdfPaths(essays, root);
  const actual = actualPdfPaths(root);
  const missing = [...expected].filter((path) => !actual.has(path));
  const extra = [...actual].filter((path) => !expected.has(path));
  if (missing.length > 0 || extra.length > 0) {
    throw new Error(`Essay PDF set mismatch under ${root}; missing: ${missing.join(", ") || "none"}; extra: ${extra.join(", ") || "none"}`);
  }
  for (const essay of essays) validatePdf(safePath(root, essay.href), essay.isChinese);
}

function verifyManifest(essays, root) {
  const manifest = readManifest(root);
  const expectedHrefs = new Set(essays.map((essay) => essay.href));
  const actualHrefs = new Set(Object.keys(manifest.entries));
  const missing = [...expectedHrefs].filter((href) => !actualHrefs.has(href));
  const extra = [...actualHrefs].filter((href) => !expectedHrefs.has(href));
  if (missing.length > 0 || extra.length > 0) {
    throw new Error(`Essay PDF manifest mismatch under ${root}; missing: ${missing.join(", ") || "none"}; extra: ${extra.join(", ") || "none"}`);
  }
  for (const essay of essays) {
    const entry = manifest.entries[essay.href];
    const outputPath = safePath(root, essay.href);
    if (!entry || typeof entry.input !== "string" || typeof entry.output !== "string") {
      throw new Error(`Invalid essay PDF manifest entry for ${essay.href}`);
    }
    if (entry.output !== digestFile(outputPath)) {
      throw new Error(`Essay PDF checksum mismatch for ${essay.href}`);
    }
  }
}

function removeStaleOutputs(essays, root) {
  const expected = expectedPdfPaths(essays, root);
  for (const path of actualPdfPaths(root)) {
    if (!expected.has(path)) {
      rmSync(path, { force: true });
      process.stdout.write(`Removed  ${relative(root, path)}\n`);
    }
  }
}

function runBrowser(browserPath, argumentsList, expectedPdf) {
  return new Promise((resolvePromise, rejectPromise) => {
    const child = spawn(browserPath, argumentsList, { stdio: ["ignore", "ignore", "pipe"] });
    let stderr = "";
    let settled = false;
    let renderComplete = false;
    let stopError;
    let stopping = false;
    let stableSize = -1;
    let stableChecks = 0;
    let killTimer;
    const startedAt = Date.now();

    const settle = (error) => {
      if (settled) return;
      settled = true;
      clearInterval(monitor);
      clearTimeout(killTimer);
      if (error) rejectPromise(error);
      else resolvePromise();
    };

    const stopBrowser = (error) => {
      if (stopping) return;
      stopping = true;
      stopError = error;
      clearInterval(monitor);
      child.kill("SIGTERM");
      killTimer = setTimeout(() => child.kill("SIGKILL"), 3000);
    };

    const monitor = setInterval(() => {
      if (existsSync(expectedPdf)) {
        const size = statSync(expectedPdf).size;
        if (size >= 4096 && size === stableSize) stableChecks += 1;
        else stableChecks = 0;
        stableSize = size;
        if (stableChecks >= 3 && isValidPdf(expectedPdf)) {
          renderComplete = true;
          stopBrowser();
        }
      }
      if (Date.now() - startedAt > 60000) {
        stopBrowser(new Error(`Browser timed out while creating ${expectedPdf}: ${stderr.trim()}`));
      }
    }, 250);

    child.stderr.on("data", (chunk) => {
      stderr += chunk.toString();
    });
    child.on("error", (error) => {
      stopError = error;
      settle(error);
    });
    child.on("close", (code) => {
      if (stopError) settle(stopError);
      else if (renderComplete || (code === 0 && isValidPdf(expectedPdf))) settle();
      else settle(new Error(`Browser exited with status ${code}: ${stderr.trim()}`));
    });
  });
}

async function renderEssay(essay, index, options, browserPath, cjkFontPath, scratchRoot, previousManifest) {
  validateResources(essay, options.site);
  const outputPath = safePath(options.source, essay.href);
  const previousEntry = previousManifest.entries[essay.href];
  const cachedOutputMatches = previousEntry
    && previousEntry.input === essay.fingerprint
    && existsSync(outputPath)
    && previousEntry.output === digestFile(outputPath);
  if (!options.force && cachedOutputMatches && isValidPdf(outputPath, essay.isChinese)) {
    process.stdout.write(`Current  ${relative(options.source, outputPath)}\n`);
    return;
  }

  mkdirSync(dirname(outputPath), { recursive: true });
  const jobRoot = join(scratchRoot, String(index).padStart(2, "0"));
  mkdirSync(jobRoot, { recursive: true });
  const htmlPath = join(jobRoot, basename(essay.htmlPath));
  const temporaryPdf = join(jobRoot, "essay.pdf");
  const profilePath = join(jobRoot, "chrome-profile");
  let localizedCjkFontPath = "";
  if (essay.isChinese) {
    localizedCjkFontPath = join(jobRoot, `essay-cjk${extname(cjkFontPath) || ".ttf"}`);
    copyFileSync(cjkFontPath, localizedCjkFontPath);
  }
  writeFileSync(htmlPath, localizeResources(essay.html, options.site, options.origin, localizedCjkFontPath));

  await runBrowser(browserPath, [
    "--headless=new",
    "--allow-file-access-from-files",
    "--disable-background-networking",
    "--disable-default-apps",
    "--disable-dev-shm-usage",
    "--disable-extensions",
    "--disable-gpu",
    "--hide-scrollbars",
    "--no-first-run",
    "--no-pdf-header-footer",
    "--print-to-pdf-no-header",
    `--print-to-pdf=${temporaryPdf}`,
    "--run-all-compositor-stages-before-draw",
    `--user-data-dir=${profilePath}`,
    "--virtual-time-budget=5000",
    "--window-size=1280,960",
    pathToFileURL(htmlPath).href,
  ], temporaryPdf);
  validatePdf(temporaryPdf, essay.isChinese);
  const stagingOutput = `${outputPath}.new-${process.pid}-${index}`;
  try {
    copyFileSync(temporaryPdf, stagingOutput);
    validatePdf(stagingOutput, essay.isChinese);
    renameSync(stagingOutput, outputPath);
  } finally {
    rmSync(stagingOutput, { force: true });
  }
  process.stdout.write(`Created  ${relative(options.source, outputPath)}\n`);
}

async function main() {
  const options = parseArguments(process.argv.slice(2));
  const essays = discoverEssays(options.site);

  if (options.verifyOnly) {
    verifyOutputSet(essays, options.site);
    verifyManifest(essays, options.site);
    process.stdout.write(`Verified ${essays.length} essay PDFs in ${options.site}\n`);
    return;
  }

  const browserPath = findBrowser(options.browser);
  const cjkFontPath = essays.some((essay) => essay.isChinese) ? findCjkFont() : "";
  const renderer = rendererFingerprint(browserPath, cjkFontPath);
  for (const essay of essays) essay.fingerprint = essayFingerprint(essay, options, renderer);
  const previousManifest = readManifest(options.source);
  const scratchRoot = mkdtempSync(join(tmpdir(), "latticecut-essay-pdfs-"));
  let nextIndex = 0;
  let firstError;
  try {
    const workers = Array.from({ length: Math.min(options.concurrency, essays.length) }, async () => {
      while (!firstError) {
        const index = nextIndex;
        nextIndex += 1;
        if (index >= essays.length) return;
        try {
          await renderEssay(essays[index], index, options, browserPath, cjkFontPath, scratchRoot, previousManifest);
        } catch (error) {
          firstError ||= error;
          throw error;
        }
      }
    });
    await Promise.allSettled(workers);
    if (firstError) throw firstError;
  } finally {
    rmSync(scratchRoot, { recursive: true, force: true });
  }
  removeStaleOutputs(essays, options.source);
  verifyOutputSet(essays, options.source);
  writeManifest(options.source, Object.fromEntries(essays.map((essay) => {
    const outputPath = safePath(options.source, essay.href);
    return [essay.href, { input: essay.fingerprint, output: digestFile(outputPath) }];
  })));
  verifyManifest(essays, options.source);
  process.stdout.write(`Ready: ${essays.length} essay PDFs\n`);
}

main().catch((error) => {
  process.stderr.write(`${error.stack || error.message}\n`);
  process.exitCode = 1;
});
