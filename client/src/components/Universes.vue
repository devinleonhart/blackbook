<template>
  <div id="universes-component">
    <div
      v-for="universe in universes"
      class="card"
    >
      <router-link :to="'/universe/' + universe.id">
        <div class="card-content">
          <p class="title">
            {{ universe.name }}
          </p>
        </div>
      </router-link>
    </div>
    <b-field label="New Universe">
      <b-input v-model="newUniverseName"></b-input>
    </b-field>
    <b-button @click="createUniverse">
      Create Universe
    </b-button>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex';

  export default {
    name: 'UniversesComponent',
    props: {},
    data() {
      return {
        newUniverseName: ''
      };
    },
    computed: {
      ...mapGetters([
        'universes'
      ]),
    },
    methods: {
      createUniverse() {
        this.$store.dispatch('createUniverse', {
          name: this.newUniverseName
        });
      }
    }
  };
</script>

<style lang="scss">
</style>
