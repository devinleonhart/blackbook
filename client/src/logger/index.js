const logger = {}

const error = (message) => {
  console.error(message); // eslint-disable-line no-console
};

const log = (message) => {
  console.log(message); // eslint-disable-line no-console
};

logger.install = (Vue) => {

  Vue.mixin({
    created() {
      this.$logger = {
        error,
        log
      };
    }
  });

}

logger.error = error;
logger.log = log;

export default logger
