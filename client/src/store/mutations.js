// UNIVERSE
export const UPDATE_UNIVERSES = (state, payload) => {
  state.universes = payload;
};

// USER
export const DELETE_USER = (state) => {
  state.user = {};
};

export const UPDATE_USER = (state, payload) => {
  state.user = payload;
};
