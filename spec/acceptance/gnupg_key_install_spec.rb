require 'spec_helper_acceptance'

describe 'install gnupg keys' do
  before :all do
    pp = "class { 'gnupg': }"
    apply_manifest(pp, :catch_failures => true)
  end

  it 'should install a key from a http URL address' do
    pp = <<-EOS
      gnupg_key { 'jenkins_key':
        ensure     => present,
        user       => 'root',
        key_source => 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key',
        key_id     => 'D50582E6', 
      }
    EOS
  
    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)

    # check that gnupg installed the key
    gpg("--list-keys D50582E6") do |r|
      expect(r.stdout).to match(/D50582E6/)
      expect(r.exit_code).to eq(0)
    end
  end

  it 'should install a key from a https URL address' do
    pp = <<-EOS
      gnupg_key { 'newrelic_key':
        ensure     => present,
        user       => 'root',
        key_source => 'https://download.newrelic.com/548C16BF.gpg',
        key_id     => '548C16BF',
      }
    EOS
  
    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)

    # check that gnupg installed the key
    gpg("--list-keys D50582E6") do |r|
      expect(r.stdout).to match(/D50582E6/)
      expect(r.exit_code).to eq(0)
    end
  end

 it 'should install a key from a key server' do
    pp = <<-EOS
      gnupg_key { 'root_key_foo':
        ensure    => present,
        user      => 'root',
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
  end


  it 'should remove key 20BC0A86' do
    pp = <<-EOS
      gnupg_key { 'bye_bye_key':
        ensure => absent,
        key_id => 20BC0A86,
        user   => root,
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)
  end

  it 'should install key from the puppet fileserver/module repository' do
    pp = <<-EOS
      gnupg_key {'add_key_by_remote_source':
        ensure     => present,
        key_id     => 20BC0A86,
        user       => root,
        key_source => "puppet:///modules/gnupg/random.key",
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)

    # check that gnupg installed the key
    gpg("--list-keys 20BC0A86") do |r|
      expect(r.stdout).to match(/20BC0A86/)
      expect(r.exit_code).to eq(0)

    end
  end

  it 'should not install a key, because local resource does not exists' do
    pp = <<-EOS
      gnupg_key { 'jenkins_key':
        ensure     => present,
        user       => 'root',
        key_source => '/santa/claus/does/not/exists/org/sorry/kids.key',
        key_id     => '40404040',
      }
    EOS

    apply_manifest(pp, :expect_failures => true)
  end

  it 'should fail because there is no content on the URL address' do
    pp = <<-EOS
      gnupg_key { 'jenkins_key':
        ensure     => present,
        user       => 'root',
        key_source => 'http://foo.com/key-not-there.key',
        key_id     => '40404040',
      }
    EOS

    apply_manifest(pp, :expect_failures => true)
  end

end