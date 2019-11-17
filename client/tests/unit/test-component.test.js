import Vue from 'vue';
import Vuex from 'vuex';
import { shallowMount, createLocalVue } from "@vue/test-utils";
import { __createMocks as createStoreMocks } from '@/store';
import LobbyComponent from "@/components/Lobby";

// Ignore elements we're not testing.
Vue.config.ignoredElements = ['b-field', 'b-input', 'b-button']

// Set up mock store.
jest.mock('@/store');
const localVue = createLocalVue();
localVue.use(Vuex);

describe('LobbyComponent', () => {
  let storeMocks;
  let wrapper;

  // Before each test, mount component with new mocked store.
  beforeEach(() => {
    storeMocks = createStoreMocks();
    wrapper = shallowMount(LobbyComponent, {
      store: storeMocks.store,
      localVue,
    });
  });

  test('is a Vue instance', () => {
    expect(wrapper.isVueInstance()).toBeTruthy();
  });

});
