#
class gnupg::install {

  ensure_packages(['gnupg'], { ensure => $gnupg::package_ensure })

}
