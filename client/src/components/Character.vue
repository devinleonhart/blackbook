<template>
  <div id="character-component">
    {{ character }}
    <hr />
    {{ characterRelationships }}
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
        'character',
        'characterRelationships',
      ]),
    },
    created: function() {
      this.$store.dispatch('getCharacter', { id: this.id });
      this.$store.dispatch('getCharacterRelationships', { id: this.id });
    },
  };
</script>

<style lang="scss">
</style>
