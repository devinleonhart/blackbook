<template>
  <div id="navbar-component">
    <nav class="level">
      <p class="level-left has-text-centered">
        Black Book
      </p>
      <p class="level-right has-text-centered">
        <a
          v-if="user.uid"
          class="link is-info"
          @click="$emit('logout')"
        >
          Logout
        </a>
      </p>
    </nav>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex';

  export default {
    name: 'NavbarComponent',
    props: {},
    data() {
      return {};
    },
    computed: {
    ...mapGetters([
        'user'
      ]),
    }
  };
</script>

<style lang="scss">
</style>

