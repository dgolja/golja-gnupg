# @summary Set module defaults
# @api private
class gnupg::params {
  case $facts['os']['family'] {
    'Debian': {
      $package_name ='gnupg'
    }
    'RedHat': {
      $package_name = 'gnupg2'
    }
    'Suse': {
      $package_name = 'gpg2'
    }

    'Linux': {
      if $facts['os']['name'] == 'Amazon' {
        $package_name = 'gnupg2'
      }
      else {
        fail("Osfamily ${facts['os']['family']} with operating system ${facts['os']['name']} is not supported")
      }
    }
    default: {
      fail("Osfamily ${facts['os']['family']} is not supported")
    }
  }
}
