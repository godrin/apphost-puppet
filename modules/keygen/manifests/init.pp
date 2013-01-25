class keygen {
  define gen($user) {
    exec { "keygen-exec-$user":
      unless=>"test -e /home/$user/.ssh/id_dsa",
	path=>"/bin:/usr/bin",
	command=>"ssh-keygen -t dsa -q -N '' -f /home/$user/.ssh/id_dsa",
	user=>$user,
	require=>File["/home/$user"]
    }
  }
}
