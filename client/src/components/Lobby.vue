<template>
  <div id="lobby-component">
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
    <b-button @click="getUniverses">
      Get Universes
    </b-button>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex';

  export default {
    name: 'LobbyComponent',
    props: {},
    data() {
      return {
        email: "",
        password: "",
      };
    },
    computed: {
    ...mapGetters({}),
    },
    methods: {
      login() {
        this.$store.dispatch('loginUser', {
          email: this.email,
          password: this.password
        })
      },
      getUniverses() {
        this.$store.dispatch('getUniverses')
      }
    }
  };
</script>

<style lang="scss">
</style>
