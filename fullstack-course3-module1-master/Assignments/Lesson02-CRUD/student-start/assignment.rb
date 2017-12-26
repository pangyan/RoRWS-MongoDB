require 'mongo'
require 'json'
require 'pp'
require 'byebug'
Mongo::Logger.logger.level = ::Logger::INFO
#Mongo::Logger.logger.level = ::Logger::DEBUG

#A variable prefixed with @ is an instance variable, while one prefixed with @@ is a class variable.
#See https://stackoverflow.com/questions/5890118/what-does-variable-mean-in-ruby/5890127

class Solution
  MONGO_URL='mongodb://localhost:27017'
  MONGO_DATABASE='test'
  RACE_COLLECTION='race1'

  # helper function to obtain connection to server and set connection to use specific DB
  # set environment variables MONGO_URL and MONGO_DATABASE to alternate values if not
  # using the default.
  def self.mongo_client
    url=ENV['MONGO_URL'] ||= MONGO_URL
    database=ENV['MONGO_DATABASE'] ||= MONGO_DATABASE 
    db = Mongo::Client.new(url)
    @@db=db.use(database)
  end

  # helper method to obtain collection used to make race results. set environment
  # variable RACE_COLLECTION to alternate value if not using the default.
  def self.collection
    collection=ENV['RACE_COLLECTION'] ||= RACE_COLLECTION
    return mongo_client[collection]
  end
  
  # helper method that will load a file and return a parsed JSON document as a hash
  def self.load_hash(file_path) 
    file=File.read(file_path)
    JSON.parse(file)
  end

  # initialization method to get reference to the collection for instance methods to use
  def initialize
    @coll=self.class.collection
  end

  #
  # Lecture 1: Create
  #

  def clear_collection
    #place solution here
	return @coll.delete_many
  end

  def load_collection(file_path) 
    #place solution here
	return @coll.insert_many(self.class.load_hash(file_path))
  end

  def insert(race_result)
    #place solution here
	return @coll.insert_one(race_result)
  end

  #
  # Lecture 2: Find By Prototype
  #

  def all(prototype={})
    #place solution here
	return @coll.find(prototype)
  end

  def find_by_name(fname, lname)
    #place solution here
	view = @coll.find({ "first_name"=>fname, "last_name"=>lname })
	view = view.projection({ first_name: 1, last_name: 1, number: 1, _id: 0 })
  end

  #
  # Lecture 3: Paging
  #

  def find_group_results(group, offset, limit) 
    #place solution here
	view = @coll.find({ "group"=>group })
	view = view.projection({ group: 0, _id: 0 })
	view = view.sort( { secs: 1 } )
	view = view.skip(offset)
	view = view.limit(limit)
	return view
  end

  #
  # Lecture 4: Find By Criteria
  #

  def find_between(min, max) 
    #place solution here
	return @coll.find({ "secs"=>{ "$gt"=>min, "$lt"=>max } })
  end

  def find_by_letter(letter, offset, limit) 
    #place solution here
	pattern = "^" + letter.upcase + ".+"
	view = @coll.find({ "last_name"=>{ "$regex"=>pattern } })
	view = view.sort( {last_name: 1} )
	view = view.skip(offset)
	view = view.limit(limit)
	return view
  end

  #
  # Lecture 5: Updates
  #
  
  def update_racer(racer)
    #place solution here
	view = @coll.find({ "_id"=>racer["_id"] })
	view = view.replace_one(racer)
	return view
  end

  def add_time(number, secs)
    #place solution here
	@coll.update_one({ "number" => number }, { "$inc" => {"secs": secs} })
  end

end

s=Solution.new
race1=Solution.collection
