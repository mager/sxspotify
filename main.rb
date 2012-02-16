require 'rubygems'
require 'sinatra'
require 'twilio-ruby'
require 'mongo_mapper'
require './model'

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
  # TODO: Make sure phone numbers are in Twilio format
  @body = params[:Body]
  @text_message = nil
  @on = false

  User.create({
    :number => @from,
    :on => @on
  })

  if @body == 'Subscribe' or @body == 'Spotify'

    @message = 'You will now get updates from Spotify about awesome shows at SxSW. Text "off" to unsubscribe.'
    @on = true
    update_database()

  elsif @body == 'cancel' or @body == 'Cancel' or @body == 'off' or @body == "Off" or @body == 'Unsubscribe'

    @message = 'Okay, you\'re unsubscribed. Text "on" to turn on notifications.'
    @on = false
    update_database()

  elsif @body == 'on' or @body == 'On'

    @message = 'Welcome back! Notifications from Spotify are on. Stay tuned for updates about secret shows at SxSW'
    @on = true
    update_database()

  else

    @body == 'I don\t recognize that command. Type "help" to get a list of commands.'

  end

    @client.account.sms.messages.create(
      :from => '+15128616593',
      :to => @from,
      :body => @message
    )

end


# Functions
def update_database()
  @user = User.first(:number => @from)
  @user.update_attributes(:on => @on)
  @user.save
end
