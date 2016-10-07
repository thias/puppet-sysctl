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
  String $variable               = $title,
  String $ensure                 = 'present',
  Variant[String,Undef] $value   = undef,
  Variant[String,Undef] $prefix  = undef,
  String $suffix                 = '.conf',
  Variant[String,Undef] $comment = undef,
  Variant[String,Undef] $content = undef,
  Variant[String,Undef] $source  = undef,
  Boolean $enforce               = true,
  String $sysctl_binary          = '/sbin/sysctl',
  String $sysctl_dir_path        = '/etc/sysctl.d',
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

    # Enforce configured value during each run when set by value
    # (doesn't work with custom files)
    $enforcing = $enforce and ! ( $content or $source )
    if $enforcing {
      $qvariable = shellquote($variable)
      # Value may contain '|' and others, we need to quote to be safe
      # Convert any numerical to expected string, 0 instead of '0' would fail
      # lint:ignore:only_variable_string Convert numerical to string
      $qvalue = shellquote($value)
      # lint:endignore
      exec { "enforce-sysctl-value-${qvariable}":
        command => "${sysctl_binary} -w ${qvariable}=${qvalue}",
        path    => [ '/usr/sbin', '/sbin', '/usr/bin', '/bin' ],
        unless  => "test \"$(${sysctl_binary} -n ${qvariable} | sed \"s,[[:space:]]\\+, ,g\")\" = ${qvalue}",
      }
    }

    # if we are enforcing values on every run, do so only if the file
    # doesn't need updating
    $before = $enforcing ? {
      true  => Exec["enforce-sysctl-value-${qvariable}"],
      false => undef,
    }

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
      notify       => Exec["remove-${variable}-from-sysctl.conf"],
      validate_cmd => "${sysctl_binary} -p %",
      before       => $before,
    }

    # Remove any entries from the main sysctl.conf because we have
    # already set them in /etc/sysctl.d
    exec { "remove-${variable}-from-sysctl.conf":
      command => "sed -i -e '/^${variable} *=/d' /etc/sysctl.conf",
      path    => [ '/usr/sbin', '/sbin', '/usr/bin', '/bin' ],
      onlyif  => "grep -E '^${variable} *=' /etc/sysctl.conf",
      require => File["${sysctl_dir_path}/${sysctl_d_file}"],
    }

  } else {
    # absent: cannot restore values, since defaults unknown... reboot :-/
    file { "${sysctl_dir_path}/${sysctl_d_file}":
      ensure => absent,
    }
  }

}
