require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

# Twilio setup
API_VERSION = '2010-04-01'
BROADCASTER = '+15128616593'
@client = Twilio::REST::Client.new, ENV['TWILIO_ID'], ENV['AUTH_TOKEN']

get '/' do
  erb :main
end

post '/sms' do
  @from = params[:From]
  @message = 'Success!'

/*
  response = Twilio::TwiML::Response.new do |r|
    r.Sms 'hello there'
  end
*/
  @client.account.sms.messages.create (
    :from => BROADCASTER,
    :to => @from,
    :body => 'Hey there!'
  )
end

