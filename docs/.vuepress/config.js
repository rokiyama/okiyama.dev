module.exports = {
  plugins: ["@vuepress/blog"],
  themeConfig: {
    lastUpdated: "Last Updated",
    nav: [
      { text: "About", link: "/about/" },
      { text: "Tags", link: "/tag/" },
      { text: "Categories", link: "/category/" }
    ]
  },
  locales: {
    "/": {
      lang: "ja-JP",
      title: "blog.rokiyama.dev",
      description: "rokiyama's blog."
    }
  }
};
