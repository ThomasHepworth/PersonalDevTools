# Tom Hepworth's Blog

Personal blog covering data engineering, software engineering, design patterns, and whatever else captures my curiosity.

**Live at:** [tomhepworth.dev](https://tomhepworth.dev)

## 🚀 Tech Stack

- **Framework**: [Astro](https://astro.build/)
- **Styling**: [TailwindCSS](https://tailwindcss.com/)
- **Type Checking**: [TypeScript](https://www.typescriptlang.org/)
- **Search**: [Pagefind](https://pagefind.app/)
- **Deployment**: GitHub Pages

## 📁 Project Structure

```bash
blog/
├── public/           # Static assets
├── src/
│   ├── assets/       # Images and icons
│   ├── components/   # Astro components
│   ├── data/
│   │   ├── blog/     # Blog posts (markdown)
│   │   └── notes/    # Quick notes/sparks
│   ├── layouts/      # Page layouts
│   ├── pages/        # Routes
│   ├── styles/       # Global styles
│   └── utils/        # Utility functions
└── astro.config.ts
```

## 🧞 Commands

| Command | Action |
| :------ | :----- |
| `pnpm install` | Install dependencies |
| `pnpm run dev` | Start dev server at `localhost:4321` |
| `pnpm run build` | Build for production |
| `pnpm run preview` | Preview build locally |
| `pnpm run format` | Format with Prettier |
| `pnpm run lint` | Lint with ESLint |

## 🐳 Docker

```bash
docker compose up -d
```

## 📜 License

Licensed under the MIT License.

---

Built with the [AstroPaper](https://github.com/satnaing/astro-paper) template by [Sat Naing](https://satnaing.dev).
