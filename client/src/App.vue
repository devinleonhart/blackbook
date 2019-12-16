<template>
  <div id="app-component">
    <div class="container is-fluid">
      <router-view></router-view>
    </div>
  </div>
</template>

<script>
  export default {
    name: 'App',
    data() {
      return {};
    },
    beforeCreate: function() {
      let auth = JSON.parse(this.$localStorage.get('auth'));
      if(auth) {
        this.$store.dispatch('restoreSession', auth);
      }
    }
  };
</script>

<style lang="scss">
  *, *:before, *:after {
    box-sizing: border-box;
  }
</style>
