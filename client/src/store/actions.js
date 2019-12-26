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
  }).catch((error) => {
    handleError(error.response, dispatch, 'loginUser');
  });
};

export const logoutUser = ({ commit }) => {
  api.SIGN_OUT().finally(() => {
    api.deleteHeaders();
    commit(types.DELETE_USER);
    window.location.href = "/";
  });
};

export const restoreSession = ({ commit, dispatch }, data) => {
  api.VALIDATE_USER(data)
  .then((response) => {
    api.refreshHeaders(response.headers);
    commit(types.UPDATE_USER, response.data.data);
    dispatch('getUniverses');
  }).catch((error) => {
    handleError(error.response, dispatch, 'restoreSession');
  });
};

// Universe
export const createUniverse = ({ state, dispatch }, data) => {
  data.owner_id = state.user.id;
  api.CREATE_UNIVERSE(data)
  .then((response) => {
    api.refreshHeaders(response.headers);
    dispatch('getUniverses');
  }).catch((error) => {
    handleError(error.response, dispatch, 'createUniverse');
  });
};

export const getUniverse = ({ commit, dispatch }, data) => {
  api.GET_UNIVERSE(data)
  .then((response) => {
    api.refreshHeaders(response.headers);
    commit(types.UPDATE_UNIVERSE, response.data.universe);
  }).catch((error) => {
    handleError(error.response, dispatch, 'getUniverse');
  });
};

export const getUniverses = ({ commit, dispatch }) => {
  api.GET_UNIVERSES()
  .then((response) => {
    api.refreshHeaders(response.headers);
    commit(types.UPDATE_UNIVERSES, response.data);
  }).catch((error) => {
    handleError(error.response, dispatch, 'getUniverses');
  });
};

// Character
export const createCharacter = ({ state, dispatch }, data) => {
  api.CREATE_CHARACTER(data, state.universe.id)
  .then((response) => {
    api.refreshHeaders(response.headers);
    dispatch('getUniverse', { id: state.universe.id });
  }).catch((error) => {
    handleError(error.response, dispatch, 'createCharacter');
  });
};

function handleError(error, dispatch, name) {
  if(error.status === 401) {
    dispatch('logoutUser');
  }
  logger.error(`${name} action has failed.`);
  logger.error(error.data.errors);
}
