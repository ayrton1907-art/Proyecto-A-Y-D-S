# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'
require './controllers/category_controller'
require './controllers/document_controller'
require './controllers/login_controller'
require './controllers/notification_controller'
require './controllers/suscription_controller'
require './controllers/user_controller'

# Clase principal
class App < Sinatra::Base
  register Sinatra::ConfigFile

  use CategoryController
  use DocumentController
  use LoginController
  use NotificationController
  use SuscriptionController
  use UserController

  config_file 'config/config.yml'

  configure :development, :production do
    enable :logging
    enable :session
    set :session_secret, '5fdh4h8f4jghne27w84ew4r882&(asd/&h$gfj&hdkjfjew48y' \
    't4hgrd56g8u84gfmjhdmhh,xg544ncd'
    set :sessions, true
    set :server, 'thin'
    set :sockets, []
  end

  get '/' do
    logger.info 'params'
    logger.info params
    logger.info '--------------'
    logger.info session['session_id']
    logger.info session.inspect
    logger.info 'Configurations'
    logger.info settings.db_adapter
    logger.info '--------------'
    @document = Document.order(:date).reverse.all
    erb :index
  end

  before do
    if session[:is_login]
      @current_user = User.find(id: session[:user_id])
      @notification = NotificationUser.where(
        user_id: @current_user.id,
        seen: 'f'
      )
      @count_notifications = 0
      @notification&.each { |_element| @count_notifications += 1 }
      @page = request.path_info
      @current_layout = session[:type] ? :layout_admin : :layout_users
    end
    @url_admin = ['/all_category', '/all_document', '/modify_document']
    redirect '/profile' if !session[:type] && @url_admin.include?(
      request.path_info
    )
    redirect '/all_document' if session[:type] && (request.path_info) == '/documents'
    @url_user =
      ['/profile', '/subscriptions', '/edit_user', '/documents',
       '/notification', '/view_document']
    redirect '/' if !session[:is_login] && @url_user.include?(request.path_info)
  end

  get '/miwebsoket' do
    if !request.websocket?
      redirect '/'
    else
      request.websocket do |ws|
        @connect = { id_user: session[:user_id], socket: ws }
        ws.onopen do
          settings.sockets << @connect
        end
        ws.onmessage do |msg|
          EM.next_tick { settings.sockets.each { |s| s[:socket].send(msg) } }
        end
        ws.onclose do
          settings.sockets.delete(@connect)
        end
      end
    end
  end
end
