# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'

# Service para User
class UserService
  def self.login(email, password, session)
    @current_user = User.find(email: email)
    return raise ArgumentError, 'No existe un usuario con ese email' unless @current_user
    return raise ArgumentError, 'Contraseña incorrecta' unless @current_user.password == password

    session[:is_login] = true
    session[:user_id] = @current_user.id
    session[:type] = @current_user.admin
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
    save_user(@new_user)
  end

  def self.save_user(user)
    user.save
    return unless User.find(dni: user['dni']).nil?

    raise ArgumentError, 'El usuario no se creo correctamente, ' \
    'Intente nuevamente'
  end
end
