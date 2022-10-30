# @summary Install the package
# @api private
class gnupg::install {

  package { 'gnupg':
    ensure => $gnupg::package_ensure,
    name   => $gnupg::package_name,
  }

}
