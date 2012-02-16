require 'rubygems'
require 'sinatra'
require 'twilio-ruby'
require 'mongo_mapper'
require './model'

# When someone sends a text message to us, this code runs
post '/sms' do
  # Initialize Twilio
  @sid = 'AC92f0c87900e80c41ecfde5f7e6a9f0e3'
  @auth_token = '5ec9e80206da8b8779b370c73f74df65'
  @us = '+15128616593' # This is our Twilio number
  @client = Twilio::REST::Client.new @sid, @auth_token

  # Set global variables
  @from = "+1" << params[:From] # The @from variable is the user's cell phone number
  @body = params[:Body]
  @text_message = nil # The message we blast to everyone
  @on = false

  # If a phone number is not in the database...
  if User.first(:number => @from) == nil
    # Create a row in the database
    User.create({
      :number => @from,
      :on => @on
    })
  end

  # TODO: If the incoming cell phone number is a certified Spotify broadcaster, like Candice, Rachel, or Andrew, the whole logic of the code changes; And the message from that cell phone gets sent to every other cell phone in the database.
  if @from == '+16464131271'
    for user in User.all(:on=>true)
      @client.account.sms.messages.create(
        :from => @us,
        :to => user[:number],
        :body => @body
      )
    end

  else

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

    elsif @body == 'help' or @body == 'Help' or @body == 'HELP'

      @message = 'I haven\'t programmed that. Yell at @mager'

    else

      @body == 'I don\t recognize that command. Type "help" to get a list of commands.'

    end

      @client.account.sms.messages.create(
        :from => @us,
        :to => @from,
        :body => @message
      )
  end

end


# Functions
def update_database()
  @user = User.first(:number => @from)
  @user.update_attributes(:on => @on)
  @user.save
end
