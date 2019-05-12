<template>
  <div>
    <ul v-for="(category, categoryName) in categories">
      <h3>{{ categoryName }}</h3>
      <li v-for="post in category.posts">
        <a :href="post.path">{{ post.title }}</a>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  computed: {
    categories() {
      return this.$categories._metaMap;
    }
  }
};
</script>
