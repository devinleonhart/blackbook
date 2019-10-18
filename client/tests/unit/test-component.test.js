import Vuex from 'vuex';
import { shallowMount, createLocalVue } from "@vue/test-utils";
import { __createMocks as createStoreMocks } from '@/store';
import TestComponent from "@/components/TestComponent";

// Set up mock store.
jest.mock('@/store');
const localVue = createLocalVue();
localVue.use(Vuex);

describe('TestComponent', () => {
  let storeMocks;
  let wrapper;

  // Before each test, mount component with new mocked store.
  beforeEach(() => {
    storeMocks = createStoreMocks();
    wrapper = shallowMount(TestComponent, {
      propsData: { superfood: "pancakes" },
      store: storeMocks.store,
      localVue,
    });
  });

  test('is a Vue instance', () => {
    expect(wrapper.isVueInstance()).toBeTruthy();
  });

  test('received pancakes', () => {
    expect(wrapper.props()).toEqual({superfood: "pancakes"});
  });

  test('has a functioning store', () => {
    expect(wrapper.html()).toContain('waffles');
  });
});
