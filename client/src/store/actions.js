import * as api from '../api';
import logger from '../logger';
import * as types from './types';

// User
export const loginUser = ({ commit, dispatch }, data) => {
  api.SIGN_IN(data)
  .then((response) => {
    api.refreshHeaders(response.headers);
    commit(types.UPDATE_USER, response.data.data);
    dispatch('getUniverses');
  }, () => {
    logger.error("loginUser action has failed.");
  });
}

export const logoutUser = ({ commit }) => {
  api.SIGN_OUT()
  .finally(() => {
    api.deleteHeaders();
    commit(types.DELETE_USER);
  });
}

export const restoreSession = ({ commit, dispatch }, data) => {
  api.VALIDATE_USER(data)
  .then((response) => {
    api.refreshHeaders(response.headers);
    commit(types.UPDATE_USER, response.data.data);
    dispatch('getUniverses');
  }, () => {
    logger.error("loginUser action has failed.");
  });
}

// Universe
export const createUniverse = ({ state, dispatch }, data) => {
  data.owner_id = state.user.id;
  api.CREATE_UNIVERSE(data)
  .then((response) => {
    api.refreshHeaders(response.headers);
    dispatch('getUniverses');
  }, () => {
    logger.error("createUniverse action has failed.");
  });
}

export const getUniverses = ({ commit }) => {
  api.GET_UNIVERSES()
  .then((response) => {
    api.refreshHeaders(response.headers);
    commit(types.UPDATE_UNIVERSES, response.data);
  }, () => {
    logger.error("getUniverses action has failed.");
  });
}

