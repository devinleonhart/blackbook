<template>
  <div id="universe-component">
    <div v-if="universe">
      Universe {{ id }}! <br />
      Owner: {{ universe.owner }} <br />
      Collaborators: {{ universe.collaborators }} <br />
      Locations: {{ universe.locations }} <br />
      <characters :characters="universe.characters" />

      <b-button
        icon-right="times"
        type="is-danger"
        @click="deleteUniverse"
      >
        Delete Universe?
      </b-button>
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
    },
    methods: {
      deleteUniverse() {
        this.$buefy.dialog.confirm({
          message: 'Are you sure you want to delete this universe?',
          onConfirm: () => {
            this.$store.dispatch('deleteUniverse', { id: this.id }).then(
            () => {
              this.$buefy.toast.open({
                message: 'Universe Deleted',
                type: 'is-success',
                position: 'is-top-right'
              });
              this.$router.push('/');
            },
            () => {
              this.$buefy.toast.open({
                message: 'Something went wrong!',
                type: 'is-danger',
                position: 'is-top-right'
              });
            });
          }
        });
      },
    }
  };
</script>

<style lang="scss">
</style>
