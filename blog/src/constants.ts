import IconMail from "@/assets/icons/IconMail.svg";
import IconGitHub from "@/assets/icons/IconGitHub.svg";
import IconBrandX from "@/assets/icons/IconBrandX.svg";
import IconLinkedin from "@/assets/icons/IconLinkedin.svg";
import IconWhatsapp from "@/assets/icons/IconWhatsapp.svg";
import IconFacebook from "@/assets/icons/IconFacebook.svg";
import IconTelegram from "@/assets/icons/IconTelegram.svg";
import IconPinterest from "@/assets/icons/IconPinterest.svg";
import IconDatabase from "@/assets/icons/IconDatabase.svg";
import IconCode from "@/assets/icons/IconCode.svg";
import IconWrench from "@/assets/icons/IconWrench.svg";
import IconGraduationCap from "@/assets/icons/IconGraduationCap.svg";
import IconStar from "@/assets/icons/IconStar.svg";
import IconBook from "@/assets/icons/IconBook.svg";
import IconPalette from "@/assets/icons/IconPalette.svg";
import { SITE } from "@/config";

export const SOCIALS = [
  {
    name: "Github",
    href: "https://github.com/ThomasHepworth",
    linkTitle: ` ${SITE.title} on Github`,
    icon: IconGitHub,
  },
  {
    name: "LinkedIn",
    href: "https://www.linkedin.com/in/tom-hepworth-b941b1157",
    linkTitle: `${SITE.title} on LinkedIn`,
    icon: IconLinkedin,
  },
] as const;

export const SHARE_LINKS = [
  {
    name: "WhatsApp",
    href: "https://wa.me/?text=",
    linkTitle: `Share this post via WhatsApp`,
    icon: IconWhatsapp,
  },
  {
    name: "Facebook",
    href: "https://www.facebook.com/sharer.php?u=",
    linkTitle: `Share this post on Facebook`,
    icon: IconFacebook,
  },
  {
    name: "X",
    href: "https://x.com/intent/post?url=",
    linkTitle: `Share this post on X`,
    icon: IconBrandX,
  },
  {
    name: "Telegram",
    href: "https://t.me/share/url?url=",
    linkTitle: `Share this post via Telegram`,
    icon: IconTelegram,
  },
  {
    name: "Pinterest",
    href: "https://pinterest.com/pin/create/button/?url=",
    linkTitle: `Share this post on Pinterest`,
    icon: IconPinterest,
  },
  {
    name: "Mail",
    href: "mailto:?subject=See%20this%20post&body=",
    linkTitle: `Share this post via email`,
    icon: IconMail,
  },
] as const;

// Canonical post tags used for filtering on the Posts index.
// Edit this list to the formal categories you want users to filter by.
export const POST_TAGS = [
  { key: 'data-engineering', label: 'Data Engineering', icon: IconDatabase },
  { key: 'software-engineering', label: 'Software Engineering', icon: IconCode },
  { key: 'tooling', label: 'Tooling', icon: IconWrench },
  { key: 'tutorial', label: 'Tutorials', icon: IconGraduationCap },
  { key: 'recommendations', label: 'Recommendations', icon: IconStar },
  { key: 'book-notes', label: 'Books', icon: IconBook },
  { key: 'art', label: 'Art', icon: IconPalette },
] as const;
