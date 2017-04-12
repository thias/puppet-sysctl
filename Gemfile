source ENV['GEM_SOURCE'] || 'https://rubygems.org'

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

gem 'facter', '>= 1.7.0'
gem 'puppet-lint', '~> 2.0'
gem 'puppet-lint-absolute_classname-check'
gem 'puppet-lint-alias-check'
gem 'puppet-lint-empty_string-check'
gem 'puppet-lint-file_ensure-check'
gem 'puppet-lint-file_source_rights-check'
gem 'puppet-lint-leading_zero-check'
gem 'puppet-lint-spaceship_operator_without_tag-check'
gem 'puppet-lint-trailing_comma-check'
gem 'puppet-lint-undef_in_function-check'
gem 'puppet-lint-unquoted_string-check'
gem 'puppet-lint-variable_contains_upcase'
gem 'rspec-puppet'

gem 'json', '<= 1.8', :require => false                     if RUBY_VERSION < '2.0.0'
gem 'json_pure', '<= 2.0.1', :require => false              if RUBY_VERSION < '2.0.0'
gem 'metadata-json-lint', '0.0.11', :require => false       if RUBY_VERSION < '1.9'
gem 'metadata-json-lint'                                    if RUBY_VERSION >= '1.9'
gem 'parallel_tests', '<= 2.9.0', :require => false         if RUBY_VERSION < '2.0.0' # [1]
gem 'puppetlabs_spec_helper', '2.0.2', :require => false    if RUBY_VERSION >= '1.8.7' && RUBY_VERSION < '1.9' # [1]
gem 'puppetlabs_spec_helper', '>= 2.0.0', :require => false if RUBY_VERSION >= '1.9' # [1]
gem 'rake', '~> 10.0', :require => false                    if RUBY_VERSION >= '1.8.7' && RUBY_VERSION < '1.9'
gem 'rspec', '~> 2.0', :require => false                    if RUBY_VERSION >= '1.8.7' && RUBY_VERSION < '1.9'
gem 'rubocop', :require => false                            if RUBY_VERSION >= '2.0.0'

# [1]: Puppetlabs is dropping support for Ruby 1.8.7 in latests releases, pin to last supported version when running on Ruby 1.8.7
