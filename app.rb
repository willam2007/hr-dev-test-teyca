# Пример app.rb
require 'sinatra'
require 'sinatra/json'
require 'sequel'

DB = Sequel.sqlite('db/test.db')

require_relative 'models/template'
require_relative 'models/user'
require_relative 'models/product'
require_relative 'models/operation'
require_relative 'services/loyalty_service'

class MyApp < Sinatra::Base
  before do
    content_type 'application/json'
  end

  post '/operation' do
    data = JSON.parse(request.body.read, symbolize_names: true)
    user_id   = data[:user_id]
    positions = data[:positions] || []

    result = LoyaltyService.calculate_operation(user_id, positions)
    json result
  end

  post '/submit' do
    data         = JSON.parse(request.body.read, symbolize_names: true)
    user_id      = data.dig(:user, :id)
    operation_id = data[:operation_id]
    write_off    = data[:write_off].to_f

    result = LoyaltyService.confirm_operation(user_id, operation_id, write_off)
    json result
  end
end

MyApp.run!
