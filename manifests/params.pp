class sysctl::params {
  case $::kernel {
    'FreeBSD': {
      $management          = 'file'
    }
    default: {
      $sysctl_dir_location = '/etc/sysctl.d'
      $group               = 'root'
      $mode                = '0755'
      $management          = 'directory'
    }
  }
}
