<template>
  <div id="appfooter-component">
    <footer class="footer">
      <div class="content has-text-centered">
        <p>
          <strong>Black Book</strong> by <a href="https://gitlab.com/starim/black-book">Devin Leonhart</a>. The source code is licensed
          <a href="https://opensource.org/licenses/AGPL-3.0">AGPL 3.0</a>.
        </p>
      </div>
    </footer>
  </div>
</template>

<script>
  export default {
    name: 'AppFooterComponent',
    props: {},
    data() {
      return {};
    },
  };
</script>

<style lang="scss" scoped>
  #appfooter-component {
    footer {
      margin-top: 3em;
      padding: 1em !important;
    }
  }
</style>

