export const SITE = {
  website: "https://astro-paper.pages.dev/", // replace this with your deployed domain
  author: "Tom Hepworth",
  profile: "https://github.com/ThomasHepworth",
  desc: "A blog dedicated to everything I enjoy about Data Engineering, along with my personal hobbies.",
  title: "Tom's Data Engineering blog",
  ogImage: "astropaper-og.jpg",
  lightAndDarkMode: true,
  postPerIndex: 4,
  postPerPage: 4,
  scheduledPostMargin: 15 * 60 * 1000, // 15 minutes
  showArchives: true,
  showBackButton: true, // show back button in post detail
  editPost: {
    enabled: true,
    text: "Suggest Changes",
    url: "https://github.com/ThomasHepworth/PersonalDevTools/blog/",
  },
  dynamicOgImage: true,
  lang: "en",
  timezone: "Etc/Greenwich", // https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
} as const;