require 'data_mapper'
require 'digest/sha1'
require 'pp'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, (ENV["DATABASE_URL"]|| 'sqlite://'+File.expand_path('../git.db',__FILE__)))
DataMapper::Model.raise_on_save_failure=true

class AppProcess
    include DataMapper::Resource

    property :id, Serial
    property :name, Text
    property :databaseUrl, Text

    property :port, Integer
    property :pid, Integer


    def self.findFreePort
      startPort=9000

      while startPort<10000
	return startPort unless self.first({:port=>startPort})
      end
      return nil
    end
end


DataMapper.finalize
DataMapper.auto_upgrade!


