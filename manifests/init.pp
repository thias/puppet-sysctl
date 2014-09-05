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
  $ensure  = undef,
  $value   = undef,
  $prefix  = undef,
  $suffix  = '.conf',
  $comment = undef,
  $content = undef,
  $source  = undef,
) {

  include '::sysctl::base'

  # If we have a prefix, then add the dash to it
  if $prefix {
    $sysctl_d_file = "${prefix}-${title}${suffix}"
  } else {
    $sysctl_d_file = "${title}${suffix}"
  }

  # If we have an explicit content or source, use them
  if $content or $source {
    $file_content = $content
    $file_source = $source
  } else {
    $file_content = template("${module_name}/sysctl.d-file.erb")
  }

  if $ensure != 'absent' {

    # Present

    # The permanent change
    file { "/etc/sysctl.d/${sysctl_d_file}":
      ensure  => $ensure,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $file_content,
      source  => $file_source,
      notify  => [
        Exec["sysctl-${title}"],
        Exec["update-sysctl.conf-${title}"],
      ],
    }

    # The immediate change + re-check on each run "just in case"
    exec { "sysctl-${title}":
      command     => "/sbin/sysctl -p /etc/sysctl.d/${sysctl_d_file}",
      refreshonly => true,
      require     => File["/etc/sysctl.d/${sysctl_d_file}"],
    }

    # For the few original values from the main file
    exec { "update-sysctl.conf-${title}":
      command     => "sed -i -e 's#^${title} *=.*#${title} = ${value}#' /etc/sysctl.conf",
      path        => [ '/usr/sbin', '/sbin', '/usr/bin', '/bin' ],
      refreshonly => true,
      onlyif      => "grep -E '^${title} *=' /etc/sysctl.conf",
    }

  } else {

    # Absent
    # We cannot restore values, since defaults can not be known... reboot :-/

    file { "/etc/sysctl.d/${sysctl_d_file}":
      ensure => absent,
    }

  }

}

