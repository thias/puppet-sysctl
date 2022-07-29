# @summary Common part for the sysctl definition. Not meant to be used on its
# own.
#
# @param purge
# @param values
# @param hiera_merge_values
# @param symlink99
# @param sysctl_dir
# @param sysctl_dir_path
# @param sysctl_dir_owner
# @param sysctl_dir_group
# @param sysctl_dir_mode
#
class sysctl::base (
  Boolean              $purge              = false,
  Optional[Hash]       $values             = undef,
  Boolean              $hiera_merge_values = false,
  Boolean              $symlink99          = $sysctl::params::symlink99,
  Boolean              $sysctl_dir         = $sysctl::params::sysctl_dir,
  Stdlib::Absolutepath $sysctl_dir_path    = $sysctl::params::sysctl_dir_path,
  String               $sysctl_dir_owner   = $sysctl::params::sysctl_dir_owner,
  String               $sysctl_dir_group   = $sysctl::params::sysctl_dir_group,
  Stdlib::Filemode     $sysctl_dir_mode    = $sysctl::params::sysctl_dir_mode,
) inherits sysctl::params {
  # Hiera support
  if $hiera_merge_values == true {
    $values_real = hiera_hash('sysctl::base::values', {})
  } else {
    $values_real = $values
  }
  if $values_real != undef {
    create_resources(sysctl,$values_real)
  }

  if $sysctl_dir {
    if $purge {
      $recurse = true
    } else {
      $recurse = false
    }
    file { $sysctl_dir_path:
      ensure  => 'directory',
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
        owner  => $sysctl_dir_owner,
        group  => $sysctl_dir_group,
        target => '../sysctl.conf',
      }
    }
  }
}
