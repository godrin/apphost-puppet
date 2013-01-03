class gitserver {

  class { 'gitolite':
    gituser => 'git',
    admin_key => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/dSbDKRHBpzaBbCwVEwuqs2ChYn+wvwM+pXLmi7FHG1CfJFuG373fDQNuMfxxbMUxc4n17Vddlqyve2137lsKvnyzzsXSIW7ylGbarZmI7HQ/5kv3SHBuxXWNEPtTXlBkIGKWOgc3GbaU5jHgsm2WliKV7M2W4v8DhpNYmqq43A6Pf44+a/SUeL67GiaKA18sTtrpIoBvRORQxH7XFl5hj4n6L6cuelyR+5u0xKfKR48RT7I9htXMB8bZ6CMCtSONuIVegd56kRUtKXGU90Svj2WC9diVInlpe1GL3ffnrejG4lsBEA5pGvfACHbys8WANL3d7zD+auukxRv0uSzl gadmin@ubuntu-12',
    path => '/var/lib/git'
  }
  class { 'gadmin':
    require => Class["gitolite"]
  }
}


node ubuntu-12 {
  class { 'base': }
  class { 'gitserver': }

  class { 'proxy': }

  class { 'postgresql-server':
  }
  class { 'postgresql-client':
  }
}
