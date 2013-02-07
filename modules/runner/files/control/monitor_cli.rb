#!/usr/bin/env ruby

require File.expand_path('../monitor.rb',__FILE__)

args=ARGV

while args.length>0
  cur=args.shift
  case cur
  when "--appdir"
    appdir=args.shift

  when "add"
    procName=args.shift
    if procName
      dbConnect=args.shift

      freePort=AppProcess.findFreePort      
      AppProcess.create({:databaseUrl=>dbConnect,:name=>procName,:port=>freePort})
    end
  when "delete"
    procName=args.shift
    if procName
      app=AppProcess.first({:name=>procName})
      if app
	ProcControl.kill(app.pid) if app.pid
	app.destroy
	puts "app destroyed"
      end
    end
  when "list"
    pp AppProcess.all
  end

end

ProcControl.checkAll
