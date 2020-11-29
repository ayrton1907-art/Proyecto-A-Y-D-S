# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'
require './services/user_service'

# Service para crear documentos
class DocumentService
  def self.new_document(filename, tempfile)
    @filename = filename
    @src = "/public/PDF/#{@filename}"
    file = tempfile
    @direction = "PDF/#{@filename}"
    File.open("./public/PDF/#{@filename}", 'wb') do |f|
      f.write(file.read)
    end
    @direction
  end

  def self.save_document(name_document,
                         description_document,
                         direction_document,
                         category_id)
    @chosen_category = Category.find(id: category_id)
    @doc_save = Document.new(name: name_document,
                             description: description_document,
                             fileDocument: direction_document,
                             category_id: @chosen_category.id,
                             date: Time.now.strftime('%Y-%m-%d'))
    @doc_saved = guardar_base_documento(@doc_save)
    @doc_saved
  end

  def self.guardar_base_documento(documento)
    documento.save
    unless Document.find(id: documento.id)
      raise ArgumentError, 'El Documento no se creo correctamente,' \
                          ' Intente nuevamente'
    end
    documento
  end

  def self.edit_document(the_id, new_name, description, category)
    return raise ArgumentError, 'El Documento no se modifico correctamente' unless Document.find(id: the_id)

    @document_modify = modificar(the_id, new_name, description, category)
    @notification_delete = Notification.where(document_id: @document_modify.id).all
    @notification_delete&.each do |element|
      element.remove_all_users
      element.delete
    end
    @document_modify
  end

  def self.modificar(id, new_name, description, category)
    @document_modify = Document.find(id: id)
    @document_modify.update(name: new_name) if new_name != ''
    @document_modify.update(description: description) if description != ''
    @document_modify.update(category_id: category) if category
    @document_modify.remove_all_users
    @document_modify
  end

  def self.select_user_tag(users_tagged, category_id, document_id)
    @user_tagged_category = User.where(categories: Category.find(id: category_id))
    @user_tagged_name = tag_users(users_tagged, @user_tagged_category)
    @doc_save = Document.find(id: document_id)
    @user_tagged_cate = []
    @user_tagged_category&.each do |element|
      @user_tagged_cate << element unless @user_tagged_name.include?(element)
    end
    notify(@user_tagged_name, @user_tagged_cate, @doc_save)
  end

  def self.tag_users(users_tagged, user_tagged_category)
    @user_tagged_name = []
    users_tagged&.each do |element|
      @user_not = User.find(id: element)
      index = user_tagged_category.include? element
      user_tagged_category.delete(user_tagged_category[index]) if index
      @user_tagged_name << @user_not
    end
    @user_tagged_name
  end

  def self.notify(user_tagged, user_category, document)
    date_notification = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    notify_tagged(user_tagged, document, date_notification)
    notify_subcription(user_category, document, date_notification)
  end

  def self.notify_tagged(user_tagged, document, date_notification)
    @user_taggeds = user_tagged
    return unless @user_taggeds

    @notification_tagged = create_notify(document, 'etiquetaron', date_notification)
    create_tagged(@user_taggeds, @notification_tagged, document)
  end

  def self.create_tagged(user_taggeds, _notification_tagged, document)
    user_taggeds&.each do |element|
      document.add_user(element)
      @notification_tagged.add_user(element)
    end
  end

  def self.notify_subcription(user_category, document, date_notification)
    @notif_from_category = create_notify(document, 'categoria', date_notification)
    user_category&.each { |element| @notif_from_category.add_user(element) }
  end

  def self.create_notify(document, descriptions, date_notification)
    @notification = Notification.new(
      description: descriptions,
      date: date_notification,
      document_id: document.id
    )
    @notification.save
    @notification
  end
end
