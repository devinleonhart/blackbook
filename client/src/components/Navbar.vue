<template>
  <div id="navbar-component">
    <nav class="level">
      <p class="brand level-left">
        <router-link :to="'/'">
          Black Book
          <b-icon
            icon="book"
            size="is-large"
          >
          </b-icon>
        </router-link>
      </p>
      <p class="level-right">
        <a
          v-if="user.uid"
          class="link is-info"
          @click="$emit('logout')"
        >
          <a class="button is-light">
            Log Out
          </a>
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

<style lang="scss" scoped>
  #navbar-component {
    color: #0C0C0C;
    a {
      color: #0C0C0C;
    }
    .brand {
      font-size: 1.5em;
    }
  }
</style>

