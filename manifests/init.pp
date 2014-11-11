# Manages a set of sysctl values from Hiera config (sysctl::base::values)
class sysctl {

  create_resources(sysctl::variable, hiera_hash('sysctl::base::values'))

}

