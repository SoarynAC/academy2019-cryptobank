# frozen_string_literal: true

require 'sinatra'
require 'mongoid'
require 'json'
require 'jwt'

require_relative 'models/account'

Mongoid.load! 'mongoid.yml'

Mongoid.raise_not_found_error = false

# Auth class
class JwtAuth
  def initialize(app)
    @app = app
  end

  def call(env)
    bearer = env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)
    payload, _header = JWT.decode bearer, 'pr0b4bly_4_53cur3_h45h_k3y', true, algorithm: 'HS256'

    env[:user] = payload['user']

    @app.call env
  rescue JWT::DecodeError
    [401, { 'Content-Type' => 'text/plain' }, ['A token must be passed.']]
  rescue JWT::ExpiredSignature
    [403, { 'Content-Type' => 'text/plain' }, ['The token has expired.']]
  rescue JWT::InvalidIatError
    [403, { 'Content-Type' => 'text/plain' }, ['The token does not have a valid "issued at" time.']]
  end
end

# Public route
class Public < Sinatra::Base
  post '/create_account' do
    content_type :json

    account = JSON.parse request.body.read
    has_account = Account.find_by(email: account['email'])

    if has_account.nil?
      Account.create(account)
      { msg: 'Conta criada com sucesso!' }.to_json
    else
      halt 400, { 'Content-Type' => 'application/json' },
           { msg: 'Email já cadastrado!' }.to_json
    end
  end

  post '/login/:email' do
    email = params[:email]
    password = JSON.parse(request.body.read)['password']

    account = Account.find_by(email: email, password: password)

    if !account.nil?
      content_type :json
      { token: token(email) }.to_json
    else
      halt 401, { 'Content-Type' => 'application/json' },
           { msg: 'Email ou senha incorretos!' }.to_json
    end
  end

  def token(email)
    JWT.encode payload(email), 'pr0b4bly_4_53cur3_h45h_k3y', 'HS256'
  end

  def payload(email)
    {
      exp: Time.now.to_i + 60 * 60,
      iat: Time.now.to_i,
      user: {
        email: email
      }
    }
  end
end

# Private route
class Api < Sinatra::Base
  use JwtAuth

  get '/money' do
    user = request.env[:user]
    email = user['email'].to_sym

    if !Account.find_by(email: email).nil?
      content_type :json
      { money: Account.find_by(email: email).money }.to_json
    else
      halt 403
    end
  end

  put '/money/add/:amount' do
    user = request.env[:user]
    email = user['email'].to_sym

    unless params['amount']
      halt 400, { 'Content-Type' => 'application/json' },
           { msg: 'Informe o valor!' }.to_json
    end

    if !Account.find_by(email: email).nil?
      content_type :json
      account = Account.find_by(email: email)
      money = account.money

      account.update_attribute(:money, money + params['amount'].to_f)
      { money: account.money }.to_json
    else
      halt 403
    end
  end

  put '/money/remove/:amount' do
    user = request.env[:user]
    email = user['email'].to_sym

    unless params['amount']
      halt 400, { 'Content-Type' => 'application/json' },
           { msg: 'Informe o valor!' }.to_json
    end

    if !Account.find_by(email: email).nil?
      content_type :json
      account = Account.find_by(email: email)
      money = account.money

      account.update_attribute(:money, money - params['amount'].to_f)
      { money: account.money }.to_json
    else
      halt 403
    end
  end

  put '/money/transfer/:email/:amount' do
    user = request.env[:user]
    email = user['email'].to_sym

    if !params['email'] || !params['amount']
      halt 400, { 'Content-Type' => 'application/json' },
           { msg: 'Informe a conta e o valor!' }.to_json
    end

    if !Account.find_by(email: email).nil?
      content_type :json

      account_to = Account.find_by(email: params['email'])

      if !account_to.nil?
        account_from = Account.find_by(email: email)
        money_from = account_from.money
        money_to = account_to.money

        account_from.update_attribute(:money, money_from - params['amount'].to_f)
        account_to.update_attribute(:money, money_to + params['amount'].to_f)
        { money_from: account_from.money,
          money_to: account_to.money }.to_json
      else
        halt 400
      end
    else
      halt 403
    end
  end
end
