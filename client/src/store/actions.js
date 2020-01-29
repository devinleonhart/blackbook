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

export const deleteUniverse = ({ dispatch }, data) => {
  api.DELETE_UNIVERSE(data)
  .then((response) => {
    api.refreshHeaders(response.headers);
    dispatch('getUniverses');
  }).catch((error) => {
    handleError(error.response, dispatch, 'deleteUniverse');
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
  return new Promise((resolve, reject) => {
    api.CREATE_CHARACTER(data, state.universe.id)
    .then((response) => {
      api.refreshHeaders(response.headers);
      dispatch('getUniverse', { id: state.universe.id });
      resolve();
    }).catch((error) => {
      handleError(error.response, dispatch, 'createCharacter');
      reject();
    });
  });
};

export const deleteCharacter = ({ state, dispatch }, data) => {
  return new Promise((resolve, reject) => {
    api.DELETE_CHARACTER(data)
    .then((response) => {
      api.refreshHeaders(response.headers);
      dispatch('getUniverse', { id: state.universe.id });
      resolve();
    }).catch((error) => {
      handleError(error.response, dispatch, 'deleteCharacter');
      reject();
    });
  });
};

export const getCharacter = ({ commit, dispatch }, data) => {
  api.GET_CHARACTER(data)
  .then((response) => {
    api.refreshHeaders(response.headers);
    commit(types.UPDATE_CHARACTER, response.data.character);
  }).catch((error) => {
    handleError(error.response, dispatch, 'getCharacter');
  });
};

export const getCharacterRelationships = ({ commit, dispatch }, data) => {
  api.GET_CHARACTER_RELATIONSHIPS(data)
  .then((response) => {
    api.refreshHeaders(response.headers);
    commit(types.UPDATE_CHARACTER_RELATIONSHIPS, response.data);
  }).catch((error) => {
    handleError(error.response, dispatch, 'getCharacterRelationships');
  });
};

export const relateCharacters = ({ dispatch, state }, data) => {
  return new Promise((resolve, reject) => {
    api.RELATE_CHARACTERS(data, data.originating_character_id)
    .then((response) => {
      api.refreshHeaders(response.headers);
      dispatch('getUniverse', { id: state.universe.id });
      resolve();
    }).catch((error) => {
      handleError(error.response, dispatch, 'relateCharacters');
      reject();
    });
  });
};

function handleError(error, dispatch, name) {
  if(error.status === 401) {
    dispatch('logoutUser');
  }
  logger.error(`${name} action has failed.`);
  logger.error(error.data.errors);
}
