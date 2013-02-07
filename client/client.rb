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

  def addKeyFromFile(fileName)
    if fileName and File.exists?(fileName)
      c=File.open(fileName){|f|f.read}
      client.addKey(c)
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

