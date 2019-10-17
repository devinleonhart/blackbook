import Vue from 'vue';
import VueRouter from 'vue-router';

import App from './App';

import {
  store
} from './store';

Vue.use(VueRouter);

// Buefy
import Buefy from 'buefy';
import 'buefy/dist/buefy.css';
Vue.use(Buefy);

// Font Awesome
import { library } from '@fortawesome/fontawesome-svg-core';
import {
  faUser
} from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
library.add(faUser);
Vue.component('font-awesome-icon', FontAwesomeIcon);

// Project-Wide Custom Styling
import './main.scss';

const routes = [];

const router = new VueRouter({
  routes
});

new Vue({
  router,
  el: '#app',
  components: {
    App
  },
  template: '<App />',
  store
});
