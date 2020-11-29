# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'

require './controllers/before_controller'

require './services/user_service'

# Controller para User
class UserController < BeforeController
  post '/new_user' do
    @user = { 'name' => params[:name],
              'surname' => params[:surname],
              'dni' => params[:dni],
              'email' => params[:email],
              'password' => params[:password],
              'rol' => params[:rol],
              'type' => false }
    UserService.create_user(@user)
    redirect '/profile'
  rescue ArgumentError => e
    return erb :error, locals: { errorMessage: e.message,
                                 url: '/',
                                 document: Document.order(:date).reverse.all }
  end

  post '/create_user' do
    type = params['type'] == 'Administrador'
    @user  = { 'name' => params[:name],
               'surname' => params[:surname],
               'dni' => params[:dni],
               'email' => params[:email],
               'password' => params[:password],
               'rol' => params[:rol],
               'admin' => type }
    UserService.create_user(@user)
    redirect '/profile'
  rescue ArgumentError => e
    return erb :error, locals: { errorMessage: e.message,
                                 url: '/',
                                 document: Document.order(:date).reverse.all }
  end

  get '/profile' do
    @all_documents = Document.where(users: @current_user).all
    @all_subcriptions = Category.where(users: @current_user).all
    @all_subcriptions&.each do |element|
      @documents_category = Document.where(category_id: element.id).all
      @documents_category&.each do |element2|
        @all_documents << (element2) unless @all_documents.include?(element2)
      end
    end
    erb :profile, layout: @current_layout
  end

  post '/edit_user' do
    @current_user.update(name: params[:name]) if params[:name] != ''
    @current_user.update(surname: params[:surname]) if params[:surname] != ''
    @current_user.update(dni: params[:dni]) if params[:dni] != ''
    @current_user.update(password: params[:password]) if params[:password] != ''
    @current_user.update(rol: params[:rol]) if params[:rol] != ''
    redirect '/profile'
  end

  post '/delete_user' do
    @user_delete = User.find(id: session[:user_id])
    @user_delete.remove_all_categories
    @user_delete.remove_all_documents
    @notification = Notification.where(users: @user_delete).all
    unless @notification.empty?
      @notification.each do |element|
        element.remove_all_notifications
        element.delete
      end
    end
    if @user_delete.delete
      session.clear
      redirect '/'
    end
  end
end
