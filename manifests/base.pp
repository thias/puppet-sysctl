# Class: sysctl::base
#
# Common part for the sysctl definition. Not meant to be used on its own.
#
class sysctl::base (
  $purge     = false,
  $symlink99 = $::sysctl::params::symlink99,
) inherits ::sysctl::params {

  if $purge {
    $recurse = true
  } else {
    $recurse = false
  }

  file { '/etc/sysctl.d':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    # Magic hidden here
    purge   => $purge,
    recurse => $recurse,
  }

  if $symlink99 {
    file { '/etc/sysctl.d/99-sysctl.conf':
      ensure => link,
      target => '../sysctl.conf',
    }
  }

}

