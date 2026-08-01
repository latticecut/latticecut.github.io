# Mathematics Progress Website — Deployment Package

This guide accompanies:

`ai-mathematical-proof-analysis-website-deploy.zip`

The ZIP is a self-contained copy of the website project, ready to add to the main website repository or upload to a compatible hosting workflow.

## Requirements

- Node.js 22.13.0 or newer
- npm (included with Node.js)

## What is included

- `app/` — page components, layout, global styling, and authentication helper
- `public/` — images, SVGs, downloadable report PDF, CSV data, JSON data, and other static assets
- `dist/` — the current prebuilt site output, including client and server bundles
- `.openai/hosting.json` — OpenAI Sites hosting configuration
- `worker/` and `build/` — hosting and build integration code
- `db/`, `drizzle/`, and `drizzle.config.ts` — database schema and migration configuration; no D1 database is currently attached
- `scripts/` — utilities for rebuilding reference data and recording analysis runs
- `tests/` — rendered-page test
- `package.json` and `package-lock.json` — exact JavaScript dependencies and commands
- TypeScript, Vite, Next.js, PostCSS, and ESLint configuration files
- `README.md` — the original project-specific development notes
- `examples/` — optional D1 database example code

The archive opens directly at the website project root. It does not add an extra enclosing folder.

## What is not included

The following local or reproducible files were deliberately excluded:

- `node_modules/` — approximately 764 MB of installed dependencies; restore these with `npm ci`
- `.git/` — local Git history and repository metadata
- `.wrangler/` — local Wrangler logs and state
- `.vinext/` — local vinext build cache
- `.DS_Store` — macOS metadata

The wider research workspace, temporary image renders, LaTeX source, and analysis working files outside the website folder are also not part of this deployment package. The final report PDF and website-facing datasets are included under `public/`.

## Recommended use: add it to the main website source

1. Extract the ZIP into the intended subdirectory of the main website repository.
2. Open a terminal in the extracted directory.
3. Install the locked dependency versions:

   ```bash
   npm ci
   ```

4. Run the local development server:

   ```bash
   npm run dev
   ```

5. Open the local URL printed in the terminal and check the site.
6. Before deploying, run:

   ```bash
   npm test
   npm run lint
   npm run build
   ```

7. Commit the extracted source files to the main website repository and deploy using that repository's normal workflow.

If the main website is already a separate application, do not blindly overwrite its own `package.json` or configuration. Copy this project into a subdirectory, or integrate `app/` and `public/` selectively while reconciling dependencies and routes.

## Using the included build output

The current compiled output is in `dist/`. This can be useful for inspection or for a deployment system that explicitly accepts vinext/Cloudflare build artifacts. For most source-based hosting platforms, use the project root and let the platform run `npm ci` followed by `npm run build`.

Do not treat `dist/client/` alone as a universally deployable static website: the project also has server output in `dist/server/`.

## Available commands

```bash
npm run dev              # Start local development
npm run build            # Create a production build
npm start                # Start the built application
npm test                 # Build and run the rendered HTML test
npm run lint             # Run ESLint
npm run data:references  # Rebuild the reference map
npm run log:analysis     # Add an analysis-log entry
npm run db:generate      # Generate Drizzle migrations after schema changes
```

## Hosting notes

- The application uses vinext, Vite, Next.js 16, React 19, and Cloudflare tooling.
- `.openai/hosting.json` contains the existing OpenAI Sites project ID.
- No D1 or R2 resource is currently declared in the hosting configuration.
- The package does not contain secrets or a local environment file.
- If deploying somewhere other than OpenAI Sites or Cloudflare-compatible hosting, confirm that the provider supports the generated server runtime.

## Archive verification

The ZIP was tested successfully after creation. Its SHA-256 checksum is:

```text
c0e12434d8ba2adaf8c5c4e0c6808df91c2f4694fd68b4d2fda6a21100abaca1
```

On macOS or Linux, verify it with:

```bash
shasum -a 256 ai-mathematical-proof-analysis-website-deploy.zip
```
