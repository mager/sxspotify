require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

# Twilio setup
BROADCASTER = '+15128616593'
@client = Twilio::REST::Client.new, ENV['TWILIO_ID'], ENV['AUTH_TOKEN']

get '/' do
  erb :main
end

post '/sms' do
  puts params
  @from = params[:From]
  @message = 'Success!'
  @client.account.sms.messages.create(:from=>BROADCASTER,:to=>@from,:body=>@message)
end

