require 'rubygems'
require 'sinatra'
require 'em-synchrony'
require 'twilio-rb'
require 'mongo_mapper'
require './model'

EM.synchrony do
  Twilio::Config.setup account_sid: ENV['SID'], auth_token:  ENV['AUTH_TOKEN']

  # This is our Twilio number
  CALLER_ID    = '894546'.freeze
  BROADCASTERS = ['+14158305533', '+14156022729', '+16463340760'].freeze


  # When someone sends a text message to us, this code runs
  post '/sms' do

    # Break down the message object into usable variables
    from = params['From'] # The @from variable is the user's cell phone number
    body = params['Body'] # The body of the text message
    on   = false # Whether or not the user wants texts

    # If a phone number is not in the database, create a row in the database.
    user = User.first(number: from) || User.create(number: from, on: on)

    # If broadcaster texts a message, send it to everybody
    # with on = true
    if BROADCASTERS.include?(from)
      User.all(on: true).each { |user| Twilio::SMS.create from: CALLER_ID, to: user[:number], body: body }
      count = User.count on: true

      BROADCASTERS.each do |number|
         Twilio::SMS.create from: CALLER_ID, to: number, body: 'You just sent a message to ' + count.to_s + ' peeps. Hope you aren\'t too drunk or sleepy.'
      end

    else

      case body
      when /^subscribe$/i, /^spotify$/i, /^join$/i
        message = 'Welcome! You will now get updates from Spotify about awesome events in Austin next week. Text "off" to unsubscribe. SMS powered by Twilio!'
        on      = true

      when /^cancel$/i, /^off$/i, /^unsubscribe$/i, /^stop$/i, /^die$/i, /^shut up$/
        message = 'You are opted out from Spotify SMS alerts. No more messages will be sent. Text ON to rejoin. Text HELP for help. Msg&Data rates may apply.'
        on      = false

      when /^on$/i
        message = 'Welcome back! Notifications from Spotify are on. Stay tuned for updates about all of our events this week in Austin.'
        on      = true

      when /^help$/i
        message = 'Spotify SMS alerts: Reply STOP or OFF to cancel. Msg frequency depends on user. Msg&Data rates may apply.'

      else
        message = 'Welcome! You will now get updates from Spotify about awesome events in Austin next week. Text "off" to unsubscribe. SMS powered by Twilio!'
        on      = true

      end

      Twilio::SMS.create from: CALLER_ID, to: from, body: message

      user.update_attributes! on: on
    end

  end
end
