require 'gitolite'
require 'sinatra'

class Ga
  def self.repos
    ga_repo = Gitolite::GitoliteAdmin.new(MyApp::GITOLITE_ADMIN_HOME)
    ga_repo.config.repos
  end

  def self.groups
  end

  def self.users
  end
end


class MyApp < Sinatra::Base
  GITOLITE_ADMIN_HOME="/var/lib/git"
get '/' do
  @repos = Ga.repos
end
end

