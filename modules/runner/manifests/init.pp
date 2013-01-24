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


  sudo::line { "sudo-initdb":
    line=>"#runner     ALL=NOPASSWD:su - postgres /usr/local/bin/init_db.sh" 
  }

  completeuser { "runner":
    name => "runner"
  }

}
