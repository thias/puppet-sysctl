class sysctl::params(
	$keep_symlink99 = false,
) {
  if $keep_symlink99 {
  	$symlink99 = true
  }
  else {
    # Keep the original symlink if we purge, to avoid ping-pong with initscripts
    case "${::osfamily}-${::operatingsystemmajrelease}" {
      'RedHat-7', 'Debian-8': {
        $symlink99 = true
      }
      default: {
        $symlink99 = false
      }
    }
  }

  case $::osfamily {
    'FreeBSD': {
      $sysctl_dir = false
    }
    default: {
      $sysctl_dir = true
      $sysctl_dir_path = '/etc/sysctl.d'
      $sysctl_dir_owner = 'root'
      $sysctl_dir_group = 'root'
      $sysctl_dir_mode = '0755'
    }
  }

}