module.exports = {
  "env": {
    "browser": true,
    "es6": true,
    "node": true
  },
  "extends": [
    "eslint:recommended",
    "plugin:vue/recommended"
  ],
  "rules": {
    "no-empty-pattern": "off",
    "vue/html-indent": ["error", 2],
    "vue/html-self-closing": "off",
    "vue/no-v-html": "off",
    "vue/v-on-style": "off",
    "vue/require-v-for-key": "off",
  }
};
