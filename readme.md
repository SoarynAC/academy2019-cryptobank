# Sarakin
URL Backend: [heroku](https://soaryn-cryptobank-ruby.herokuapp.com/)
URL Frontend: [heroku](https://soaryn-cryptobank.herokuapp.com/)

# Como usar localmente
Para o frontend, estando na pasta do Vue.js, basta instalar as dependências com ``npm install`` e depois executar o comando ``npm run serve`` (lembrando que ele está configurado para acessar o Mongo Atlas, para alterar isso, basta alterar a URL de requisição no arquivo src/http.js).

Para o backend, estando na pasta do Ruby, basta instalar as dependências com ``bundle install`` e depois executar o comando ``bundle exec rackup config.ru -p [porta desejada]``.

## API
### Autenticação não necessária
- criar conta
``POST`` ``/create_account``
``BODY => { "email": "a", "password": "b" }``
``RESPONSE => JSON``

- logar
``POST`` ``/login/:email``
``BODY => { "password": "b" }``
``RESPONSE => JSON``

### Autenticação necessária via header 'Authorization: Bearer'
- receber confirmação se está logado
``POST`` ``/api/auth``
``RESPONSE => JSON``

- receber seu dinheiro
``GET`` ``/api/money/get``
``RESPONSE => JSON``

- depositar
``PUT`` ``/api/money/add/:quantidade``
``RESPONSE => JSON``

- retirar
``PUT`` ``/api/money/remove/:quantidade``
``RESPONSE => JSON``

- transferir
``PUT`` ``/api/money/transfer/:email/:quantidade``
``RESPONSE => JSON``

- receber todas contas menos a logada
``GET`` ``/api/accounts``
``RESPONSE => JSON``