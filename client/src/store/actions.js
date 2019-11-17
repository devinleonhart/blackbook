import Vue from 'vue';
import VueLocalStorage from 'vue-localstorage';
import api from '../api';
import logger from '../logger';
import * as types from './types';
Vue.use(VueLocalStorage);

// Auth
export const loginUser = ({commit}, data) => {
  api.authenticate(data)
  .then((response) => {
    const auth = refreshHeaders(response.headers);
    if(response.ok) {
      commit(types.LOGIN, auth);
    }
  }, (response) => {
    logger.error("loginUser action has failed.");
    response.body.error ? logger.error(response.body.error) : null;
  });
}

// Universes - GET ALL
export const getUniverses = ({commit}, data) => {
  logger.log(commit);
  api.getUniverses(data)
  .then((response) => {
    const auth = refreshHeaders(response.headers);
    if(response.ok) {
      commit(types.LOGIN, auth);
      logger.log(response.body)
    }
  }, (response) => {
    logger.error("getUniverses action has failed.");
    response.body.error ? logger.error(response.body.error) : null;
  });
}

// Private =============================================================================================================

function refreshHeaders(headers) {
  let auth = {
    accessToken: headers.get('access-token'),
    expiry: headers.get('expiry'),
    tokenType: headers.get('token-type'),
    uid: headers.get('uid'),
    client: headers.get('client'),
  }
  refreshLocalStorage(auth);
  logger.log(auth.accessToken)
  Vue.http.headers.common['Accept'] = 'application/json';
  Vue.http.headers.common['access-token'] = auth.accessToken || Vue.http.headers.common['access-token'];
  Vue.http.headers.common['expiry'] = auth.expiry || Vue.http.headers.common['expiry'];
  Vue.http.headers.common['token-type'] = auth.tokenType || Vue.http.headers.common['token-type'];
  Vue.http.headers.common['uid'] = auth.uid || Vue.http.headers.common['uid'];
  Vue.http.headers.common['client'] = auth.client || Vue.http.headers.common['client'];
  return auth;
}

function refreshLocalStorage(auth) {
  let storage = JSON.parse(Vue.localStorage.get('auth')) || {}
  storage.accessToken = auth.accessToken || storage.accessToken;
  storage.expiry = auth.expiry || storage.expiry;
  storage.tokenType = auth.tokenType || storage.tokenType;
  storage.uid = auth.uid || storage.uid;
  storage.client = auth.client || storage.client;
  Vue.localStorage.set('auth', JSON.stringify(storage));
}
