class gadmin {
  user { "gadmin":
    ensure=>"present",
    gid => "gadmin",
    require => Group["gadmin"]
  }
  group { "gadmin":
    ensure => "present"
  }
  file { "/home/gadmin":
    ensure => "directory",
    owner=>"gadmin",
    group => "gadmin",
    require => User["gadmin"]
  }
  file { "/home/gadmin/app":
    ensure=> "directory",
    recurse => "true",
    source => "puppet:///modules/gadmin/admin",
    owner => "gadmin",
    require => [User["gadmin"],File["/home/gadmin"]]
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

  service { "gadmin":
    ensure => "running",
    require => [File["/etc/init.d/gadmin"],Package["bundler"]]
  }
    


}
