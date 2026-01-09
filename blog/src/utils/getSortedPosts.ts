import type { CollectionEntry } from "astro:content";
import postFilter, { type PostFilterOptions } from "./postFilter";

const getSortedPosts = (
  posts: CollectionEntry<"blog">[],
  filterOptions?: PostFilterOptions
) => {
  return posts
    .filter(post => postFilter(post, filterOptions))
    .sort(
      (a, b) =>
        Math.floor(
          new Date(b.data.modDatetime ?? b.data.pubDatetime).getTime() / 1000
        ) -
        Math.floor(
          new Date(a.data.modDatetime ?? a.data.pubDatetime).getTime() / 1000
        )
    );
};

export default getSortedPosts;
