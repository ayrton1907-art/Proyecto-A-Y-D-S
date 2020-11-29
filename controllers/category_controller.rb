# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'

require './controllers/before_controller'

require './services/category_service'
# Controller para Category
class CategoryController < BeforeController
  get '/all_category' do
    @page_name = 'Categorias'
    @all_categories = Category.order(:name).all
    erb :all_category, layout: @current_layout
  end

  post '/create_category' do
    CategoryService.crear_categoria(params[:name], params[:description])
    redirect '/all_category'
  rescue ArgumentError => e
    return erb :error, locals: { errorMessage: e.message,
                                 url: '/all_category',
                                 all_categories: Category.order(:name).all }
  end

  post '/modify_category' do
    CategoryService.modificar_categoria(params[:name], params[:description], params[:modify_id])
    redirect '/all_category'
  rescue ArgumentError => e
    return erb :error, locals: { errorMessage: e.message,
                                 url: '/all_category',
                                 all_categories: Category.order(:name).all }
  end

  post '/delete_category' do
    CategoryService.eliminar_categoria(params['id_delete'], params['id_select'])
    redirect '/all_category'
  rescue ArgumentError => e
    return erb :error, locals: { errorMessage: e.message,
                                 url: '/all_category',
                                 all_categories: Category.order(:name).all }
  end
end
