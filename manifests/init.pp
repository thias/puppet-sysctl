# @summary
#   Manage sysctl variable values.
#
# @example
#   Sample Usage :
#   sysctl { 'net.ipv6.bindv6only': value => '1' }
#
# @param ensure
#   Whether the variable's value should be 'present' or 'absent'.
#   Defaults to 'present'.
#
# @param value
#   The value for the sysctl parameter. Mandatory, unless $ensure is 'absent'.
#
# @param prefix
#   Optional prefix for the sysctl.d file to be created. Default: none.
#
# @param suffix
#   Optional suffix for the sysctl.d file to be created. Default: '.conf'.
#
# @param comment
#   Comment(s) to be added to the sysctl.d file.
#
# @param content
#   Content for the sysctl.d file to be used instead of the template.
#
# @param source
#   Source file for the sysctl.d file to be used instead of the template.
#
# @param enforce
#   Enforce configured value during each run (can't work with custom files).
#
define sysctl (
  Enum['present', 'absent']           $ensure  = 'present',
  Optional[String[1]]                 $value   = undef,
  Optional[String[1]]                 $prefix  = undef,
  String                              $suffix  = '.conf',
  Optional[Variant[Array, String[1]]] $comment = undef,
  Optional[String[1]]                 $content = undef,
  Optional[Stdlib::Filesource]        $source  = undef,
  Boolean                             $enforce = true,
) {
  include sysctl::base

  if ! ($ensure == 'absent') and ! $value {
      fail("${title} was defined without a target value, failing...")
  }

  # If we have a prefix, then add the dash to it
  if $prefix {
    $_sysctl_d_file = "${prefix}-${title}${suffix}"
  } else {
    $_sysctl_d_file = "${title}${suffix}"
  }

  # Some sysctl keys contain a slash, which is not valid in a filename.
  # Most common at those on VLANs: net.ipv4.conf.eth0/1.arp_accept = 0
  $sysctl_d_file = regsubst($_sysctl_d_file, '[/ ]', '_', 'G')

  # If we have an explicit content or source, use them
  if $content {
    $file_content = $content
  } else {
    $file_content = epp("${module_name}/sysctl.d-file.epp", { 'comment' => $comment, 'key_name' => $title, 'key_val' => $value })
  }

  if $ensure == 'present' {
    # The permanent change
    file { "/etc/sysctl.d/${sysctl_d_file}":
      ensure  => $ensure,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $file_content,
      source  => $source,
      notify  => [
        Exec["sysctl-${title}"],
        Exec["update-sysctl.conf-${title}"],
      ],
    }

    # The immediate change + re-check on each run "just in case"
    exec { "sysctl-${title}":
      command     => "sysctl -p /etc/sysctl.d/${sysctl_d_file}",
      path        => ['/usr/sbin', '/sbin', '/usr/bin', '/bin'],
      refreshonly => true,
      require     => File["/etc/sysctl.d/${sysctl_d_file}"],
    }

    # For the few original values from the main file
    exec { "update-sysctl.conf-${title}":
      command     => "sed -i -e 's#^${title} *=.*#${title} = ${value}#' /etc/sysctl.conf",
      path        => ['/usr/sbin', '/sbin', '/usr/bin', '/bin'],
      refreshonly => true,
      onlyif      => "grep -E '^${title} *=' /etc/sysctl.conf",
    }

    # Enforce configured value during each run (can't work with custom files)
    if $enforce and ! ( $content or $source ) {
      $qtitle = shellquote($title)
      # Value may contain '|' and others, we need to quote to be safe
      # Convert any numerical to expected string, 0 instead of '0' would fail
      # lint:ignore:only_variable_string Convert numerical to string
      $qvalue = shellquote("${value}")
      # lint:endignore
      exec { "enforce-sysctl-value-${qtitle}":
        unless  => "/usr/bin/test \"$(/sbin/sysctl -n ${qtitle} | /usr/bin/sed -r -e 's/[ \t]+/ /g')\" = ${qvalue}",
        command => "/sbin/sysctl -w ${qtitle}=${qvalue}",
      }
    }
  } else {
    # Absent
    # We cannot restore values, since defaults can not be known... reboot :-/

    file { "/etc/sysctl.d/${sysctl_d_file}":
      ensure => absent,
    }
  }
}
