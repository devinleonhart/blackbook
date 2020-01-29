<template>
  <div id="universe-component">
    <section class="section">
      {{ universe }}
      <characters :characters="universe.characters" />
    </section>
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
    },
    methods: {

    }
  };
</script>

<style lang="scss">
</style>
