<template>
  <div class="home">
    <div class="content">
      <img :src="require('@/assets/logo.svg')" />
    </div>
    <div class="content parent">
      <p class="header">
        <router-link to="/">
          <img :src="require('@/assets/left-arrow.svg')" />
        </router-link>
        <span>Deposit</span>
        <span>&nbsp;</span>
      </p>
      <div class="child">
        <p class="title">
          Inform desired
          <strong>amount</strong>
        </p>
        <input v-model="money" type="text" />
        <p class="subtitle">Digite um valor entre $KA 10,00 e $KA 15.000,00</p>
        <button class="outer-link" @click="depositMoney">Deposit</button>
      </div>
    </div>
    <div class="content"></div>
  </div>
</template>
<script>
import { http } from "../http";

export default {
  data() {
    return {
      money: ""
    };
  },

  methods: {
    async depositMoney() {
      let money
      let splitMoney = this.money.split(',')
      if (splitMoney.length > 1) {
        money = splitMoney.join('.')
      } else {
        money = this.money
      }
      http
        .put("api/money/add/" + money)
        .then(response => {
          window.location.href = '/'
        })
        .catch(error => {
          if (error.response.data.msg) {
            alert(error.response.data.msg);
          }
        });
    }
  }
};
</script>
<style lang="scss" scoped>
.parent {
  background-color: #4076ad;
  border-radius: 10px;

  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 5px 1em;
    color: #ffffff;
    font-size: 13px;
    width: 100%;
  }

  .child {
    background-color: #ffffff;
    border-radius: 10px;
    width: 100%;
    padding: 15px;
    display: flex;
    flex-direction: column;
    align-items: center;

    input {
      margin: 1em 0;
      font-size: 30px;
      width: 50%;
      border: none;
      outline: none;
      background-color: rgb(0, 0, 0, 0);
      text-align: center;
    }

    .title,
    strong {
      font-size: 20px;
    }

    .subtitle {
      font-size: 10px;
    }
  }
}

.home {
  width: 100%;
  height: 100%;
  padding: 40px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: center;

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
      }
    }

    .outer-link {
      display: flex;
      justify-content: center;
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
      font-size: 20px;
      text-align: center;
    }
  }
}
</style>
