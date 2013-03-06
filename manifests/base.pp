# Class: sysctl::base
#
# Common part for the sysctl definition. Not meant to be used on its own.
# 
class sysctl::base {

  file { '/etc/sysctl.d':
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    ensure => directory,
    # Magic hidden here
    purge  => true,
  }

}

