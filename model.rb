MongoMapper.connection = Mongo::Connection.new('staff.mongohq.com', 10020)
MongoMapper.database = 'sxspotify'
MongoMapper.database.authenticate('sxspotify','sxspotify')

class User
  include MongoMapper::Document
  key :number, String
  key :on, Boolean

  timestamps!
end

