/* eslint-disable no-unused-vars */
import Vue from "vue";
import Router from "vue-router";
import Home from "./views/Home.vue";
import Deposit from "./views/Deposit.vue";
import Pay from "./views/Pay.vue";
import Transfer from "./views/Transfer.vue";
import { http } from "./http";

Vue.use(Router);

let router = new Router({
  mode: "history",
  base: process.env.BASE_URL,
  routes: [
    {
      path: "/",
      name: "home",
      component: Home,
      meta: {
        requiresAuth: true
      }
    },
    {
      path: "/pay",
      name: "pay",
      component: Pay,
      meta: {
        requiresAuth: true
      }
    },
    {
      path: "/transfer",
      name: "transfer",
      component: Transfer,
      meta: {
        requiresAuth: true
      }
    },
    {
      path: "/deposit",
      name: "deposit",
      component: Deposit,
      meta: {
        requiresAuth: true
      }
    },
    {
      path: "/login",
      name: "about",
      component: () => import("./views/Login.vue")
    },
    {
      path: "/create_account",
      name: "create_account",
      component: () => import("./views/CreateAccount.vue")
    }
  ]
});

router.beforeEach((to, from, next) => {
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth);

  if (requiresAuth) {
    http
      .post("api/auth")
      .then(_response => {
        next();
      })
      .catch(_error => {
        next("login");
      });
  } else {
    next();
  }
});

export default router;
