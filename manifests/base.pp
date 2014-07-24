# Class: sysctl::base
#
# Common part for the sysctl definition. Not meant to be used on its own.
#
class sysctl::base (
  $purge = false,
) inherits params {

  $sysctl_dir_location = $::sysctl::params::sysctl_dir_location
  $group               = $::systcl::params::group
  $mode                = $::sysctl::params::mode

  if $purge {
    $recurse = true
  } else {
    $recurse = false
  }

  file { $sysctl_dir_location:
    ensure  => directory,
    owner   => 'root',
    group   => $group,
    mode    => $mode,
    # Magic hidden here
    purge   => $purge,
    recurse => $recurse,
  }

}

