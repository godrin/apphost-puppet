#!/usr/bin/env ruby

require 'nestful'
require 'pp'
require 'json'

class Client
  attr_reader :token
  def initialize
    @server=Nestful::Resource.new("http://localhost:9292")
    readConfig
  end

  def token=(token)
    @token=token
    saveConfig
  end

  def register(email,password)
    token=@server["register"].post(:params=>{"email"=>email,"password"=>password})

    if token=~/"[a-z0-9]+"/
      self.token=token[1..-2]
      true
    else
      false
    end
  end

  def login(email,password)
    token=@server["login"].post(:params=>{"email"=>email,"password"=>password})
    if token=~/"[a-z0-9]+"/
      self.token=token[1..-2]
      true
    else
      false
    end
  end

  def logout
    self.token=nil
  end
  def addKey(keyData)
    result=JSON.parse(@server["key"].post(:params=>{"key"=>keyData,"token"=>@token}))
    if result["state"]!=true 
      puts result["error"] 
      false
    else
      true
    end
  end

  def removeKey(keyData,id)
    result=JSON.parse(@server["key"].post(:params=>{"_method"=>"delete","key"=>keyData,"id"=>id,"token"=>@token}))
    if result["state"]!=true
      puts result["error"]
      false
    else
      true
    end
  end


  def keys
    JSON.parse(@server["key"].get({:params=>{:token=>@token}}))
  end


  def repos
    JSON.parse(@server["repo"].get(:params=>{"token"=>@token}))
  end

  def createRepo(repoName)
    result=JSON.parse(@server["repo"].post(:params=>{"name"=>repoName,"token"=>@token}))
    if result["state"]!=true 
      puts result["error"] 
      false
    else
      result["url"]
    end
  end

  def removeRepo(repoName)
    result=JSON.parse(@server["repo"].post(:params=>{"name"=>repoName,"token"=>@token,"_method"=>"delete"}))
    if result["state"]!=true
      puts result["error"]
      false
    else
      pp "RESULT",result
      true
    end
  end


  private
  def saveConfig
    File.open(configFile,"w") {|f|
      f.puts("token="+@token) if @token
    }
  end
  def configFile
    File.join(ENV["HOME"],".apphost")
  end
  def readConfig
    return unless File.exists?(configFile)
    File.open(configFile,"r").each_line{|line|
      line.chomp!
      case line
      when /^token=.*/
	@token=line.sub(/^....../,"")
      end

    }
  end

end

client=Client.new
if ARGV.length>0
  case ARGV[0]
  when "repo"
    case ARGV[1]
    when "list"
      pp client.repos
    when "create"
      if ARGV[2]
	begin
	  repoName=ARGV[2]
	  puts "Creating repo #{repoName}"
	  result=client.createRepo(repoName)
	rescue Exception=>e
	  pp e
	  raise e
	end
	pp result
	if result
	  puts "run:"
	  puts "git remote add apphost "+result
	end
      end
    when "remove","rm","delete"
      if ARGV[2]
	repoName=ARGV[2]
	puts "Deleting repo #{repoName}"
	pp client.removeRepo(repoName)
      end
    end
  when "register"
    email=ARGV[1]
    password=ARGV[2]
    if email=~/[a-z][a-z0-9_]*/ and password
      client.register(email,password)
    else
      puts "Login or password not ok"
    end
  when "login"
    email=ARGV[1]
    password=ARGV[2]
    puts "failed" unless client.login(email,password)
  when "logout"
    client.logout
  when "token"
    puts client.token
  when "key"
    case ARGV[1]
    when "add"
      if ARGV[2] and File.exists?(ARGV[2])
	c=File.open(ARGV[2]){|f|f.read}
	client.addKey(c)	
      end
    when "remove"
      if ARGV[2] and File.exists?(ARGV[2])
	c=File.open(ARGV[2]){|f|f.read}
	pp client.removeKey(c)
      elsif ARGV[2]=~/^[0-9]*$/
	pp client.removeKey(nil,ARGV[2])
      end
    when "list"
      pp client.keys
    end
  else
    puts "unknown command"
    exit 1
  end

end
