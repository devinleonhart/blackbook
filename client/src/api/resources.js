import Vue from 'vue';
import VueLocalStorage from 'vue-localstorage';
import VueResource from 'vue-resource';
import {API_ROOT} from '../config';

Vue.use(VueLocalStorage);
Vue.use(VueResource);

let auth = JSON.parse(Vue.localStorage.get('auth')) || {}
if (auth) {
  Vue.http.headers.common['Accept'] = 'application/json';
  Vue.http.headers.common['access-token'] = auth.accessToken || Vue.http.headers.common['access-token'];
  Vue.http.headers.common['expiry'] = auth.expiry || Vue.http.headers.common['expiry'];
  Vue.http.headers.common['token-type'] = auth.tokenType || Vue.http.headers.common['token-type'];
  Vue.http.headers.common['uid'] = auth.uid || Vue.http.headers.common['uid'];
  Vue.http.headers.common['client'] = auth.client || Vue.http.headers.common['client'];
}

Vue.http.options.root = API_ROOT;

export const SIGN_IN_RESOURCE = Vue.resource(
  'api/v1/auth/sign_in'
);

export const UNIVERSE = Vue.resource(
  'api/v1/universes'
);

