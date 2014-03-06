MongoMapper.connection = Mongo::Connection.new('linus.mongohq.com', 10008)
MongoMapper.database = 'sxspotify'
MongoMapper.database.authenticate('test','test')

class User
  include MongoMapper::Document
  key :number, String
  key :on, Boolean

  timestamps!
end
