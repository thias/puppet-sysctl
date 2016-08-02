class sysctl (Boolean $purge,
              Hash    $values,
              Boolean $symlink99,
              String  $sysctl_binary,
              Boolean $sysctl_dir,
              String  $sysctl_dir_path,
              String  $sysctl_dir_owner,
              String  $sysctl_dir_group,
              String  $sysctl_dir_mode) {

  $defaults = {
    sysctl_binary   => $sysctl_binary,
    sysctl_dir_path => $sysctl_dir_path,
  }
  create_resources(sysctl::configuration, $values, $defaults)

  if $sysctl_dir {
    # if we're purging we should also recurse
    $recurse = $purge
    file { $sysctl_dir_path:
      ensure  => directory,
      owner   => $sysctl_dir_owner,
      group   => $sysctl_dir_group,
      mode    => $sysctl_dir_mode,
      purge   => $purge,
      recurse => $recurse,
    }

    if $symlink99 and $sysctl_dir_path =~ /^\/etc\/[^\/]+$/ {
      file { "${sysctl_dir_path}/99-sysctl.conf":
        ensure => link,
        target => '../sysctl.conf',
      }
    }
  }
}
