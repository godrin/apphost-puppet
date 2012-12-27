class proxy {
  package { ["nginx"]:
    ensure=>"present"
  }

  service { "nginx":
    ensure => "running"
  }

}
