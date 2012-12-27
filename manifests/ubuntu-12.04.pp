class gitserver {

  class { 'gitolite':
    gituser => 'git',
	    admin_key => 'ssh-dss AAAAB3NzaC1kc3MAAACBAIikAPitqBkxvI36yJj/4yBrLvNg8gO2mKKpE85Yh9ns/SIOCV8EBiMyPh2f6cE3zla0Rq8XA78QbQqPoyrc1/gb7fq5qlUucaKZ0T5GOcaRMNdJOvw7mRGZg//l+983Ak1xvKwpa5RibC96CbIH32NVqa+IlcVmxGx4SmrVnsx3AAAAFQCgvFq4IW+JfGdgbO1rbzGhQ6f4kQAAAIAF3GCEhdeBqFjT/4lDopSN+KC9BgMYDSKYD4+dkToVYTSIkq/Xn4cdEYE7slN0WyrdprVy/hSddGY97jnH7JgdM6IYHe0T/KtcNGpNf+/O8xSZRBug6QPy3DPWKBA6PCOBLzV7Q91X7yXOhs/c2IOE+n13Lji36RcXsv4eLPuQPwAAAIBm9zYgjH23GgcCUmpw2ut+PqxUTJ5DzzMFuVi1O9CiQpbf6SNLufkngbNs0mClXqShplPQAgiY7zRVxsY994uHSZXF7wUTUEbx5KThFX7Fzz4E3FUGICo16qrAU7VBBeAbrF1jeEqbx46A4DbWkL1joQnnJqGzh2mvTEkW1ya/Ow== david@maclin',
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
