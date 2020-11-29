# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'

require './controllers/before_controller'

require './services/filter_service'
require './services/document_service'

# Controller para Document
class DocumentController < BeforeController
  get '/all_document' do
    @page_name = 'Documentos'
    @all_documents = Document.order(:name).all
    @all_categories = Category.order(:name).all
    @users_name = User.order(:name).all
    erb :all_document, layout: @current_layout
  end

  get '/documents' do
    @page_name = 'Documentos'
    @all_documents = Document.order(:name).all
    @all_categories = Category.order(:name).all
    erb :documents, layout: @current_layout
  end

  post '/documents_filter' do
    @page_name = 'Documentos'
    @all_documents = FilterService.filter(
      params[:document_id],
      params[:filter],
      params[:category_id],
      params[:dateDoc]
    )
    @all_categories = Category.order(:name).all
    if session[:type]
      @users_name = User.order(:name).all
      erb :all_document, layout: @current_layout
    else
      erb :documents, layout: @current_layout
    end
  end

  post '/create_document' do
    @new_direction = DocumentService.new_document(params[:PDF][:filename], params[:PDF][:tempfile])
    @document_save = DocumentService.save_document(
      params[:name],
      params[:description],
      @new_direction,
      params[:category]
    )
    DocumentService.select_user_tag(params[:users_tagged], params[:category], @document_save.id)
    redirect '/all_document'
  rescue ArgumentError => e
    return erb :error, locals: { errorMessage: e.message,
                                 url: '/all_document',
                                 document: Document.order(:date).reverse.all }
  end

  post '/select_document' do
    @page_before_name = 'Documentos'
    @page_before = '/all_document'
    @page_intern = 'Editar Documento'
    @document_modify = Document.find(id: params[:select_id])
    @categories_modify = Category.where(id: @document_modify.category_id)
    @all_categories = Category.except(@categories_modify).all
    @users_tagged = User.where(documents: @document_modify)
    @users = User.except(@users_tagged).all
    erb :modify_document, layout: @current_layout
  end

  post '/modify_document' do
    @document_modify = DocumentService.edit_document(params[:the_id],
                                                     params[:new_name],
                                                     params[:description],
                                                     params[:category])
    DocumentService.select_user_tag(params[:users_tagged],
                                    @document_modify.category_id,
                                    @document_modify.id)
    redirect '/all_document'
  rescue ArgumentError => e
    return erb :error, locals: { errorMessage: e.message,
                                 url: '/all_document',
                                 document: Document.order(:date).reverse.all }
  end

  post '/delete_document' do
    @pdf_delete = Document.find(id: params[:delete_document_id])
    @pdf_delete.remove_all_users
    @notification = Notification.where(document_id: @pdf_delete.id).all
    @notification.each do |element|
      element.remove_all_users
      element.delete
    end
    @pdf_delete.delete
    redirect '/all_document'
  end

  post '/see_document' do
    if params[:name] == 'Perfil'
      @page_name = 'Documento'
    else
      @page_before_name = params[:name]
      @page_before = params[:road]
      @page_intern = 'Documento'
    end
    @document = Document.find(id: params[:seen_document_id])
    erb :view_document, layout: @current_layout
  end
end
