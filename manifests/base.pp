# Class: sysctl::base
#
# Common part for the sysctl definition. Not meant to be used on its own.
#
class sysctl::base (
  $purge = false,
) {

  if $purge {
    $recurse = true
  } else {
    $recurse = false
  }

  file { $::sysctl::params::sysctl_location:
    ensure  => $::sysctl::params::ensure,
    owner   => 'root',
    group   => $::systcl::params::group,
    mode    => $::sysctl::params::mode,
    # Magic hidden here
    purge   => $purge,
    recurse => $recurse,
  }

}

