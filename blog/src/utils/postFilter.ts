import type { CollectionEntry } from "astro:content";
import { SITE } from "@/config";

const postFilter = ({ data }: CollectionEntry<"blog">) => {
  const isPublishTimePassed =
    Date.now() >
    new Date(data.pubDatetime).getTime() - SITE.scheduledPostMargin;
  if (data.draft) return true; // Show drafts regardless of schedule
  return import.meta.env.DEV || isPublishTimePassed;
};

export default postFilter;
