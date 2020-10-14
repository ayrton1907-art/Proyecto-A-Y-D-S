require "bundler"
require "sinatra"
require 'sequel'
require "sinatra/config_file"

Bundler.require

# Get the values from our config file
register Sinatra::ConfigFile
config_file 'config/config.yml'

# Create a connection and leave it as a global object in our project
DB = Sequel.connect(
  adapter: settings.db_adapter,
  database: settings.db_name,
  host: settings.db_host,
  user: settings.db_username,
  password: settings.db_password)
Sequel::Model.plugin:json_serializer
# Require and run the main app
require "./app.rb"
run App
