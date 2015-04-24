# Class: sysctl::base
#
# Common part for the sysctl definition. Not meant to be used on its own.
#
class sysctl::base (
  $purge              = false,
  $symlink99          = $::sysctl::params::symlink99,
  $sysctl_dir         = $::sysctl::params::sysctl_dir,
  $sysctl_dir_path    = $::sysctl::params::sysctl_dir_path,
  $sysctl_dir_owner   = $::sysctl::params::sysctl_dir_owner,
  $sysctl_dir_group   = $::sysctl::params::sysctl_dir_group,
  $sysctl_dir_mode    = $::sysctl::params::sysctl_dir_mode,
) inherits ::sysctl::params {

  if $sysctl_dir {

    if $purge {
      $recurse = true
    } else {
      $recurse = false
    }

    file { $sysctl_dir_path:
      ensure  => directory,
      owner   => $sysctl_dir_owner,
      group   => $sysctl_dir_group,
      mode    => $sysctl_dir_mode,
      # Magic hidden here
      purge   => $purge,
      recurse => $recurse,
    }

    if $symlink99 and $sysctl_dir_path =~ /^\/etc\/[^\/]+$/ {
      file { "${sysctl_dir_path}/99-sysctl.conf":
        ensure => link,
        target => '../sysctl.conf',
      }
    }
  
  }

}

