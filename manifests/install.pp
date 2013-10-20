#
class gnupg::install inherits gnupg {

  package { 'gnupg':
    ensure => $package_ensure,
    name   => $package_name,
  }

}