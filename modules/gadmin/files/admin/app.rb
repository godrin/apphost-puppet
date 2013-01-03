require 'gitolite'
require 'sinatra'
require 'data_mapper'
require 'digest/sha1'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, (ENV["DATABASE_URL"]|| 'sqlite://'+File.expand_path('../git.db',__FILE__)))
DataMapper::Model.raise_on_save_failure=true

class User
  include DataMapper::Resource

  property :id, Serial
  property :email, Text
  property :password, Text
  property :token, Text
  
  has n,:keys

  def name
    self.name.gsub("@","_at_").gsub(".","__")
  end
end

class Key
  include DataMapper::Resource

  property :id, Serial
  property :data, Text

  belongs_to :user

  def file
    self.user.name+"_"+self.id.to_s
  end
end

class Ga
  GITOLITE_ADMIN_HOME="/home/gadmin/repo"

  @@ga_repo=Gitolite::GitoliteAdmin.new(Ga::GITOLITE_ADMIN_HOME)
 
  

  def self.repos
    @@ga_repo.config.repos
  end

  def self.repo
    @@ga_repo
  end

  def self.config
    @@ga_repo.config
  end

  def self.groups
  end

  def self.users
  end

end


class MyApp < Sinatra::Base
  helpers do
    def json(data)
      content_type :json
      data.to_json
    end
  end

  get '/' do
    @repos = Ga.repos
    @repos.to_s
  end

  post '/register' do
    User.create!({:email=>params["email"],:password=>params["password"]})
    json true
  end
  post '/login' do
    user=User.first({:email=>params["email"],:password=>params["password"]})
    if user
      user.token=Digest::SHA1.hexdigest 'mysecret'+user.email+"__"+user.password
      user.save
      json user.token
    else
      json "failed"
    end
  end

  get '/key' do
    user=User.first({:token=>params["token"]})
    if user
      json user.keys
    else
      json []
    end
  end
  post '/key' do
    user=User.first({:token=>params["token"]})
    if user
      if params["key"]
	k=Key.create!({:user=>user,:key=>params["key"]})
	json true
      else
	json false
      end
    end
  end
  delete '/key' do
    key=User.first({:token=>params["token"]}).first({:key=>params["key"]})
    if key
      key.destroy
      json true
    else
      json false
    end
  end
  post '/repo' do
    repoName="meintest"
    repo = Gitolite::Config::Repo.new(repoName)

    #For a list of permissions, see http://sitaramc.github.com/gitolite/conf.html#gitolite
    repo.add_permission("RW+", "", "gadmin")
    #bob", "joe", "susan")
    #
    ##Set a git config option to the repo
    #repo.set_git_config("hooks.mailinglist", "gitolite-commits@example.tld") # => "gitolite-commits@example.tld"
    #
    ##Unset a git config option from the repo
    #repo.unset_git_config("hooks.mailinglist") # => "gitolite-commits@example.tld"
    #
    ##Set a gitolite option to the repo
    #repo.set_gitolite_option("mirroring.master", "kenobi") # => "kenobi"
    #
    ##Remove a gitolite option from the repo
    #repo.unset_gitolite_option("mirroring.master") # => "kenobi"
    #
    repo.set_git_config("hooks.post-update","touch /tmp/POSTUPDATE")
    ##Add repo to config
    Ga.config.add_repo(repo)
    #Ga.repo.
    Ga.repo.apply
    json true
  end
end



