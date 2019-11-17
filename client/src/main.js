import Vue from 'vue';
import VueRouter from 'vue-router';

import App from './App';
import Dashboard from './components/Dashboard';
import Lobby from './components/Lobby';

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

const routes = [
  { path: '/', component: Lobby },
  { path: '/dashboard', component: Dashboard },
  { path: '*', component: Lobby }
];

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
