# Define: sysctl
#
# Manage sysctl variable values.
#
# Parameters:
#  $ensure:
#    Whether the variable's value should be 'present' or 'absent'.
#    Defaults to 'present'.
#
# Sample Usage :
#  sysctl { 'net.ipv6.bindv6only': value => '1' }
#
define sysctl ( $value = undef, $ensure = undef ) {

    # Parent purged directory
    include sysctl::base

    # The permanent change
    file { "/etc/sysctl.d/${title}.conf":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => "${title} = ${value}\n",
        ensure  => $ensure,
        notify  => Exec["sysctl-${title}"],
    }

    # The immediate change
    exec { "sysctl-${title}":
        command => "/sbin/sysctl -w ${title}=${value}",
        unless  => "/bin/echo $(/sbin/sysctl -n ${title}) | /bin/grep -q -e '^${value}$'",
    }

    # For the few original values from the main file
    exec { "update-sysctl.conf-${title}":
        command => "sed -i -e 's/${title} =.*/${title} = ${value}/' /etc/sysctl.conf",
        unless  => "/bin/bash -c \"! egrep '^${title} =' /etc/sysctl.conf || egrep '^${title} = ${value}\$' /etc/sysctl.conf\"",
        path    => [ '/usr/sbin', '/sbin', '/usr/bin', '/bin' ],
    }

}

