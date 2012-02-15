require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

# Twilio setup
SID = 'AC92f0c87900e80c41ecfde5f7e6a9f0e3'
AUTH_TOKEN = '5ec9e80206da8b8779b370c73f74df65'
@client = Twilio::REST::Client.new SID, AUTH_TOKEN

get '/' do
  erb :main
end

post '/sms' do
  puts 'HELLO!'
  @client.account.sms.messages.create(:from => '+15128616593',:to => '+14158305533',:body => 'Hey there!')
end

