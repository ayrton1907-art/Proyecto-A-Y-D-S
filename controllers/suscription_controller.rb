# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'

require './controllers/before_controller'

require './services/before_service'

# Controller para Suscription
class SuscriptionController < BeforeController
  get '/subscriptions' do
    @page_name = 'Subscripciones'
    @subcriptions = Category.where(users: @current_user)
    @all_categories = Category.except(@subcriptions).all
    erb :subscriptions, layout: @current_layout
  end

  post '/delete_subcriptions' do
    @subscription_to_delete = Category.find(id: params[:idSubcriptions])
    @current_user.remove_category(@subscription_to_delete)
    redirect '/subscriptions'
  end

  post '/new_suscription' do
    @subscription = Category.find(id: params[:id_cat])
    @current_user.add_category(@subscription)
    redirect '/subscriptions'
  end
end
