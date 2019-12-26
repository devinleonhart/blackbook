import axios from 'axios';
import Vue from 'vue';
import VueLocalStorage from 'vue-localstorage';
import { API_ROOT } from '../config';

Vue.use(VueLocalStorage);

// Prepare axios with any existing localstorage headers.
let auth = JSON.parse(Vue.localStorage.get('auth')) || {}
let api = axios.create({
  baseURL: API_ROOT ,
  timeout: 1000,
  headers: {
    'Accept': 'application/json',
    ...auth
  }
});

// Refresh axios with headers provided from API.
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

// Delete axios' headers and wipe headers from localstorage.
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

// Inform API of new user.
export const SIGN_IN = (data) => api.post('auth/sign_in', data);

// Inform API of user signout.
export const SIGN_OUT = () => api.delete('auth/sign_out', {
  'access-token': api.defaults.headers['access-token'],
  'client': api.defaults.headers['client'],
  'uid': api.defaults.headers['uid'],
});

// Ask API if user has active session.
export const VALIDATE_USER = () => api.get('auth/validate_token');

// Create a universe.
export const CREATE_UNIVERSE = (data) => api.post('universes', data);

// Get a universe.
export const GET_UNIVERSE = (data) => api.get('universes/' + data.id);

// Get all universes.
export const GET_UNIVERSES = () => api.get('universes');

// Create a character.
export const CREATE_CHARACTER = (data, universe_id) => api.post('universes/' + universe_id + '/characters', data);

