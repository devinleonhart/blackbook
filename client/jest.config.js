module.exports = {
  clearMocks: true,
  moduleFileExtensions: [
    "js",
    "json",
    "vue"
  ],
  moduleNameMapper: {
    "^@/(.*)$": "<rootDir>/src/$1"
  },
  testEnvironment: "jsdom",
  transform: {
    ".*\\.(vue)$": "vue-jest",
    "^.+\\.js$": "<rootDir>/node_modules/babel-jest"
  }
};
