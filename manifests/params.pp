# @api private
class sysctl::params {
  # Keep the original symlink if we purge, to avoid ping-pong with initscripts
  if (
    $facts['os']['family'] == 'RedHat' and versioncmp($facts['os']['release']['major'], '7') >= 0
  ) or (
    $facts['os']['family'] == 'Debian' and versioncmp($facts['os']['release']['major'], '8') >= 0
  ) {
    $symlink99 = true
  } else {
    $symlink99 = false
  }

  $sysctl_dir = true
  $sysctl_dir_path = '/etc/sysctl.d'
  $sysctl_dir_owner = 'root'
  $sysctl_dir_group = 'root'
  $sysctl_dir_mode = '0755'
}
