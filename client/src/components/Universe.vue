<template>
  <div id="universe-component">
    <div v-if="universe">
      Universe {{ id }}! <br />
      Owner: {{ universe.owner }} <br />
      Collaborators: {{ universe.collaborators }} <br />
      Locations: {{ universe.locations }} <br />
      <characters :characters="universe.characters" />
    </div>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex';
  import Characters from './Characters.vue';

  export default {
    name: 'UniverseComponent',
    components: {
      characters: Characters,
    },
    props: {
      id: {
        type: String,
        required: true,
      },
    },
    data() {
      return {};
    },
    computed: {
      ...mapGetters([
        'universe'
      ]),
    },
    created: function() {
      this.$store.dispatch('getUniverse', { id: this.id });
    }
  };
</script>

<style lang="scss">
</style>
