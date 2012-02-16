require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

get '/' do
  erb :main
end

# When someone sends a text message to us, this code runs
post '/sms' do
  # Initialize Twilio
  @sid = 'AC92f0c87900e80c41ecfde5f7e6a9f0e3'
  @auth_token = '5ec9e80206da8b8779b370c73f74df65'
  @client = Twilio::REST::Client.new @sid, @auth_token

  # Set global variables
  @from = params[:From]
  @body = params[:Body]
  @text_message = nil

  if @body == 'Subscribe'
    @message = 'You will now get updates from Spotify about awesome shows at SxSW. Text "cancel" to unsubscribe.'
  elsif @body == 'cancel'
    @message = 'Okay, you\'re unsubscribed. Text "on" to turn on notifications.'
  else
    @body == 'I don\t recognize that command. Try again sucka!!'
  end

    @client.account.sms.messages.create(
      :from => '+15128616593',
      :to => @from,
      :body => @message
    )
end
