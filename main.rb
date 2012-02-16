require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

get '/' do
  erb :main
end

post '/sms' do
  @sid = 'AC92f0c87900e80c41ecfde5f7e6a9f0e3'
  @auth_token = '5ec9e80206da8b8779b370c73f74df65'
  @client = Twilio::REST::Client.new @sid, @auth_token

  @from = params[From]
  @client.account.sms.messages.create(
    :from => '+15128616593',
    :to => @from,
    :body => 'Hey there'
  )
end
