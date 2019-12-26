// UNIVERSE
export const UPDATE_UNIVERSE = (state, payload) => {
  state.universe = payload;
};

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
