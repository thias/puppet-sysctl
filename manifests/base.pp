# @summary
#   Common part for the sysctl definition. Not meant to be used on its own.
#
# @param purge
#   Boolean to choose if $sysctl_dir_path should get purged.
#
# @param values
#   Hash of sysctl keys and their values to managed.
#
# @param hiera_merge_values
#   Boolean to choose if $values to be used should be searched in hiera.
#
# @param symlink99
#   Boolean to choose if 99-sysctl.conf should be created.
#
# @param sysctl_dir
#   Boolean to choose if $sysctl_dir_path should be managed.
#
# @param sysctl_dir_path
#   Absolute path of sysctl directory.
#
# @param sysctl_dir_owner
#   Owner for sysctl directory.
#
# @param sysctl_dir_group
#   Group for sysctl directory.
#
# @param sysctl_dir_mode
#   Mode for sysctl directory.
#
class sysctl::base (
  Boolean        $purge              = false,
  Optional[Hash] $values             = undef,
  Boolean        $hiera_merge_values = false,
  Boolean        $symlink99          = $sysctl::params::symlink99,
  Boolean        $sysctl_dir         = $sysctl::params::sysctl_dir,
  String[1]      $sysctl_dir_path    = $sysctl::params::sysctl_dir_path,
  String[1]      $sysctl_dir_owner   = $sysctl::params::sysctl_dir_owner,
  String[1]      $sysctl_dir_group   = $sysctl::params::sysctl_dir_group,
  String[1]      $sysctl_dir_mode    = $sysctl::params::sysctl_dir_mode,
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
