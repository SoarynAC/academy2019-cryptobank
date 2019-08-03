import Vue from "vue";
import App from "./App.vue";
import router from "./router";
import "./registerServiceWorker";

Vue.config.productionTip = false;

// eslint-disable-next-line no-undef
if (getCookie("sarakinToken") == "") {
  document.cookie = "sarakinToken" + "=" + ".";
}

new Vue({
  router,
  render: h => h(App)
}).$mount("#app");
