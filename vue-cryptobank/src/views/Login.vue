<template>
  <div class="form">
    <form @submit.prevent="login">
      <img :src="require('@/assets/logo.svg')">
      <div class="input">
        <label for="email">Email</label>
        <input type="email" v-model="email" placeholder="Type your email">
      </div>
      <div class="input">
        <label for="password">Password</label>
        <input type="password" v-model="password" placeholder="Type your password">
      </div>
      <button type="submit">Login</button>
      <p>New user? <router-link to="/create_account"><a>Create account</a></router-link></p>
    </form>
  </div>
</template>

<script>
import { http } from '../http'

export default {
  data() {
    return {
      jwt: '',
      email: '',
      password: ''
    }
  },

  methods: {
    async login() {
      let vue = this
      let email = this.email
      let password = this.password
      http.post('login/'+email, {
        password: password
      }, {
        method: 'post'
      }).then(response => {
        document.cookie = "sarakinToken" + "=" + response.data.token
        window.location.href = '/'
      }).catch(error => {
        alert(error.data.msg)
      })
    }
  }
}
</script>

<style lang="scss" scoped>
  .form {
    width: 100%;
    height: 100%;
    display: flex;
    justify-content: center;
    align-items: center;

    form {
      display: flex;
      flex-direction: column;
      width: 40%;
      min-width: 260px;

      .input {
        width: 100%;

        label {
          color: #FFFFFF;
          font-size: 15px
        }
      }

      p {
        color: #FFFFFF;
        width: 100%;
        text-align: center;

        a {
          color: #FFFFFF;
          font-weight: bold;
          text-decoration: none;
        }
      }

      input {
        padding: 1em;
        border: none;
        border-radius: 5px;
        background-color: #F2F2F2;
        outline: none;
        width: 100%;
      }

      button {
        background-color: #FA7268;
        border: none;
        border-radius: 5px;
        padding: 1em 1.75em;
        align-self: center;
        color: #FFFFFF;
        font-size: 15px;
        font-weight: bold;
        outline: none;
      }

      input, button {
        margin: 0.75em 0;
      }
    }
  }
</style>
