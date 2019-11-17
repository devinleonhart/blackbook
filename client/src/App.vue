<template>
  <div id="app-component">
    <div class="container">
      <router-view></router-view>
    </div>
  </div>
</template>

<script>

  export default {
    name: 'App',
    data() {
      return {};
    }
  };
</script>

<style lang="scss">
  *, *:before, *:after {
    box-sizing: border-box;
  }
</style>
