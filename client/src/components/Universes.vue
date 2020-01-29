<template>
  <div id="universes-component">
    <section class="section">
      <b-table
        :data="universes"
        :striped="true"
        :narrowed="true"
        :hoverable="true"
        :checked-rows.sync="checkedRows"
        checkable
        :checkbox-position="'right'"
      >
        <template slot-scope="props">
          <b-table-column
            field="id"
            label="ID"
            width="40"
            numeric
          >
            {{ props.row.id }}
          </b-table-column>

          <b-table-column
            field="name"
            label="Name"
          >
            <router-link :to="'/universe/' + props.row.id">
              {{ props.row.name }}
            </router-link>
          </b-table-column>
        </template>

        <template slot="empty">
          <section class="section">
            <div class="content has-text-grey has-text-centered">
              <p>
                <b-icon
                  icon="leaf"
                  size="is-large"
                >
                </b-icon>
              </p>
              <p>Nothing here.</p>
            </div>
          </section>
        </template>
      </b-table>


      <div class="controls columns">
        <div class="column is-half">
          <b-field label="New Universe">
            <b-input v-model="newUniverseName"></b-input>
          </b-field>
          <b-button @click="createUniverse">
            Create Universe
          </b-button>
        </div>
        <div class="column if-half">
          <b-button
            v-if="rowsChecked"
            icon-right="times"
            type="is-danger"
            @click="deleteUniverse"
          >
            Delete Universe?
          </b-button>
        </div>
      </div>
    </section>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex';

  export default {
    name: 'UniversesComponent',
    props: {},
    data() {
      return {
        checkedRows: [],
        newUniverseName: '',
      };
    },
    computed: {
      ...mapGetters([
        'universes',
      ]),
      rowsChecked() {
        return this.checkedRows.length !== 0;
      },
    },
    methods: {
      createUniverse() {
        this.$store.dispatch('createUniverse', {
          name: this.newUniverseName,
        });
      },
      deleteUniverse() {
        this.$buefy.dialog.confirm({
          message: 'Are you sure you want to delete this universe?',
          onConfirm: () => {
            this.checkedRows.forEach((row) => {
              this.$store.dispatch('deleteUniverse', { id: row.id }).then(
              () => {
                this.$buefy.toast.open({
                  message: 'Universe Deleted',
                  type: 'is-success',
                  position: 'is-top-right'
                });
                this.checkedRows = [];
              },
              () => {
                this.$buefy.toast.open({
                  message: 'Something went wrong!',
                  type: 'is-danger',
                  position: 'is-top-right'
                });
              });
            });
          }
        });
      },
    }
  };
</script>

<style lang="scss" scoped>
  #universes-component {
    .controls {
      margin-top: 1em;
    }
  }
</style>
