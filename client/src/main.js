import Vue from 'vue';
import VueRouter from 'vue-router';
import VueLocalStorage from 'vue-localstorage';

import App from './App';
import Character from './components/Character';
import Lobby from './components/Lobby';
import Universe from './components/Universe';

import {
  store
} from './store';

Vue.use(VueRouter);
Vue.use(VueLocalStorage);

// Font Awesome
import { library } from '@fortawesome/fontawesome-svg-core';
import {
  faTimes,
  faArrowUp,
  faLeaf,
  faUserFriends,
} from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
library.add([faTimes, faArrowUp, faLeaf, faUserFriends]);
Vue.component('vue-fontawesome', FontAwesomeIcon);

// Buefy
import Buefy from 'buefy';
import 'buefy/dist/buefy.css';
Vue.use(Buefy, {
  defaultIconComponent: 'vue-fontawesome',
  defaultIconPack: 'fas',
});

// Project-Wide Custom Styling
import './main.scss';

const routes = [
  { path: '/', component: Lobby },
  { path: '/universe/:id', component: Universe, props: true },
  { path: '/character/:id', component: Character, props: true },
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
