<template>
  <span>
    <div v-for="post in posts">
      {{ post.date }}
      <a :href="post.path">{{ post.title }}</a>
    </div>
  </span>
</template>

<script>
export default {
  computed: {
    posts() {
      console.log(this.$site.pages);
      return this.$site.pages
        .filter(x => x.type === "post")
        .map(post => ({ ...post, datetime: new Date(post.frontmatter.date) }))
        .map(post => ({ ...post, date: post.datetime.toLocaleDateString() }))
        .sort((a, b) => new Date(b.datetime) - new Date(a.datetime));
    }
  }
};
</script>
