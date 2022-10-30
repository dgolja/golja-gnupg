# @summary Set module defaults
# @api private
class gnupg::params {
  case $::osfamily {
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
      if $::operatingsystem == 'Amazon' {
        $package_name = 'gnupg2'
      }
      else {
        fail("Osfamily ${::osfamily} with operating system ${::operatingsystem} is not supported")
      }
    }
    default: {
      fail("Osfamily ${::osfamily} is not supported")
    }
  }
}
