class sysctl::params {

  # Keep the original symlink if we purge, to avoid ping-pong with initscripts
  if ($::osfamily == 'RedHat' and
      versioncmp($::operatingsystemmajrelease, '7') >= 0) or
     ($::osfamily == 'Debian' and
      versioncmp($::operatingsystemmajrelease, '8') >= 0) {
    $symlink99 = true
  } else {
    $symlink99 = false
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

