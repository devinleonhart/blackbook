import * as api from '../api';
import logger from '../logger';
import * as types from './types';

// Auth
export const loginUser = ({}, data) => {
  api.SIGN_IN(data)
  .then((response) => {
    api.refreshHeaders(response.headers);
  }, (response) => {
    logger.error("loginUser action has failed.");
    response.body.error ? logger.error(response.body.error) : null;
  });
}

export const logoutUser = ({}) => {
  api.SIGN_OUT()
  .then((response) => {
    api.deleteHeaders(response.headers);
  }, (response) => {
    logger.error("logoutUser action has failed.");
    response.body.error ? logger.error(response.body.error) : null;
  });
}

// Universes - GET ALL
export const getUniverses = ({commit}, data) => {
  api.GET_UNIVERSES(data)
  .then((response) => {
    api.refreshHeaders(response.headers);
    commit(types.UPDATE_UNIVERSES, response.data);
  }, (response) => {
    logger.error("getUniverses action has failed.");
    response.body.error ? logger.error(response.body.error) : null;
  });
}

