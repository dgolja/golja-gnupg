# @summary Manage gnupg and public key entries
#
# @param package_ensure
#   Remove or install the gnupg package. Possible values
#   present or absent, however most of modern Linux distros rely on
#   gnupg so you shouldn't remove the package
#
# @param package_name
#   name of the package usually gnupg/gnupg2 depends of the distro
#
# @example Basic installation
#   include gnupg
#
# @author Dejan Golja <dejan@golja.org>
#
class gnupg (
  String[1] $package_ensure = 'present',
  String[1] $package_name = $gnupg::params::package_name,
) inherits gnupg::params {
  package { 'gnupg':
    ensure => $package_ensure,
    name   => $package_name,
  }
}
