# @api private
class sysctl::params {
  # Keep the original symlink if we purge, to avoid ping-pong with initscripts
  $symlink99 = ($facts['os']['family'] == 'RedHat' and versioncmp($facts['os']['release']['major'], '7') >= 0) or
  ($facts['os']['family'] == 'Debian' and versioncmp($facts['os']['release']['major'], '8') >= 0)
}
