<template>
  <div id="lobby-component">
    <div
      v-if="user.uid"
      class="authenticated"
    >
      <navbar v-on:logout="logout" />
      <universes />
    </div>
    <div
      v-else
      class="unauthenticated"
    >
      <div class="notification">
        <b-field label="Email">
          <b-input v-model="email"></b-input>
        </b-field>
        <b-field label="Password">
          <b-input
            v-model="password"
            type="password"
          ></b-input>
        </b-field>
        <b-button @click="login">
          Log In
        </b-button>
      </div>
    </div>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex';
  import Navbar from './Navbar.vue';
  import Universes from './Universes.vue';

  export default {
    name: 'LobbyComponent',
    components: {
      navbar: Navbar,
      universes: Universes,
    },
    props: {},
    data() {
      return {
        email: "",
        password: "",
      };
    },
    computed: {
    ...mapGetters([
        'user',
      ]),
    },
    methods: {
      login() {
        this.$store.dispatch('loginUser', {
          email: this.email,
          password: this.password
        });
      },
      logout() {
        this.$store.dispatch('logoutUser');
      }
    }
  };
</script>

<style lang="scss">
  .unauthenticated {
    max-width: 650px;
    margin: 6em auto 0;
  }
</style>
