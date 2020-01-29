<template>
  <div id="characters-component">
    <b-table
      :data="characters"
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
          <router-link :to="'/character/' + props.row.id">
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

    <div class="columns controls">
      <div class="column is-half">
        <b-field label="New Character">
          <b-input v-model="newCharacterName"></b-input>
        </b-field>
        <b-button @click="createCharacter">
          Create Character
        </b-button>
      </div>
      <div class="column is-half">
        <b-button
          v-if="twoRowsChecked"
          icon-right="user-friends"
          type="is-primary"
          @click="relateCharacters"
        >
          Relate Characters
        </b-button>
        <b-button
          v-if="rowsChecked"
          icon-right="times"
          type="is-danger"
          @click="deleteCharacters"
        >
          Delete Characters
        </b-button>
      </div>
    </div>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex';

  export default {
    name: 'CharactersComponent',
    props: {
      characters: {
        type: Array,
        default() { return []; }
      },
    },
    data() {
      return {
        checkedRows: [],
        columns: [
          {
            field: 'id',
            label: 'ID',
            width: '40',
            numeric: true
          },
          {
            field: 'name',
            label: 'Name',
          },
        ],
        newCharacterName: ''
      };
    },
    computed: {
      ...mapGetters([]),
      rowsChecked() {
        return this.checkedRows.length !== 0;
      },
      twoRowsChecked() {
        return this.checkedRows.length === 2;
      },
    },
    methods: {
      createCharacter() {
        this.$store.dispatch('createCharacter', {
          name: this.newCharacterName,
          description: "A brand new character.",
        } );
      },
      deleteCharacters() {
        this.$buefy.dialog.confirm({
          message: 'Are you sure you want to delete these characters?',
          onConfirm: () => {
            this.checkedRows.forEach((row) => {
              this.$store.dispatch('deleteCharacter', { id: row.id }).then(
              () => {
                this.$buefy.toast.open({
                  message: `${row.name} Deleted`,
                  type: 'is-success',
                  position: 'is-top-right'
                });
                this.clearChecked();
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
      relateCharacters() {


        this.$buefy.dialog.confirm({
          message: 'Are you sure you want to relate these characters?',
          onConfirm: () => {
            this.$store.dispatch('relateCharacters', {
              "mutual_relationship": {
                "forward_name": `${this.checkedRows[0].name} to ${this.checkedRows[1].name}`,
                "reverse_name": `${this.checkedRows[1].name} to ${this.checkedRows[0].name}`,
                "target_character_id": this.checkedRows[1].id,
              },
              "originating_character_id": this.checkedRows[0].id,
            }).then(
              () => {
                this.$buefy.toast.open({
                  message: 'Characters related!',
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
          }
        });
      },
      clearChecked() {
        this.checkedRows = [];
      },
    }
  };
</script>

<style lang="scss" scoped>
  .controls {
    margin-top: 1em;
  }
</style>
