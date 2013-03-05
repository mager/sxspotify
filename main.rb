STDOUT.sync = true

require 'thin'
require 'sinatra'
require 'sinatra/synchrony'
require 'twilio-rb'
require 'mongo_mapper'
require 'logger'
require './model'

# TCPSocket = EventMachine::Synchrony::TCPSocket

Twilio::Config.setup account_sid: ENV['SID'], auth_token: ENV['AUTH_TOKEN']

# This is our Twilio number
CALLER_ID = '+61235'.freeze

# An array of broadcasters
BROADCASTERS = ['+14158305533'].freeze
LOGGER = Logger.new STDOUT


# Web interface for posting

get '/admin' do
  @count = User.count on: true
  haml :admin
end

get '/sent' do
  @count = User.count on: true
  haml :sent
end

post '/admin' do
  User.all(on: true).each do |user|
    retry_count = 0
    begin
      Twilio::SMS.create(from: CALLER_ID, to: user[:number], body: params['sms_body']) unless retry_count > 2
    rescue => e
      retry_count += 1
      LOGGER.error "ERROR: failed to send message to #{user[:number]}. Error msg: #{e.to_s}. Retrying #{ 3 - retry_count } more times."
      retry
    end

  end

  count = User.count on: true

  BROADCASTERS.each do |number|
    Twilio::SMS.create from: CALLER_ID, to: number, body: 'INFO: Message sent to ' + count.to_s + ' subscribers from web interface.'
  end

  LOGGER.info "Broadcast sent. Message body: #{params[:sms_body]}"

  "Message sent."

  redirect '/sent'
end




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
      message = 'Welcome back! Notifications from Spotify are on. Stay tuned for updates about all of our events this week in Austin. SMS powered by Twilio!'
      on      = true

    when /^help$/i
      message = 'Spotify SMS alerts: Reply STOP or OFF to cancel. Msg frequency depends on user. Msg&Data rates may apply. SMS powered by Twilio.'

    else
      message = 'Welcome! You will now get updates from Spotify about awesome events in Austin next week. Text "off" to unsubscribe. SMS powered by Twilio!'
      on      = true

    end

    Twilio::SMS.create from: CALLER_ID, to: from, body: message

    user.update_attributes! on: on
  end

end

