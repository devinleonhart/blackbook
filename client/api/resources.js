import Vue from 'vue';
import VueLocalStorage from 'vue-localstorage';
import VueResource from 'vue-resource';

import {API_ROOT} from '../src/config';

Vue.use(VueLocalStorage);
Vue.use(VueResource);

let authToken = Vue.localStorage.get('authToken')
if (authToken) {
  Vue.http.headers.common['Authorization'] = authToken;
}

Vue.http.options.root = API_ROOT;

export const TEST_RESOURCE = Vue.resource(
  'api/v1/test'
);

