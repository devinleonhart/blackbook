<template>
  <div id="test-component">
    <h1>
      Props: {{ superfood.name }}
    </h1>
    <h1>
      Store: {{ food }}
    </h1>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex';

  export default {
    name: 'TestComponent',
    props: {
      superfood: {
        required: true,
        type: String
      },
    },
    data() {
      return {};
    },
    computed: {
    ...mapGetters({
        food: 'food'
      }),
    }
  };
</script>

<style lang="scss">
</style>
