/* eslint-disable */

import Vue from 'vue';
import Vuex from 'vuex';

Vue.use(Vuex);

export const getters = {
  universes: jest.fn().mockReturnValue([{"id":1,"name":"universe1","owner":{"id":1,"display_name":"user1"}},{"id":2,"name":"universe2","owner":{"id":1,"display_name":"user1"}},{"id":3,"name":"universe3","owner":{"id":1,"display_name":"user1"}}]),
  user: jest.fn().mockReturnValue({"data":{"id":1,"email":"user1@lionheart.design","provider":"email","display_name":"user1","uid":"user1@lionheart.design","allow_password_change":false}})
};

export const mutations = {

};

export const actions = {

};

export const state = {
  universes: {},
  user: {}
};

// eslint-disable-next-line no-underscore-dangle
export function __createMocks(custom = { getters: {}, mutations: {}, actions: {}, state: {} }) {
  const mockGetters = Object.assign({}, getters, custom.getters);
  const mockMutations = Object.assign({}, mutations, custom.mutations);
  const mockActions = Object.assign({}, actions, custom.actions);
  const mockState = Object.assign({}, state, custom.state);

  return {
    getters: mockGetters,
    mutations: mockMutations,
    actions: mockActions,
    state: mockState,
    store: new Vuex.Store({
      getters: mockGetters,
      mutations: mockMutations,
      actions: mockActions,
      state: mockState,
    }),
  };
}

export const store = __createMocks().store;
