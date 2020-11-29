# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'

# Service para User
class UserService
  def self.login(email, password, session)
    @current_user = User.find(email: email)
    if @current_user
      if @current_user.password == password
        session[:is_login] = true
        session[:user_id] = @current_user.id
        session[:type] = @current_user.admin
      else
        raise ArgumentError, 'Contraseña incorrecta'
      end
    else
      raise ArgumentError, 'No existe un usuario con ese email'
    end
  end

  def self.create_user(user)
    raise ArgumentError, 'Ya existe un usuario con ese DNI' if User.find(dni: user['dni'])
    raise ArgumentError, 'Ya existe un usuario con ese email' if User.find(email: user['email'])

    @new_user = User.new(name: user['name'],
                         surname: user['surname'],
                         dni: user['dni'],
                         email: user['email'],
                         password: user['password'],
                         rol: user['rol'],
                         admin: user['admin'])
    @new_user.save
    unless User.find(dni: user['dni'])
      raise ArgumentError, 'El usuario no se creo correctamente, ' \
      'Intente nuevamente'
    end
  end
end
