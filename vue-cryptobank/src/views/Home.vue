<template>
  <div class="home">
    <div class="content">
      <img :src="require('@/assets/logo.svg')" />
      <div class="money">
        <p class="top">Amount available</p>
        <p class="bottom">
          $KA
          <span id="amount">{{getMoneyString}}</span>
        </p>
      </div>
    </div>
    <div class="content">
      <router-link class="outer-link" to="/deposit">
        <img :src="require('@/assets/piggy-bank.svg')" />
        <a>Deposit</a>
      </router-link>
      <router-link class="outer-link" to="/pay">
        <img :src="require('@/assets/pay.svg')" />
        <a>Pay</a>
      </router-link>
      <router-link class="outer-link" to="/transfer">
        <img :src="require('@/assets/surface1.svg')" />
        <a>Transfer</a>
      </router-link>
    </div>
  </div>
</template>
<script>
import { http } from "../http";

export default {
  data() {
    return {
      money: 0.0
    };
  },

  created() {
    let vue = this;
    http.get("api/money/get").then(response => {
      this.money = response.data.money;
    });
  },

  methods: {
    getMoney() {
      http
        .get("api/money/get")
        .then(response => {
          document.querySelector("span.amount").nodeValue = response.data.money;
        })
        .catch(error => {
          alert(error.response.data.msg);
        });
    }
  },

  computed: {
    getMoneyString: function() {
      var cMoney = this.money.toString();
      var splitMoney = cMoney.split(".");
      if (splitMoney.length == 1) {
        cMoney = splitMoney[0] + ",00";
      } else {
        if (splitMoney[1].split("").length == 1) {
          splitMoney[1] = splitMoney[1] + "0";
        } else if (splitMoney[1].split("").length > 2) {
          splitMoney[1] = splitMoney[1].substr(0, 2);
        }
        cMoney = splitMoney.join(",");
      }

      return cMoney;
    }
  }
};
</script>
<style lang="scss" scoped>
.home {
  width: 100%;
  height: 100%;
  padding: 40px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: center;
  background-color: #333333;

  .content {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    width: 100%;

    .money {
      padding: 15px;
      background-color: #ffffff;
      color: #333333;
      width: 100%;
      margin-top: 20px;
      border-radius: 5px;

      .bottom {
        font-size: 40px;
        margin-top: 10px;
        font-weight: bold;

        span {
          font-size: 40px;
          font-weight: bold;
        }
      }
    }

    .outer-link {
      display: flex;
      justify-content: space-between;
      align-items: center;
      width: 100%;
      padding: 10px;
      color: #ffffff;
      text-decoration: none;
      background-color: #fa6f65;
      border: none;
      margin: 0.5em 0;
      border-radius: 5px;
      opacity: 1;

      a {
        color: #ffffff;
        font-size: 20px;
      }
    }
  }
}
</style>
