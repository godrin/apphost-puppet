require File.expand_path('../model.rb',__FILE__)
require 'pp'
require 'fileutils'

class AppRun
  @@appBaseDir="/home/runner/tmp"

  def initialize(appName)
    @appDir=File.join(@@appBaseDir,appName)
    @appName=appName
    filename=File.join(@appDir,"Procfile")
    unless File.exists?(filename)
      # fallback
      File.open(filename,"w"){|f|f.puts "web: bundle exec rackup -p $PORT -E $RACK_ENV"}
    end
    @config=YAML.load File.open(filename){|f|f.read}
  end

  def self.appBaseDir=(appBaseDir)
    @@appBaseDir=appBaseDir
  end
  def run(params={})
    raise RuntimeError,"Nothing checked out in #{@appDir} !" unless File.exists?(@appDir)

    unless pid=fork
      params.each{|k,v|ENV[k]=v.to_s}
      Dir.chdir(@appDir)
      fifoDir="../../fifos"
      FileUtils.mkdir_p(fifoDir)
      out=File.join(fifoDir,"#{@appName}_out")
      err=File.join(fifoDir,"#{@appName}_err")
      [out,err].each{|f|system("mkfifo #{f}") unless File.exists?(f)}
      STDOUT.reopen(out)
      STDERR.reopen(err)
      call=@config["web"]
      pp "CALL",call
      args=call.split(" ")
      pp "ARGS",args
      args[0]=`which #{args[0]}`.chomp
      args=args.map{|a|a.gsub(/\$[a-zA-Z_][a-zA-Z0-9_]*/){|p|
	puts "P",p,params[p[1..-1]]
	params[p[1..-1]]
      }
      }
      pp "ARGS2",args
      exec(*args)
      #@config["web"].split(" "))
    end
    pid
  end
end

class ProcControl
  def self.existant?(pid)
    File.exists?("/proc/#{pid}")
  end
  def self.run(procName)
    puts "RUN #{procName}"
    appRun=AppRun.new(procName)
    pp appRun

    appRun.run "RACK_ENV"=>"development","PORT"=>9999,"DATABASE_URL"=>"DBURL"
  end
  def self.kill(pid)
    Process.kill(15,pid)
    sleep 0.5
    Process.kill(9,pid) if self.existant?(pid)
  end

  def self.checkAll
    AppProcess.all.each{|process|
      self.checkProcess(process)
    }
  end
  def self.checkProcess(process)
    if process.pid
      if not ProcControl.existant?(process.pid)
	process.pid=nil
	process.save
      end
    end


    unless process.pid
      begin
	pid=ProcControl.run(process.name)
	if pid
	  process.pid=pid
	  process.save
	end
      rescue RuntimeError=>e
	pp e
      end
    end
    pp process
  end
end



