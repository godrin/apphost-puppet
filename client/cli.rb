#!/usr/bin/env ruby

require File.expand_path('../client.rb',__FILE__)

client=Client.new
if ARGV.length>0
  case ARGV[0]
  when "repo"
    case ARGV[1]
    when "list"
      pp client.repos
      exit
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
	  puts "git push apphost master"
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
	client.addKeyFromFile(ARGV[2])
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




