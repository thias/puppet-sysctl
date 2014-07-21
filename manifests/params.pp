class sysctl::params {
  case $::osfamily {
    'FreeBSD': {
      $sysctl_location = '/etc/sysctl.conf'
      $ensure          = 'file'
      $group           = 'wheel'
      $mode            = '0644'
    }
    default: {
      $sysctl_location = '/etc/sysctl.d'
      $ensure          = 'directory'
      $group           = 'root'
      $mode            = '0755'
    }
  }
}
