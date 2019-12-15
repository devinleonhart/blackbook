import axios from 'axios';
import logger from '../logger';
import Vue from 'vue';
import VueLocalStorage from 'vue-localstorage';
import { API_ROOT } from '../config';

Vue.use(VueLocalStorage);

let auth = JSON.parse(Vue.localStorage.get('auth')) || {}
let api = axios.create({
  baseURL: API_ROOT ,
  timeout: 1000,
  headers: {
    'Accept': 'application/json',
    ...auth
  }
});

export const refreshHeaders = (auth) => {
  let headers = {
    'Accept': 'application/json',
    'access-token': auth['access-token'] || api.defaults.headers['access-token'],
    'client': auth['client'] || api.defaults.headers['client'],
    'expiry': auth['expiry'] || api.defaults.headers['expiry'],
    'token-type': auth['token-type'] || api.defaults.headers['token-type'],
    'uid': auth['uid'] || api.defaults.headers['uid'],
  };
  api = axios.create({
    baseURL: API_ROOT ,
    timeout: 1000,
    headers
  });
  Vue.localStorage.set('auth', JSON.stringify(headers));
};

export const deleteHeaders = () => {
  api = axios.create({
    baseURL: API_ROOT ,
    timeout: 1000,
    headers: {
      'Accept': 'application/json'
    }
  });
  Vue.localStorage.set('auth', null);
};

export const SIGN_IN = (data) => api.post('auth/sign_in', data);
export const SIGN_OUT = () => api.delete('auth/sign_out', {
  'access-token': api.defaults.headers['access-token'],
  'client': api.defaults.headers['client'],
  'uid': api.defaults.headers['uid'],
});

export const GET_UNIVERSES = () => api.get('universes');

