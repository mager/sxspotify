require 'rubygems'
require 'sinatra'
require 'mongo_mapper'

get '/' do
  erb :main
end

