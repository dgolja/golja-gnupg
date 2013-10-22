#GnuPG puppet module

##Overview

Install GnuPG on Ubuntu/Debian/RedHat/CentOS/Amazon AMI and manage users public keys.

##Installation

     $ puppet module install golja/gnupg

##Usage

####Install GnuPG package

    include gnupg

####Add public key 20BC0A86 from PGP server from hkp://pgp.mit.edu/ to user root

    gnupg_key { 'hkp_server_20BC0A86':
      ensure     => present,
      key_id     => '20BC0A86',
      user       => 'root',
      key_server => 'hkp://pgp.mit.edu/',
    }

####Add public key D50582E6 from standard http URI to user foo

    gnupg_key { 'jenkins_foo_key':
      ensure     => present,
      key_id     => 'D50582E6',
      user       => 'foo',
      key_source => 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key',
    }

####Add public key D50582E6 from puppet fileserver to user foo

    gnupg_key { 'jenkins_foo_key':
      ensure     => present,
      key_id     => 'D50582E6',
      user       => 'foo',
      key_source => '"puppet:///modules/gnupg/D50582E6.key",',
    }

####Remove public key 20BC0A86 from user root

    gnupg_key {'root_remove':
      ensure => absent,
      key_id => 20BC0A86,
      user   => root,
    }
    

###Attributes

####gnupg

#####`package_ensure`

Valid value present/absent. Default: present

#####`package_name`

Name of the GnuPG package. Default value determined by $::osfamily/$::operatingsystem facts

####gnupg_key

#####`ensure`

**REQUIRED** - Valid value present/absent

#####`user`

**REQUIRED** - System username for who to store the public key. Also define the location of the 
pubring (default ${HOME}/.gnupg/)

#####`key_id`

**REQUIRED** - Key ID. Usually the traditional 8-character key ID. Also accepted the
long more accurate (but  less  convenient) 16-character key ID. Accept only hexadecimal
values.

#####`key_source`

**REQUIRED** if `key_server` is not defined and `ensure` is present.
A source file containing PGP key. Values can be URIs pointing to remote files,
or fully qualified paths to files available on the local system.

The available URI schemes are *puppet*, *https*, *http* and *file*. *Puppet*
URIs will retrieve files from Puppet's built-in file server, and are
usually formatted as:

puppet:///modules/name_of_module/filename

#####`key_server`

**REQUIRED** if `key_source` is not defined and `ensure` is present.

PGP key server from where to retrieve the public key. Valid URI schemes are
*http*, *https*, *ldap* and *hkp*.

## Supported Platforms

* Debian Wheezy
* Ubuntu 12+
* RedHat 5/6
* CentOS 5/6
* Amazon AMI

## License

See LICENSE file

