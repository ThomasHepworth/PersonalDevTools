export const SITE = {
  website: "https://tomhepworth.dev/", // Custom domain
  author: "Tom Hepworth",
  profile: "https://github.com/ThomasHepworth",
  desc: "Data engineering insights, German expressionism, bouldering, books, and whatever else captures my curiosity.",
  title: "> Tom Hepworth",
  ogImage: "astropaper-og.jpg",
  lightAndDarkMode: true,
  postPerIndex: 4,
  postPerPage: 4,
  scheduledPostMargin: 15 * 60 * 1000, // 15 minutes
  showArchives: false, // Disable the old Archives section
  showAllPosts: true, // Enable the new All Posts section
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