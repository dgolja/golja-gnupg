source ENV['GEM_SOURCE'] || 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_GEM_VERSION') ? ENV['PUPPET_GEM_VERSION'] : ['>= 3.8.7']
gem 'puppet', puppetversion
gem 'puppetlabs_spec_helper', '>= 1.2.0'
gem 'puppet-lint', '>= 1.0.0'
gem 'facter', '>= 1.7.0'
gem 'rspec-puppet'

# rspec must be v2 for ruby 1.8.7
if RUBY_VERSION >= '1.8.7' && RUBY_VERSION < '1.9'
  gem 'rspec', '~> 2.0'
  gem 'rake', '~> 10.0'
elsif RUBY_VERSION >= '1.9.3' && RUBY_VERSION < '2.0'
  gem 'public_suffix', '~> 1.4.6'
  # rubocop requires ruby >= 2.0 as of 0.42
  gem 'rubocop', '~> 0.41'
elsif RUBY_VERSION >= '2.0'
  # metadata-json-lint requires >= 2.0
  gem 'metadata-json-lint'
  # rubocop requires ruby >= 1.9
  gem 'rubocop'
else
  gem 'rubocop'
end

unless puppetversion >= '5.0'
  gem 'semantic_puppet'
end
