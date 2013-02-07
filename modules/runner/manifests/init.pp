class runner {
  define completeuser($name) {

    group { $name:
      ensure => "present"
    }
    user { $name:
      ensure=>"present",
	gid => $name,
	require => Group[$name],
	shell => "/bin/bash"
    }
    file { "/home/$name":
      ensure => "directory",
	     owner=>$name,
	     group => $name,
	     require => User[$name]
    }
    file { "/home/$name/.bashrc":
      ensure => "file",
	     source => "/etc/skel/.bashrc",
	     owner => $name,group=>$name
    }
    file { "/home/$name/.bash_logout":
      ensure => "file",
	     source => "/etc/skel/.bash_logout",
	     owner => $name,group=>$name
    }
    file { "/home/$name/.profile":
      ensure => "file",
	     source => "/etc/skel/.profile",
	     owner => $name,group => $name
    }
  }


  file { "/usr/local/bin/init_db.sh":
    source => "puppet:///modules/runner/init_db.sh",
    mode=>"0755"
  }
  file { "/home/runner/run.sh":
    mode=>"0755",
    owner=>"runner",
    group=>"runner",
    source => "puppet:///modules/runner/run.sh"
  }
  file { "/home/runner/clone.sh":
    mode=>"0755",
      owner=>"runner",
      group=>"runner",
      source => "puppet:///modules/runner/clone.sh"
  }

  file { "/home/runner/monitor_process.sh":
    mode=>"0755",
      owner=>"runner",
      group=>"runner",
      source => "puppet:///modules/runner/monitor_process.sh"
  }

  file { "/home/runner/control":
    owner=>"runner",group=>"runner",
  #  source => "puppet:///modules/runner/control",
    ensure=>"directory"
  } 
  file { "/home/runner/control/model.rb":
    owner=>"runner",group=>"runner",
    source=>"puppet:///modules/runner/control/model.rb",
    ensure=>"file"
  }
  file { "/home/runner/control/monitor.rb":
    owner=>"runner",group=>"runner",
    source=>"puppet:///modules/runner/control/monitor.rb",
    ensure=>"file"
  }



  sudo::line { "sudo-initdb":
    line=>"runner     ALL=(postgres) NOPASSWD: /usr/local/bin/init_db.sh" 
  }

  completeuser { "runner":
    name => "runner"
  }
  class runnerKeygen {
    keygen::gen { "runner-key":
      user=>"runner"
    }
  }
  class { 'runnerKeygen': }
  file { "/home/runner/runner.pub":
    source=>"/home/runner/.ssh/id_dsa.pub",
      require=>Class["runnerKeygen"]
  }
  exec { "rm -rf gitolite-admin && git clone git@localhost:gitolite-admin.git && cd gitolite-admin && cp /home/runner/runner.pub keydir/ && git add keydir/runner.pub && git commit -a -m 'runner key' && git pushi && cp /home/runner/runner.pub /home/gadmin/runner.pub":   
 user=>"gadmin",
    require=>[User["gadmin"],File["/home/runner/runner.pub"]],
    path=>"/usr/bin:/bin",
    cwd=>"/tmp",
    environment=>"HOME=/home/gadmin",
    unless=>"test -e /home/gadmin/runner.pub",

  }

  file { "/home/runner/.ssh/known_hosts":
    require=>[User["runner"],File["/home/gadmin/.ssh/known_hosts"]],
    ensure=>"file",
    source=>"/home/gadmin/.ssh/known_hosts",
    owner=>"runner",
    group=>"runner"
  }
}
