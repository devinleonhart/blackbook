import {
  SIGN_IN_RESOURCE,
  UNIVERSE
} from './resources';

export default {
  authenticate(data) {
    return SIGN_IN_RESOURCE.save(data);
  },
  getUniverses(data) {
    return UNIVERSE.get(data);
  },
}
