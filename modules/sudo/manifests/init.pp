class sudo {
  define line($line) {
    lib::line { $line:
      line =>$line,
	   file=>"/etc/sudoers"
    }
  }
}
