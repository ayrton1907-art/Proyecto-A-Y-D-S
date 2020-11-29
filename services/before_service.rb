# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'

# Service para Before
class BeforeService
  def self.layout(type)
    @current_layout = if type
                        :layout_admin
                      else
                        :layout_users
                      end
    @current_layout
  end

  def self.new_notifications(user_id)
    @user = current_user(user_id)
    @notification = NotificationUser.where(
      user_id: @user.id,
      seen: 'f'
    )
    @count_notifications = 0
    @notification&.each { |_element| @count_notifications += 1 }
    @count_notifications
  end

  def self.current_user(user_id)
    @current_user = User.find(id: user_id)
    @current_user
  end
end
