<template>
  <div>
    <ul v-for="(tag, tagName) in tags">
      <h3>{{ tagName }}</h3>
      <li v-for="post in tag.posts">
        <a :href="post.path">{{ post.title }}</a>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  computed: {
    tags() {
      console.log(this.$tags._metaMap);
      return this.$tags._metaMap;
    }
  }
};
</script>
