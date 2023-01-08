require 'spec_helper'

describe 'gnupg' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context "when enabled" do
        let(:params) {{
          :package_ensure => 'present',
          :package_name   => 'gnupg'
        }}

        it { is_expected.to contain_package('gnupg').with({
          'ensure' => 'present'})
        }
      end

      context 'when disabled' do
        let(:params) {{
          :package_ensure => 'absent',
          :package_name   => 'gnupg'
        }}

        it { is_expected.to contain_package('gnupg').with({
          'ensure' => 'absent'})
        }
      end
    end
  end
end
