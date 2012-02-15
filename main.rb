require 'rubygems'
require 'sinatra'
require 'twiliolib'

# Twilio setup
API_VERSION = '2010-04-01'
CALLER_ID = '(646) 448-9996'
ACCOUNT_SID = 'AC92f0c87900e80c41ecfde5f7e6a9f0e3'
ACCOUNT = Twilio::RestAccount.new(ENV['ACCOUNT_SID'], ENV['ACCOUNT_TOKEN'])
URL_POST_SMS = "/#{API_VERSION}/Accounts/#{ENV['ACCOUNT_SID']}/SMS/Messages"

get '/' do
  erb :main
end

post '/sms' do
  @from = params[:From]
  @message = 'Success!'
  h = {:From => '+15128616593', :To => @from, :Body => @message }
  resp = ACCOUNT.request(URL_POST_SMS, 'POST', h)

end

