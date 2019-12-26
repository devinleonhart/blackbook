<template>
  <div id="characters-component">
    <ul>
      <b-table
        :data="characters"
        :columns="columns"
        :checked-rows.sync="checkedRows"
        checkable
        :checkbox-position="'right'"
      >
      </b-table>
      <b-field label="New Character">
        <b-input v-model="newCharacterName"></b-input>
      </b-field>
      <b-button @click="createCharacter">
        Create Character
      </b-button>
      <b-button
        v-if="rowsChecked"
        icon-right="times"
        type="is-danger"
        @click="deleteCharacters"
      >
        Delete Characters
      </b-button>
    </ul>
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
      ...mapGetters([
        'universe'
      ]),
      rowsChecked() {
        return this.checkedRows.length !== 0;
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
      clearChecked() {
        this.checkedRows = [];
      },
    }
  };
</script>

<style lang="scss">
</style>
