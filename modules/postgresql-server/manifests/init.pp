class postgresql-server {
  package { "postgresql":

  }
  lib::line { "pg-local-access":
    line=>"host    sameuser             all             all            md5",
    file=>"/etc/postgresql/9.1/main/pg_hba.conf",
    notify=>Service["postgresql"]
  }

  service { "postgresql":
    ensure=>"running"
  }

}
