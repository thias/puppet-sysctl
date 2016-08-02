sysctl::configuration { 'net.ipv4.ip_forward': value => '1' }
sysctl::configuration { 'net.core.somaxconn': value => '65536' }
sysctl::configuration { 'vm.swappiness': ensure => absent }
sysctl::configuration { 'net.ipv4.conf.eth0/1.forwarding': value => 1 }
sysctl::configuration { 'kernel.domainname': value => "foobar.'backquote.com" }
sysctl::configuration { 'kernel.core_pattern':
  value   => '|/scripts/core-gzip.sh /var/tmp/core/core.%e.%p.%h.%t.gz',
  comment => 'wrapper script to gzip core dumps',
}
