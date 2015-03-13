sysctl { 'net.ipv4.ip_forward': value => '1' }
sysctl { 'net.core.somaxconn': value => '65536' }
sysctl { 'vm.swappiness': ensure => absent }

sysctl { 'kernel.core_pattern':
    value   => "|/var/admin/scripts/core-gzip.sh /var/tmp/core/core.%e.%p.%h.%t.gz",
    comment => "wrapper script so that gzip can be given an output path for the coredump",
}

sysctl { 'kernel.domainname':
    value => "foobar.'backquote.com",
}
