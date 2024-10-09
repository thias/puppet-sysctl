# Define: sysctl
#
# Manage sysctl variable values.
#
# Parameters:
# @param value
#    The value for the sysctl parameter. Mandatory, unless $ensure is 'absent'.
# @param prefix
#    Optional prefix for the sysctl.d file to be created. Default: none.
# @param suffix
#    Optional suffix for the sysctl.d file to be created. Default: '.conf'.
# @param comment
#    Optional Array or String to put inside the sysctl.d file.
# @param content
#    File content of the specific sysctl_d_file.
# @param source
#    File source of the specific sysctl_d_file.
# @param ensure
#    Whether the variable's value should be 'present' or 'absent'.
#    Defaults to 'present'.
# @param enforce
#    Boolean value for the enforcement of the rule. Default: true
#
# Sample Usage :
#  sysctl { 'net.ipv6.bindv6only': value => '1' }
#
define sysctl (
  String                $ensure  = undef,
  String                $value   = undef,
  String                $prefix  = undef,
  String                $suffix  = '.conf',
  Variant[String,Array] $comment = undef,
  Optional[String]      $content = undef,
  Optional[String]      $source  = undef,
  Boolean               $enforce = true,
) {
  include 'sysctl::base'

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
  if $content or $source {
    $file_content = $content
    $file_source = $source
  } else {
    $file_content = template("${module_name}/sysctl.d-file.erb")
    $file_source = undef
  }

  if $ensure != 'false' {
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
