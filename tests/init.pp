sysctl { 'net.ipv4.ip_forward': value => '1' }
sysctl { 'net.core.somaxconn': value => '65536' }
sysctl { 'vm.swappiness': ensure => absent }
sysctl { 'net.ipv4.conf.eth0/1.forwarding': value => 1 }
