<template>
  <div id="character-component">
    {{ character }}
  </div>
</template>

<script>
  import { mapGetters } from 'vuex';

  export default {
    name: 'CharacterComponent',
    props: {
      id: {
        type: String,
        required: true,
      },
    },
    data() {
      return {

      };
    },
    computed: {
      ...mapGetters([
        'character'
      ]),
    },
    created: function() {
      this.$store.dispatch('getCharacter', { id: this.id });
    },
  };
</script>

<style lang="scss">
</style>
