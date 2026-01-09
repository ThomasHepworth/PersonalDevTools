import type { CollectionEntry } from "astro:content";
import { SITE } from "@/config";

export type PostFilterOptions = {
  includeUnlisted?: boolean;
};

const postFilter = (
  { data }: CollectionEntry<"blog">,
  { includeUnlisted = false }: PostFilterOptions = {}
) => {
  if (data.unlisted && !includeUnlisted) return false;

  const isPublishTimePassed =
    Date.now() >
    new Date(data.pubDatetime).getTime() - SITE.scheduledPostMargin;
  if (data.draft) return true; // Show drafts regardless of schedule
  return import.meta.env.DEV || isPublishTimePassed;
};

export default postFilter;
