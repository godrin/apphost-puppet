#!/usr/bin/env ruby

require 'nestful'
require 'pp'

server=Nestful::Resource.new("http://localhost:9292")

if ARGV.length>0
  if ARGV[0]=="create"
    if ARGV[1]
      result=server["repo"].post
      pp result
    end
  end

end
