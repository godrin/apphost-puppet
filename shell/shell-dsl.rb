require "pp"

class ShellDsl

  def initialize( &dsl_block )
    @shell_commands = Hash.new
    instance_eval( &dsl_block )
  end

  def define( name, *args )
    cmdhash = {
      :args => args,
      :vars => Hash.new,
      :commands => Array.new,
    }
    @shell_commands[name] = cmdhash

    @current_shell_command = name
  end

  def defvars( *names )
    names.each { |name|
      if !name.is_a? Symbol
        raise "variable names must be of type symbol"
      end
      @shell_commands[@current_shell_command][:vars][name] = true
    }
  end

  def cmd( command, *args )
    args.find_all { |arg| arg.is_a? Symbol }.each { |arg|
      if !@shell_commands[@current_shell_command][:vars][arg]
        raise "Unknown variable #{arg}"
      end
    }
    cmddefinition = {
      :command => command,
      :args => args
    }
    @shell_commands[@current_shell_command][:commands].push( cmddefinition )
  end

  def run( name, varvaluehash )
    @shell_commands[name][:commands].each { |cmddefinition|
      cmdstring = cmddefinition[:command]
        .concat( " " )
        .concat( cmddefinition[:args]
                   .map { |arg| arg.is_a?( Symbol ) ? varvaluehash[arg] : arg }
                   .join " " )
      cmd_output = `#{cmdstring}`
      puts cmd_output
#      puts "done (#{$?.exitstatus}, #{cmd_output})"
    }
  end

end



ShellDsl.new {
  define :myecho
  defvars :msg1, :msg2, :msg3
  cmd "echo", "erstmal langsam...", :msg1
  cmd "echo", :msg2
  cmd "echo", :msg3

  define :mysleep
  defvars :seconds
  cmd "echo", "starting to sleep for ", :seconds, " seconds..."
  cmd "sleep", :seconds
  cmd "echo", "...done."


  run :myecho, {
    :msg1 => "anfangen.",
    :msg2 => "wurstbrot",
    :msg3 => "schinken auch noch"
  }
  run :mysleep, { :seconds => 2 }
}
