# Tom Hepworth's Blog

This directory contains the source for my personal blog (live at https://tomhepworth.dev).

**Quick answers**
- Where do my blog articles live?: `src/data/blog/` (markdown files)
- Where do my quick notes / sparks live?: `src/data/notes/`
- Where to change the About page?: `src/pages/about.md`
- Where to change the main landing page?: `src/pages/index.astro`

## 🚀 Tech Stack

- Framework: Astro
- Styling: TailwindCSS
- Type checking: TypeScript
- Search: Pagefind
- Deployment: GitHub Pages (see `.github/workflows/deploy.yml`)

## 📁 Project structure (important parts)

```bash
blog/
├── public/                  # Static assets (images, icons, generated files)
├── src/
│   ├── assets/              # Images and icons
│   ├── components/          # Reusable Astro components
│   ├── data/
│   │   ├── blog/            # <--- Blog posts (each post is a Markdown file)
│   │   └── notes/           # <--- Sparks / quick notes
│   ├── layouts/             # Page layouts
│   ├── pages/               # Routes: index.astro, about.md, posts/, sparks/
│   ├── styles/              # CSS / Tailwind
│   └── utils/               # Helper scripts
└── astro.config.ts
```

## How posts are structured
- Each post is a Markdown file under `src/data/blog/`. Files should include frontmatter with fields such as `title`, `pubDatetime`, `tags`, `description` and optionally `featured`, `draft`, `ogImage`.
- The content collections and validation live in `src/content.config.ts`. If you change frontmatter fields, update that file so the site builds correctly.

Example frontmatter (minimum):
```yaml
---
title: "My article title"
pubDatetime: 2025-12-23T12:00:00Z
tags:
	- data-engineering
description: "Short summary for listing and og/meta"
---
```

## About page and landing page
- Edit the About page at `src/pages/about.md`. It's a simple Markdown file — update content and frontmatter there.
- The main landing page is `src/pages/index.astro`. This controls the intro text, featured posts, and overall layout. For layout tweaks, check `src/layouts/Layout.astro`.

## Local development
```bash
pnpm install
pnpm run dev
```

## Build & preview
```bash
pnpm run build
pnpm run preview
```

## Run with Docker
The repo includes a multi-stage [Dockerfile](Dockerfile) (builds with `pnpm`, serves the static `dist/` with Nginx) and a small [docker-compose.yml](docker-compose.yml) wrapper.

Using Docker Compose (easiest):
```bash
docker compose up --build
```
Then open http://localhost.

Using Docker directly:
```bash
docker build -t tomhepworth-blog .
docker run --rm -p 8080:80 tomhepworth-blog
```
Then open http://localhost:8080.

Notes:
- The image is a production build — it won't hot-reload. For local editing, use `pnpm run dev` instead.
- Rebuild the image (`--build` or `docker build` again) whenever content or code changes.

## Deployment
- Deployment is handled by the GitHub Actions workflow at `.github/workflows/deploy.yml` and publishes to GitHub Pages. If you rename the default branch, double-check that workflow and GitHub Pages settings.

## Contributing / checks
- Run `pnpm run format` and `pnpm run lint` before committing. Content-only changes typically don't require changes to code.

## Acknowledgements
- Inspired by the Astro and AstroPaper projects.
