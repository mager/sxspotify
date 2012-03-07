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
  @us = '894546' # This is our Twilio number
  @client = Twilio::REST::Client.new @sid, @auth_token

  @from = params[:From]
  @body = params[:Body] # The body of the text message

  @broadcasters = ['+14158305533']
  @on = false # Whether or not the user wants texts

  @subscribe = ['Subscribe', 'subscribe', 'subcribe', 'suscribe', 'subscibe', 'Start', 'start', 'Spotify', 'JOIN', 'Join', 'join', 'spotify']
  @unsubscribe = ['Off', 'off', 'Cancel', 'cancel', 'STOP', 'Stop', 'stop', 'Shut up', 'Die', 'No', 'no']
  @resubscribe = ['On', 'on']
  @help = ['HELP', 'Help', 'help', '?']

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

      @message = 'Welcome! You will now get updates from Spotify about awesome events in Austin next week. Text "off" to unsubscribe. SMS powered by Twilio!'
      @on = true
      update_database()

    elsif @unsubscribe.include?(@body)

      @message = 'You are opted out from Spotify SMS alerts. No more messages will be sent. Text ON to rejoin. Text HELP for help. Msg&Data rates may apply.'
      @on = false
      update_database()
  
    elsif @resubscribe.include?(@body)

      @message = 'Welcome back! Notifications from Spotify are on. Stay tuned for updates about all of our events this week in Austin.'
      @on = true
      update_database()

    elsif @help.include?(@body)

        @message = 'Spotify SMS alerts: Reply STOP or OFF to cancel. Msg frequency depends on user. Msg&Data rates may apply.'

    else

      @body == 'We don\t recognize that command. Type "on" or "off" to manage notifications.'

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
