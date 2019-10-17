<template>
  <div id="test-component">
    <h1>
      {{food}}
    </h1>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex';

  export default {
    name: 'TestComponent',
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
