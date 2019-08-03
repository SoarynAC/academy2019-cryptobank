import axios from 'axios';

// eslint-disable-next-line no-undef
const token = getCookie('sarakinToken');

export const http = axios.create({
  baseURL: `https://soaryn-cryptobank-ruby.herokuapp.com/`,
  headers: {
    "Authorization": 'Bearer ' + token,
    "Accept": "*/*"
  }
})