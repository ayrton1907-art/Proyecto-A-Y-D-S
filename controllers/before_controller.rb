# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'
require './services/before_service'
# Controller para Category
class BeforeController < Sinatra::Base
  configure :development, :production do
    set :views, "#{settings.root}/../views"
  end

  before do
    if session[:is_login]
      @current_user = BeforeService.current_user(session[:user_id])
      @count_notifications = BeforeService.new_notifications(session[:user_id])
      @current_layout = BeforeService.layout(session[:type])
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
end
