<template>
  <div id="app-component">
    <div class="container">
      <router-view></router-view>
      <test-component superfood="cheese-whiz"></test-component>
    </div>
  </div>
</template>

<script>
  import TestComponent from './components/TestComponent';

  export default {
    name: 'App',
    components: {
      testComponent: TestComponent
    },
    data() {
      return {};
    }
  };
</script>

<style lang="scss">
  *, *:before, *:after {
    box-sizing: border-box;
  }
</style>
