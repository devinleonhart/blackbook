<template>
  <div id="app-component">
    <div class="container is-fluid">
      <navbar v-on:logout="logout" />
      <router-view></router-view>
    </div>
  </div>
</template>

<script>
  import Navbar from './components/Navbar.vue';

  export default {
    name: 'App',
    components: {
      navbar: Navbar,
    },
    data() {
      return {};
    },
    beforeCreate: function() {
      let auth = JSON.parse(this.$localStorage.get('auth'));
      if(auth) {
        this.$store.dispatch('restoreSession', auth);
      }
    },
    methods: {
      logout() {
        this.$store.dispatch('logoutUser');
      }
    }
  };
</script>

<style lang="scss">
  *, *:before, *:after {
    box-sizing: border-box;
  }
</style>
