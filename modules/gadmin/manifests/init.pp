class gadmin {
  user { "gadmin":
    ensure=>"present",
      gid => "gadmin",
      require => Group["gadmin"],
    shell => "/bin/bash"
  }
  group { "gadmin":
    ensure => "present"
  }

  file { "/var/log/gadmin":
    require=>User["gadmin"],
    owner=>"gadmin",
    group=>"gadmin",
    ensure => "directory",
    mode => "0755"
  }
  file { "/home/gadmin":
    ensure => "directory",
	   owner=>"gadmin",
	   group => "gadmin",
	   require => User["gadmin"]
  }
  file { "/home/gadmin/.bashrc":
    ensure => "file",
    source => "/etc/skel/.bashrc",
    owner => "gadmin",group=>"gadmin"
  }
  file { "/home/gadmin/.bash_logout":
    ensure => "file",
    source => "/etc/skel/.bash_logout",
    owner => "gadmin",group=>"gadmin"
  }
  file { "/home/gadmin/.profile":
    ensure => "file",
    source => "/etc/skel/.profile",
    owner => "gadmin",group => "gadmin"
  }
  file { "/home/gadmin/app":
    ensure=> "directory",
      recurse => "true",
      source => "puppet:///modules/gadmin/admin",
      owner => "gadmin",
      require => [User["gadmin"],File["/home/gadmin"]]
  }
  exec { "gadmin_keys":
    unless=>"test -e /home/gadmin/.ssh/id_dsa",
    path=>"/bin:/usr/bin",
    command=>"ssh-keygen -t dsa -q -N '' -f /home/gadmin/.ssh/id_dsa",
    notify=>Exec["append_gadmin_key"],
    require=>File["/home/gadmin/bin"]
  }

  file { "/home/gadmin/bin":
    source=>"puppet:///modules/gadmin/bin",
    ensure=>"directory",
    recurse=>"true"
  }

  exec { "config_git":
    command=>"git config --global user.email 'gadmin@localhost' && git config --global user.name 'Git Admin'",
    path=>"/bin:/usr/bin",
    user => "gadmin",
    environment => "HOME=/home/gadmin"
  }


  exec { "append_gadmin_key":
    unless=>"test -e /var/lib/git/.gitolite/keydir/gadmin.pub",
    path=>"/bin/:/usr/bin",
    command=>"/home/gadmin/bin/gadmin_add_keys.sh",
    require=>[Exec["admin_repo"],Exec["gadmin_keys"],File["/home/gadmin/bin"],Exec["config_git"]],
    user => "gadmin"
  }
  exec { "known_hosts":
    path=>"/bin:/usr/bin",
    unless=>"grep localhost /home/gadmin/.ssh/known_hosts",
    command=>"ssh-keyscan localhost>/home/gadmin/.ssh/known_hosts",
  }
  file { "/home/gadmin/.ssh/known_hosts":
    ensure => "file",
    owner => "gadmin",
    group => "gadmin",
    mode => "0600"
  }
  file { "/home/gadmin/.ssh/id_rsa":
    source => "puppet:///modules/gadmin/initial_keys/id_rsa",
    ensure => "file",
    owner => "gadmin",
    group => "gadmin",
    mode => "0600"
  }
  file { "/home/gadmin/.ssh/id_rsa.pub":
    source => "puppet:///modules/gadmin/initial_keys/id_rsa.pub",
    ensure => "file",
    owner => "gadmin",
    group => "gadmin",
    mode => "0644"
  }
  file { "/home/gadmin/.ssh/id_dsa":
    owner => "gadmin",
    group => "gadmin",
    mode => "0600"
  }
  file { "/home/gadmin/.ssh/id_dsa.pub":
    owner => "gadmin",
    group => "gadmin",
    mode => "0644"
  } 


  exec { "admin_repo":
    path=>"/bin:/usr/bin",
    unless=>"test -e /home/gadmin/repo",
    command=>"echo 'git clone git@localhost:gitolite-admin /home/gadmin/repo'|sudo su - gadmin",
    require=>[Exec["known_hosts"],File["/home/gadmin/.ssh/id_rsa"],File["/home/gadmin/.ssh/id_rsa.pub"]]
  }
  file { "/etc/init.d/gadmin":
    ensure => "file",
	   source => "puppet:///modules/gadmin/etc/init.d/gadmin",
	   mode => "755",
	   require => File["/home/gadmin/app"]
  }
  package { "bundler":
    provider => 'gem',
     ensure => "installed",
  }

  package { ["libsqlite3-dev"]:
    ensure => "installed"
  }

  service { "gadmin":
    ensure => running,
	   require => [File["/etc/init.d/gadmin"],Package["bundler"], File["/home/gadmin/app"],Exec["admin_repo"],Package["libsqlite3-dev"]],
	   subscribe=>File["/home/gadmin/app"]
  }



}
