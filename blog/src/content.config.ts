import { defineCollection, z } from "astro:content";
import { glob } from "astro/loaders";
import { SITE } from "@/config";

export const BLOG_PATH = "src/data/blog";
export const NOTES_PATH = "src/data/notes";

const blog = defineCollection({
  loader: glob({ pattern: "**/[^_]*.md", base: `./${BLOG_PATH}` }),
  schema: ({ image }) =>
    z.object({
      author: z.string().default(SITE.author),
      pubDatetime: z.date(),
      modDatetime: z.date().optional().nullable(),
      title: z.string(),
      featured: z.boolean().optional(),
      draft: z.boolean().optional(),
      postCategory: z.string(),
      tags: z.array(z.string()).default(["others"]),
      ogImage: image().or(z.string()).optional(),
      description: z.string(),
      canonicalURL: z.string().optional(),
      hideEditPost: z.boolean().optional(),
      timezone: z.string().optional(),
    }),
});

const notes = defineCollection({
  loader: glob({ pattern: "**/[^_]*.md", base: `./${NOTES_PATH}` }),
  schema: z.object({
    title: z.string(),
    pubDatetime: z.date(),
    type: z.enum(["snippet", "quote", "link", "thought", "til"]).default("thought"),
    source: z.string().optional(), // For quotes - who said it
    link: z.string().url().optional(), // For link type - the URL
    tags: z.array(z.string()).default([]),
    draft: z.boolean().optional(),
  }),
});

export const collections = { blog, notes };