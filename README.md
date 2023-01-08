# GnuPG puppet module

#### Table of Contents

1. [Overview](##overview)
2. [Installation](##Installation)
3. [Usage - Configuration options and additional functionality](##usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](##reference)
5. [Limitations - OS compatibility, etc.](##limitations)
6. [Development - Guide for contributing to the module](##development)
7. [License](##license)

## Overview

Install GnuPG on Ubuntu/Debian/RedHat/CentOS/Amazon AMI and manage users public keys.

[![Puppet Forge](http://img.shields.io/puppetforge/v/golja/gnupg.svg)](https://forge.puppetlabs.com/golja/gnupg)

## Installation

```console
$ puppet module install golja/gnupg
```

## Usage

#### Install GnuPG package

```puppet
include gnupg
```

#### Add public key 20BC0A86 from PGP server from hkp://pgp.mit.edu/ to user root

```puppet
gnupg_key { 'hkp_server_20BC0A86':
  ensure     => present,
  key_id     => '20BC0A86',
  user       => 'root',
  key_server => 'hkp://pgp.mit.edu/',
  key_type   => public,
}
```

#### Add public key D50582E6 from standard http URI to user foo

```puppet
gnupg_key { 'jenkins_foo_key':
  ensure     => present,
  key_id     => 'D50582E6',
  user       => 'foo',
  key_source => 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key',
  key_type   => public,
}
```

#### Add public key D50582E6 from puppet fileserver to user foo

```puppet
gnupg_key { 'jenkins_foo_key':
  ensure     => present,
  key_id     => 'D50582E6',
  user       => 'foo',
  key_source => 'puppet:///modules/gnupg/D50582E6.key',
  key_type   => public,
}
```

#### Add public key D50582E6 from puppet fileserver to user bar via a string value

```puppet
gnupg_key { 'jenkins_foo_key':
  ensure      => present,
  key_id      => 'D50582E6',
  user        => 'bar',
  key_content => '-----BEGIN BROKEN PUBLIC KEY BLOCK-----...',
  key_type    => public,
}
```
*Note*: You should use hiera lookup to get the key content

#### Remove public key 20BC0A86 from user root

```puppet
gnupg_key {'root_remove':
  ensure   => absent,
  key_id   => '20BC0A86',
  user     => 'root',
  key_type => public,
}
```

### Remove both private and public key 20BC0A66

```puppet
gnupg_key {'root_remove':
  ensure   => absent,
  key_id   => '20BC0A66',
  user     => 'root',
  key_type => both,
}
```

### Reference

Please see `REFERENCE.md`.

### Tests

There are two types of tests distributed with the module. Unit tests with rspec-puppet and acceptance tests using Beaker.

For unit testing, make sure you have Ruby and bundler installed. Then install the necessary gems:

```bash
bundle install --path=vendor
```

And then run the unit tests:

```bash
bundle exec rake spec
```

To run the acceptance tests, for example on CentOS Stream 9:

```bash
BEAKER_setfile=centos9-64 bundle exec rake acceptance
```

See [voxpupuli-test](https://github.com/voxpupuli/voxpupuli-test#readme) and [voxpupuli-acceptance](https://github.com/voxpupuli/voxpupuli-acceptance#readme) for more details.

## Limitations

Please see `metadata.json` for OS and Puppet compatibility.

## Development

Please see `CONTRIBUTING.md`.

## License

See `LICENSE` file.
