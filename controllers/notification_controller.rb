# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'

require './controllers/before_controller'

require './services/before_service'

# Controller para Notification
class NotificationController < BeforeController
  get '/notification' do
    @page_name = 'Notificaciones'
    Note = Struct.new(:notification, :document, :info)
    @document_tagged = []
    @notif_subscribed_category = []
    @notif_user = NotificationUser.where(user: @current_user).all
    @notif_user&.each do |element|
      @current_notif = Notification.find(id: element.notification_id)
      @notif_save = Note.new
      @notif_save.notification = @current_notif
      @notif_save.document = (Document.find(id: @current_notif.document_id))
      @notif_save.info = (element.seen)
      if @current_notif.description == 'etiquetaron'
        @document_tagged << (@notif_save)
      else
        @notif_subscribed_category << (@notif_save)
      end
    end
    @document_tagged.reverse!
    @notif_subscribed_category.reverse!
    erb :notification, layout: @current_layout
  end

  post '/delete_notification' do
    @notificated = Notification.find(id: params[:delete_notification_id])
    @seen = NotificationUser.find(
      notification_id: @notificated.id,
      user_id: @current_user.id
    )
    @seen.delete
    redirect '/notification'
  end

  post '/mark_notification' do
    @notificated = Notification.find(id: params[:seen_id])
    @seen = NotificationUser.find(
      notification_id: @notificated.id,
      user_id: @current_user.id
    )
    if @seen.seen == false
      @seen.update(seen: true)
    else
      @seen.update(seen: false)
    end
    redirect '/notification'
  end
end
