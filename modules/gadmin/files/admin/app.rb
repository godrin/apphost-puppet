require 'gitolite'
require 'sinatra'
require 'digest/sha1'
require 'json'
require 'pp'
require './model.rb'

class Ga
  if File.exists?("/home/david/server/gitolite-admin")
    GITOLITE_ADMIN_HOME="/home/david/server/gitolite-admin"
  else
    GITOLITE_ADMIN_HOME="/home/gadmin/repo"
  end

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

  def self.removeKey(dbKey)

    self.update
pp "dbkey",dbKey
    key=Gitolite::SSHKey.from_string(File.open(File.join(GITOLITE_ADMIN_HOME,"keydir",dbKey.name+".pub")){|f|f.read},dbKey.name)
    if key

      dbKey.user.acl_entries.each{|acl|
	self.updatePermission(acl.repository)
      }

      @@ga_repo.rm_key(key)
      self.apply
      true
    else
      false
    end
  end

  def self.addKey(dbKey)

    self.update

    keys=@@ga_repo.ssh_keys


    name=dbKey.name
    pp keys,name,keys[name]
    if (not keys[name]) or keys[name].length==0
      puts "KEY NOT EXISTING - add "
      gkey=Gitolite::SSHKey.from_string(dbKey.data,dbKey.name)
      @@ga_repo.add_key(gkey)
      self.apply
    else
      puts "KEY ALREADY exists"
    end

  end

  def self.update
    @@ga_repo.update
  end
  def self.apply
    @@ga_repo.save
    @@ga_repo.apply
  end

  def self.updatePermission(dbRepo)
    self.update
    repos=self.repos

    repo=repos[dbRepo.name]
    pp "repo found ?",repo
    unless repo 
      repo=Gitolite::Config::Repo.new(dbRepo.name)
      Ga.config.add_repo(repo)

    end

    repo.clean_permissions
    repo.add_permission("RW+","","gadmin")

    dbRepo.acl_entries.each{|acl|
      acl.user.keys.each{|key|
	repo.add_permission(acl.right,"",key.name)
      }
    }
    self.apply
  end

  def self.updateRepo(repoName,user)
    @@ga_repo.update
    repos=self.repos
    #pp dbRepo
    c=repos[repoName]
    if c
      # TODO:update
      #
      #
      pp c,c.methods
      pp "owner",c.owner
      pp "permissions",c.permissions
    else
      # should create

      c = Gitolite::Config::Repo.new(repoName)

      #For a list of permissions, see http://sitaramc.github.com/gitolite/conf.html#gitolite
      c.add_permission("RW+", "", "gadmin")
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
      if false
	c.set_git_config("hooks.post-receive","touch /tmp/POSTUPDATE")
      end
      ##Add repo to config
      Ga.config.add_repo(c)
      #Ga.repo.
    end

    user.keys.each{|key|
      c.add_permission("RW+","",key.name)
    }


    Ga.repo.save
    Ga.repo.apply
  end

end


class MyApp < Sinatra::Base

  enable  :methodoverride
  helpers do
    def json(data)
      content_type :json
      data.to_json
    end
    def checkLogin
      token=params["token"]
      if token
	User.first({:token=>token})
      else
	false	
      end
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
      user.token=Digest::SHA1.hexdigest 'mysecret'+user.email+"__"+user.password+Time.now.to_s
      user.save
      json user.token
    else
      json false
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
    pp "POST",params
    user=User.first({:token=>params["token"]})
    if user
      if params["key"]
	data=params["key"].chomp.gsub("\n","")
	if user.keys.first({:data=>data})
	  json :state=>false, :error=>"already inserted"
	else
	  k=Key.create!({:user=>user,:data=>data})
	  Ga.addKey(k)
	  json :state=>true
	end
      else
	json :state=>false,:error=>"key invalid"
      end
    else
      json :state=>false,:error=>"invalid token"
    end
  end
  delete '/key' do
    key=User.first({:token=>params["token"]}).keys.first({:data=>params["key"].chomp})
    unless key
      key=User.first({:token=>params["token"]}).keys.first({:id=>params["id"]})
    end
    if key

      key.destroy
      Ga.removeKey(key)
      
      json :state=>true
    else
      json :state=>false
    end
  end

  get '/repo' do
    json Ga.repos
  end
  post '/repo' do
    user=checkLogin 
    if user and user.hasKey
      repoName=params["name"]
      #"meintest"
      if not repoName=~/[a-z][a-z0-9_]*/
	pp params
	raise "invalid reponame #{repoName}"
      end

      dbrepo=Repository.createDefault({:name=>repoName,:user=>user,:description=>params["description"]})

      Ga.updatePermission(dbrepo)

      #    Ga.repo.update
      #    repo = Gitolite::Config::Repo.new(repoName)

      #For a list of permissions, see http://sitaramc.github.com/gitolite/conf.html#gitolite
      #    repo.add_permission("RW+", "", "gadmin")
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
      #   repo.set_git_config("hooks.post-receive","touch /tmp/POSTUPDATE")
      #   ##Add repo to config
      #   Ga.config.add_repo(repo)
      #Ga.repo.
      #   Ga.repo.save
      #   Ga.repo.apply
      json :state=>true
    else
      json :state=>false,:error=>"Invalid token"
    end
  end
end



