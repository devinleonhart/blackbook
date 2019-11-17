export const LOGIN = (state, payload) => {
  state.auth.accessToken = payload.accessToken || state.auth.accessToken;
  state.auth.expiry = payload.expiry || state.auth.expiry;
  state.auth.tokenType = payload.tokenType || state.auth.tokenType;
  state.auth.uid = payload.uid || state.auth.uid;
  state.auth.client = payload.client || state.auth.client;
};
