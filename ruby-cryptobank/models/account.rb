# frozen_string_literal: true

require 'mongoid'

# Account
class Account
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, type: String
  field :password, type: String
  field :money, type: Float, default: 0.0
end
