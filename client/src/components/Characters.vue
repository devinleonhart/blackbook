<template>
  <div id="characters-component">
    <ul>
      <b-table
        :data="characters"
        :columns="columns"
      >
      </b-table>
      <b-field label="New Character">
        <b-input v-model="newCharacterName"></b-input>
      </b-field>
      <b-button @click="createCharacter">
        Create Character
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
          }
        ],
        newCharacterName: ''
      };
    },
    computed: {
      ...mapGetters([
        'universe'
      ]),
    },
    methods: {
      createCharacter() {
        this.$store.dispatch('createCharacter', {
          name: this.newCharacterName,
          description: "A brand new character.",
        } );
      }
    }
  };
</script>

<style lang="scss">
</style>
