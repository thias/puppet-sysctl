# Class: sysctl::base
#
# Common part for the sysctl definition. Not meant to be used on its own.
#
class sysctl::base (
  $purge = true
) {

  file { '/etc/sysctl.d':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    # Magic hidden here
    purge  => $purge,
  }

}

