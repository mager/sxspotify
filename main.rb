require 'rubygems'
require 'sinatra'
require 'twilio-ruby'
require 'mongo_mapper'
require './model'

# When someone sends a text message to us, this code runs
post '/sms' do
  # Initialize Twilio
  @sid = ENV['SID']
  @auth_token = ENV['AUTH_TOKEN']
  @us = '+16466062002' # This is our Twilio number
  @client = Twilio::REST::Client.new @sid, @auth_token

  @from = params[:From]
  @body = params[:Body] # The body of the text message

  @broadcasters = ['+14158305533']
  @on = false # Whether or not the user wants texts

  @subscribe = ['Subscribe', 'Spotify', 'testing!']

  # If a phone number is not in the database...
  if User.first(:number => @from) == nil
    # Create a row in the database
    User.create({
      :number => @from,
      :on => @on
    })
  end

  # If broadcaster texts a message, send it to everybody
  # with @on = true
  if @broadcasters.include?(@from)
    for user in User.all(:on=>true)
      @client.account.sms.messages.create(
        :from => @us,
        :to => user[:number],
        :body => @body
      )
    end

  else

    if @subscribe.include?(@body)

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
