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
#  sysctl::configuration { 'net.ipv6.bindv6only': value => '1' }
define sysctl::configuration (
  String $variable      = $title,
  String $ensure        = 'present',
  String $value         = undef,
  String $prefix        = undef,
  String $suffix        = '.conf',
  String $comment       = undef,
  String $content       = undef,
  String $source        = undef,
  Boolean $enforce      = true,
  String $sysctl_binary,
  String $sysctl_dir_path,
) {

  # If we have a prefix, then add the dash to it
  if $prefix {
    $_sysctl_d_file = "${prefix}-${variable}${suffix}"
  } else {
    $_sysctl_d_file = "${variable}${suffix}"
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

  if $ensure != 'absent' {

    # Present

    # Temporary file created and "sysctl -p filename" is run on that
    # If exit code is 0, the kernel setting has changed and puppet
    # copies the file to its permanent location.
    # Advantage: file in /etc/sysctl.d only if setting is good
    # Disadvantage: kernel setting will change but will fail on reboot
    # if there is a problem creating file (an obvious failure in the logs)
    file { "${sysctl_dir_path}/${sysctl_d_file}":
      ensure       => $ensure,
      owner        => 'root',
      group        => 'root',
      mode         => '0644',
      content      => $file_content,
      source       => $file_source,
      notify       => Exec["update-sysctl.conf-${variable}"],
      validate_cmd => "${sysctl_binary} -p %",
    }

    # For the few original values from the main file
    exec { "update-sysctl.conf-${variable}":
      command     => "sed -i -e 's#^${variable} *=.*#${variable} = ${value}#' /etc/sysctl.conf",
      path        => [ '/usr/sbin', '/sbin', '/usr/bin', '/bin' ],
      refreshonly => true,
      onlyif      => "grep -E '^${variable} *=' /etc/sysctl.conf",
    }

    # Enforce configured value during each run (can't work with custom files)
    if $enforce and ! ( $content or $source ) {
      $qvariable = shellquote($variable)
      # Value may contain '|' and others, we need to quote to be safe
      # Convert any numerical to expected string, 0 instead of '0' would fail
      # lint:ignore:only_variable_string Convert numerical to string
      $qvalue = shellquote("${value}")
      # lint:endignore
      exec { "enforce-sysctl-value-${qvariable}":
          command => "${sysctl_binary} -w ${qtitle}=${qvalue}",
          path    => [ '/usr/sbin', '/sbin', '/usr/bin', '/bin' ],
          unless  => "test \"$(${sysctl_binary} -n ${qvariable})\" = ${qvalue}",
      }
    }

  } else {
    # absent: cannot restore values, since defaults unknown... reboot :-/
    file { "${sysctl_dir_path}/${sysctl_d_file}":
      ensure => absent,
    }
  }

}
