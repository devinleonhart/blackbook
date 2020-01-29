<template>
  <div id="app-component">
    <div class="container">
      <navbar v-on:logout="logout" />
      <router-view></router-view>
      <appfooter></appfooter>
    </div>
  </div>
</template>

<script>
  import AppFooter from './components/AppFooter.vue';
  import Navbar from './components/Navbar.vue';

  export default {
    name: 'App',
    components: {
      appfooter: AppFooter,
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
