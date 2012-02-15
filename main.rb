require 'rubygems'
require 'sinatra'
require 'mongo_mapper'
require './model'

get '/' do
  erb :main
end

