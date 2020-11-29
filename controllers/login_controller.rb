# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'

require './controllers/before_controller'

require './services/before_service'

# Controller para Login/logout
class LoginController < BeforeController
  post '/user_login' do
    UserService.login(params[:email], params[:password], session)
    redirect '/profile'
  rescue ArgumentError => e
    return erb :error, locals: { errorMessage: e.message,
                                 url: '/',
                                 document: Document.order(:date).reverse.all }
  end

  get '/logout' do
    session.clear
    redirect '/'
  end
end
