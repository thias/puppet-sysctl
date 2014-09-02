class sysctl::params {

  # Keep the original symlink if we purge, to avoid ping-pong with initscripts
  case "${osfamily}-${operatingsystemmajrelease}" {
    'RedHat-7': {
      $symlink99 = true
    }
    default: {
      $symlink99 = false
    }
  }

}

