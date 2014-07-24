class sysctl::params {
  case $::kernel {
    'Linux': {
      $sysctl_dir_location = '/etc/sysctl.d'
      $group           = 'root'
      $mode            = '0755'
    }
    default: {
      $sysctl_dir_location = '/etc/sysctl.d'
      $group           = 'root'
      $mode            = '0755'
    }
  }
}
