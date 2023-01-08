require 'spec_helper_acceptance'

describe 'install gnupg keys' do
  before :all do
    pp = "class { 'gnupg': }"
    apply_manifest(pp, :catch_failures => true)
  end

  # Technically this HTTP key redirects to HTTPS
  it 'should install a public key from a http URL address' do
    pp = <<-EOS
      gnupg_key { 'jenkins_key':
        ensure     => present,
        user       => 'root',
        key_type   => 'public',
        key_source => 'http://pkg.jenkins.io/debian/jenkins.io.key',
        key_id     => '62A9756BFD780C377CF24BA8FCEF32E745F2C3D5',
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)

    # check that gnupg installed the key
    gpg("--list-keys 62A9756BFD780C377CF24BA8FCEF32E745F2C3D5") do |r|
      expect(r.stdout).to match(/62A9756BFD780C377CF24BA8FCEF32E745F2C3D5/)
      expect(r.exit_code).to eq(0)
    end

    # clean up
    gpg("--batch --delete-key 150FDE3F7787E7D11EF4E12A9B7D32F2D50582E6") {}
  end

  it 'should install a public key from a https URL address' do
    pp = <<-EOS
      gnupg_key { 'newrelic_key':
        ensure     => present,
        user       => 'root',
        key_type   => 'public',
        key_source => 'https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg',
        key_id     => 'A758B3FBCD43BE8D123A3476BB29EE038ECCE87C',
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)

    # check that gnupg installed the key
    gpg("--list-keys A758B3FBCD43BE8D123A3476BB29EE038ECCE87C") do |r|
      expect(r.stdout).to match(/A758B3FBCD43BE8D123A3476BB29EE038ECCE87C/)
      expect(r.exit_code).to eq(0)
    end

    # clean up
    gpg("--batch --delete-key A758B3FBCD43BE8D123A3476BB29EE038ECCE87C") {}
  end

  it 'should install a public key from a key server' do
    pp = <<-EOS
      gnupg_key { 'root_key_foo':
        ensure    => present,
        user      => 'root',
        key_type   => 'public',
        key_server => 'hkp://pgp.mit.edu/',
        key_id     => '20BC0A86',
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)

    # check that gnupg installed the key
    gpg("--list-keys 20BC0A86") do |r|
      expect(r.stdout).to match(/20BC0A86/)
      expect(r.exit_code).to eq(0)
    end

    # clean up
    gpg("--batch --delete-key 58AA73E230EB06B2A2DE8A873CCE8BC520BC0A86") {}
  end


  it 'should delete a public key' do
    scp_to default, 'files/random.public.key', '/tmp/random.public.key'
    gpg("--import /tmp/random.public.key") {}

    pp = <<-EOS
      gnupg_key { 'bye_bye_key':
        ensure   => absent,
        user     => 'root',
        key_type => 'public',
        key_id   => '926FA9B9',
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)

    # check that gnupg deleted the key
    gpg("--list-keys 926FA9B9", :acceptable_exit_codes => [0, 2]) do |r|
      expect(r.stdout).to_not match(/926FA9B9/)
    end
  end

  it 'should install public key from the puppet fileserver/module repository' do
    pp = <<-EOS
      gnupg_key { 'add_key_by_remote_source':
        ensure     => present,
        user       => 'root',
        key_type   => 'public',
        key_id     => '926FA9B9',
        key_source => 'puppet:///modules/gnupg/random.public.key',
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)

    # check that gnupg installed the key
    gpg("--list-keys 926FA9B9") do |r|
      expect(r.stdout).to match(/926FA9B9/)
      expect(r.exit_code).to eq(0)
    end

    # clean up
    gpg("--batch --delete-key 7F2A6D3944CDFE31A47ECC2A60135C26926FA9B9") {}
  end

  it 'should install public key from a local file path' do
    scp_to default, 'files/random.public.key', '/tmp/random.public.key'

    pp = <<-EOS
      gnupg_key { 'add_key_by_local_file_path':
        ensure     => present,
        user       => 'root',
        key_type   => 'public',
        key_id     => '926FA9B9',
        key_source => '/tmp/random.public.key',
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)

    # check that gnupg installed the key
    gpg("--list-keys 926FA9B9") do |r|
      expect(r.stdout).to match(/926FA9B9/)
      expect(r.exit_code).to eq(0)
    end

    # clean up
    gpg("--batch --delete-key 7F2A6D3944CDFE31A47ECC2A60135C26926FA9B9") {}
  end

  it 'should install public key from a local file URL address' do
    scp_to default, 'files/random.public.key', '/tmp/random.public.key'

    pp = <<-EOS
      gnupg_key { 'add_key_by_local_file_url':
        ensure     => present,
        user       => 'root',
        key_type   => 'public',
        key_id     => '926FA9B9',
        key_source => 'file:///tmp/random.public.key',
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)

    # check that gnupg installed the key
    gpg("--list-keys 926FA9B9") do |r|
      expect(r.stdout).to match(/926FA9B9/)
      expect(r.exit_code).to eq(0)
    end

    # clean up
    gpg("--batch --delete-key 7F2A6D3944CDFE31A47ECC2A60135C26926FA9B9") {}
  end

  it 'should install public key using string key content' do
    key = File.read('files/random.public.key')

    pp = <<-EOS
      gnupg_key { 'public_key_from_string_content':
        ensure      => present,
        user        => 'root',
        key_id      => '926FA9B9',
        key_type    => 'public',
        key_content => '#{key}',
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)

    # check that gnupg installed the key
    gpg("--list-keys 926FA9B9") do |r|
      expect(r.stdout).to match(/926FA9B9/)
      expect(r.exit_code).to eq(0)
    end

    # clean up
    gpg("--batch --delete-key 7F2A6D3944CDFE31A47ECC2A60135C26926FA9B9") {}
  end


  it 'should not install public key using string because key content is invalid' do
    key = File.read('files/broken.public.key')

    pp = <<-EOS
      gnupg_key { 'public_key_from_invalid_string_content':
        ensure      => present,
        user        => 'root',
        key_id      => '926FA9B9',
        key_type    => 'public',
        key_content => '#{key}',
      }
    EOS

    apply_manifest(pp, :expect_failures => true)
  end

  it 'should not install a key, because local resource does not exists' do
    pp = <<-EOS
      gnupg_key { 'jenkins_key':
        ensure     => present,
        user       => 'root',
        key_type   => 'public',
        key_source => '/santa/claus/does/not/exists/org/sorry/kids.key',
        key_id     => '40404040',
      }
    EOS

    apply_manifest(pp, :expect_failures => true)
  end

  it 'should fail to install a public key, because there is no content at the supplied URL address' do
    pp = <<-EOS
      gnupg_key { 'jenkins_key':
        ensure     => present,
        user       => 'root',
        key_type   => 'public',
        key_source => 'http://foo.com/key-not-there.key',
        key_id     => '40404040',
      }
    EOS

    apply_manifest(pp, :expect_failures => true)
  end

  it 'should install private key from a local file path' do
    scp_to default, 'files/random.private.key', '/tmp/random.private.key'

    pp = <<-EOS
      gnupg_key { 'add_private_key_by_local_file_path':
        ensure     => present,
        user       => 'root',
        key_id     => '926FA9B9',
        key_type   => 'private',
        key_source => '/tmp/random.private.key'
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)

    # check that gnupg installed the key
    gpg("--list-secret-keys 926FA9B9") do |r|
      expect(r.stdout).to match(/926FA9B9/)
      expect(r.exit_code).to eq(0)
    end

    # clean up
    gpg("--batch --delete-secret-and-public-key 7F2A6D3944CDFE31A47ECC2A60135C26926FA9B9")
  end

  it 'should install private key from a local file URL address' do
    scp_to default, 'files/random.private.key', '/tmp/random.private.key'

    pp = <<-EOS
      gnupg_key { 'add_private_key_by_local_file_path':
        ensure     => present,
        user       => 'root',
        key_id     => '926FA9B9',
        key_type   => 'private',
        key_source => 'file:///tmp/random.private.key'
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)

    # check that gnupg installed the key
    gpg("--list-secret-keys 926FA9B9") do |r|
      expect(r.stdout).to match(/926FA9B9/)
      expect(r.exit_code).to eq(0)
    end

    # clean up
    gpg("--batch --delete-secret-and-public-key 7F2A6D3944CDFE31A47ECC2A60135C26926FA9B9")
  end

  it 'should install private key using string key content' do
    key = File.read('files/random.private.key')

    pp = <<-EOS
      gnupg_key { 'private_key_from_string_content':
        ensure      => present,
        user        => 'root',
        key_id      => '926FA9B9',
        key_type    => 'private',
        key_content => '#{key}',
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)

    # check that gnupg installed the key
    gpg("--list-secret-keys 926FA9B9") do |r|
      expect(r.stdout).to match(/926FA9B9/)
      expect(r.exit_code).to eq(0)
    end

    # clean up
    gpg("--batch --delete-secret-and-public-key 7F2A6D3944CDFE31A47ECC2A60135C26926FA9B9") {}
  end

  it 'should delete a private key' do
    # importing a private key imports the public key as well
    scp_to default, 'files/random.private.key', '/tmp/random.private.key'
    gpg("--import /tmp/random.private.key") {}

    pp = <<-EOS
      gnupg_key { 'bye_bye_key':
        ensure   => absent,
        user     => 'root',
        key_id   => '926FA9B9',
        key_type => 'private',
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)

    # check that gnupg deleted the public key
    gpg("--list-secret-keys 926FA9B9", :acceptable_exit_codes => [0, 2]) do |r|
      expect(r.stdout).to_not match(/926FA9B9/)
    end

    # check that gnupg left the public key
    gpg("--list-keys 926FA9B9") do |r|
      expect(r.stdout).to match(/926FA9B9/)
      expect(r.exit_code).to eq(0)
    end

    # clean up
    gpg("--batch --delete-key 7F2A6D3944CDFE31A47ECC2A60135C26926FA9B9")
  end

  it 'should delete both public and private key for key_id' do
    # importing a private key imports the public key as well
    scp_to default, 'files/random.private.key', '/tmp/random.private.key'
    gpg("--import /tmp/random.private.key") {}

    pp = <<-EOS
      gnupg_key { 'bye_bye_key':
        ensure   => absent,
        user     => 'root',
        key_id   => '926FA9B9',
        key_type => 'both',
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)

    # check that gnupg deleted the public key
    gpg("--list-secret-keys 926FA9B9", :acceptable_exit_codes => [0, 2]) do |r|
      expect(r.stdout).to_not match(/926FA9B9/)
    end

    # check that gnupg left the public key
    gpg("--list-keys 926FA9B9", :acceptable_exit_codes => [0, 2]) do |r|
      expect(r.stdout).to_not match(/926FA9B9/)
    end
  end
end
