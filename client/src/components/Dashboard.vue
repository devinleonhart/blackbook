<template>
  <div id="dashboard-component">
    Dashboard!
  </div>
</template>

<script>
  import { mapGetters } from 'vuex';

  export default {
    name: 'DashboardComponent',
    props: {},
    data() {
      return {};
    },
    computed: {
    ...mapGetters({
      }),
    }
  };
</script>

<style lang="scss">
</style>
