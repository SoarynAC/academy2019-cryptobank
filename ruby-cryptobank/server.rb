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
    if env.fetch('REQUEST_METHOD', '') == 'OPTIONS'
      return [200, { 'Content-Type' => 'application/json',
                     'Access-Control-Allow-Origin' => '*',
                     'Access-Control-Allow-Methods' => '*',
                     'Access-Control-Allow-Headers' => '*' }, [{}.to_json]]
    end

    bearer = env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)
    payload, _header = JWT.decode bearer, 'pr0b4bly_4_53cur3_h45h_k3y', true, algorithm: 'HS256'

    env[:user] = payload['user']

    @app.call env
  rescue JWT::DecodeError
    [401, { 'Content-Type' => 'application/json',
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => '*',
            'Access-Control-Allow-Headers' => '*' }, [{ msg: 'Missing token!' }.to_json]]
  rescue JWT::ExpiredSignature
    [403, { 'Content-Type' => 'application/json',
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => '*',
            'Access-Control-Allow-Headers' => '*' }, [{ msg: 'Token expired!' }.to_json]]
  rescue JWT::InvalidIatError
    [403, { 'Content-Type' => 'application/json',
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => '*',
            'Access-Control-Allow-Headers' => '*' }, [{ msg: 'Invalid token!' }.to_json]]
  end
end

# Public route
class Public < Sinatra::Base

  before do 
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = '*'
    response.headers['Access-Control-Allow-Headers'] = '*'
  end

  options '*' do
    halt 200
  end

  post '/create_account' do
    content_type :json

    account = JSON.parse request.body.read
    has_account = Account.find_by(email: account['email'])

    if has_account.nil?
      Account.create(account)
      { msg: 'Conta criada com sucesso!' }.to_json
    else
      halt 400, { 'Content-Type' => 'application/json' },
           { msg: 'Email already in use!' }.to_json
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
           { msg: 'Wrong email or password!' }.to_json
    end
  end

  def token(email)
    JWT.encode payload(email), 'pr0b4bly_4_53cur3_h45h_k3y', 'HS256'
  end

  def payload(email)
    {
      exp: Time.now.to_i + 7 * 3600,
      iat: Time.now.to_i,
      user: {
        email: email
      }
    }
  end
end

# Private route
class Api < Sinatra::Base

  before do 
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = '*'
    response.headers['Access-Control-Allow-Headers'] = '*'
  end

  use JwtAuth

  options '*' do
    halt 200
  end

  def check_amount(amount)
    if amount >= 10.0 && amount <= 15_000.0
      true
    else
      false
    end
  end

  post '/auth' do
    halt 200, { 'Content-Type' => 'application/json' }, { status: 'authed' }.to_json
  end

  get '/money/get' do
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
    if check_amount(params['amount'].to_f)
      if !Account.find_by(email: email).nil?
        content_type :json
        account = Account.find_by(email: email)
        money = account.money

        account.update_attribute(:money, money + params['amount'].to_f)
        { money: account.money }.to_json
      else
        halt 403
      end
    else
      halt 400, { 'Content-Type' => 'application/json' },
           { msg: 'The value must be between $KA 10,00 and $KA 15.000,00!' }.to_json
    end
  end

  put '/money/remove/:amount' do
    user = request.env[:user]
    email = user['email'].to_sym
    if check_amount(params['amount'].to_f)
      if !Account.find_by(email: email).nil?
        content_type :json
        account = Account.find_by(email: email)
        money = account.money

        if money < params['amount'].to_f
          halt 400, { 'Content-Type' => 'application/json' },
               { msg: 'Not enough money!' }.to_json
        end

        account.update_attribute(:money, money - params['amount'].to_f)
        { money: account.money }.to_json
      else
        halt 403
      end
    else
      halt 400, { 'Content-Type' => 'application/json' },
           { msg: 'The value must be between $KA 10,00 and $KA 15.000,00!' }.to_json
    end
  end

  put '/money/transfer/:email/:amount' do
    user = request.env[:user]
    email = user['email'].to_sym
    if check_amount(params['amount'].to_f)
      if !Account.find_by(email: email).nil?
        content_type :json

        Account.with_session do |session|
          account_to = Account.find_by(email: params['email'])

          if !account_to.nil?
            account_from = Account.find_by(email: email)
            if account_from.money < params['amount'].to_f
              halt 400, { 'Content-Type' => 'application/json' },
                   { msg: 'Not enough money!' }.to_json
            end
            money_from = account_from.money
            money_to = account_to.money

            session.start_transaction
            account_from.update_attribute(:money, money_from - params['amount'].to_f)
            account_to.update_attribute(:money, money_to + params['amount'].to_f)
            session.commit_transaction

            { money_from: account_from.money,
              money_to: account_to.money }.to_json
          else
            halt 400, { 'Content-Type' => 'application/json' },
                 { msg: 'The value must be transfered to an existing account!' }.to_json
          end
        end
      else
        halt 403
      end
    else
      halt 400, { 'Content-Type' => 'application/json' },
           { msg: 'The value must be between $KA 10,00 and $KA 15.000,00!' }.to_json
    end
  end

  get '/accounts' do
    Account.all.to_json
  end
end
