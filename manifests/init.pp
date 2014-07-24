# Define: sysctl
#
# Manage sysctl variable values.
#
# Parameters:
#  $value:
#    The value for the sysctl parameter. Mandatory, unless $ensure is 'absent'.
#  $prefix:
#    Optional prefix for the sysctl.d file to be created. Default: none.
#  $ensure:
#    Whether the variable's value should be 'present' or 'absent'.
#    Defaults to 'present'.
#
# Sample Usage :
#  sysctl { 'net.ipv6.bindv6only': value => '1' }
#
define sysctl (
  $value      = undef,
  $prefix     = undef,
  $comment    = undef,
  $management = $::sysctl::params::management,
  $ensure     = undef,
) {

  include ::sysctl::params
  notify {"value:  ${management}":}
  notify {"value fully qualified: ${::sysctl::params::management}":}

  # validate management input
  if ! member(['directory', 'file'], $::sysctl::params::management) {
    fail ("you must specify either directory or file")
  }

  case $::sysctl::params::management {
    'directory': {
      include ::sysctl::base

      if $osfamily == 'FreeBSD' {
        fail ("FreeBSD does not support /etc/sysctl.d")
      }

      # If we have a prefix, then add the dash to it
      if $prefix {
        $sysctl_d_file = "${prefix}-${title}.conf"
      } else {
        $sysctl_d_file = "${title}.conf"
      }

      if $ensure != 'absent' {

        # Present

        # The permanent change
        file { "/etc/sysctl.d/${sysctl_d_file}":
          ensure  => $ensure,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => template("${module_name}/sysctl.d-file.erb"),
          notify  => [
            Exec["sysctl-${title}"],
            Exec["update-sysctl.conf-${title}"],
          ],
        }

        # The immediate change + re-check on each run "just in case"
        exec { "sysctl-${title}":
          command     => "sysctl -p /etc/sysctl.d/${sysctl_d_file}",
          path        => [ '/usr/sbin', '/sbin', '/usr/bin', '/bin' ],
          refreshonly => true,
          require     => File["/etc/sysctl.d/${sysctl_d_file}"],
        }

        # Remove parameter from sysctl.conf if it exists
        exec { "update-sysctl.conf-${title}":
          command     => "sed -i -e '/^${title} *=/d' /etc/sysctl.conf",
          path        => [ '/usr/sbin', '/sbin', '/usr/bin', '/bin' ],
          refreshonly => true,
          unless      => "grep -E '^${title} *=' /etc/sysctl.conf",
        }

      } else {

        # Absent
        # We cannot restore values, since defaults can not be known...reboot :-/

        file { "/etc/sysctl.d/${sysctl_d_file}":
          ensure => absent,
        }
      }

    }
    'file': {
      if $ensure != 'absent' {

        # Present

        # The permanent change
        file_line { "sysctl.conf line for ${title}":
          path   => '/etc/sysctl.conf',
          line   => "${title}=${value}",
          match  => "^${title} *=",
          notify => Exec["sysctl ${title}"],
        }

        # The immediate change + re-check on each run "just in case"
        exec { "sysctl ${title}":
          command     => "sysctl ${title}=${value}",
          path        => [ '/usr/sbin', '/sbin', '/usr/bin', '/bin' ],
          refreshonly => true,
          onlyif      => "grep -E '^${title}=' /etc/sysctl.conf",
        }
      } else {

        # Absent
        # delete sysctl parameter from sysctl.conf

        exec { "remove-sysctl.conf-${title}":
          command => "sed -i '' -e '/^${title} *=/d /etc/sysctl.conf",
          path        => [ '/usr/sbin', '/sbin', '/usr/bin', '/bin' ],
          refreshonly => true,
          onlyif      => "grep -E '^${title} *=' /etc/sysctl.conf",
        }
      }
    }
    default: {
      fail("no management type defined")
    }
  }
}
