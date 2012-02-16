require 'rubygems'
require 'sinatra'
require 'builder'
require 'twilio-ruby'

# Twilio setup
@sid = 'AC92f0c87900e80c41ecfde5f7e6a9f0e3'
@auth_token = '5ec9e80206da8b8779b370c73f74df65'
@client = Twilio::REST::Client.new @sid, @auth_token

get '/' do
  erb :main
end

post '/sms' do
  @client.account.sms.messages.create(
    :from => '+15128616593',
    :to => '+14158305533',
    :body => 'Hey there'
  )
end
