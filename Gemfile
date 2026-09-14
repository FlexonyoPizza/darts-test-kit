source "https://rubygems.org"

gemspec

# TODO: remove this gemfile pin after
# migrating the DAPL Test Kit to an official ONC repository and releasing
# a gem for it
gem 'dapl_test_kit', git: 'https://github.com/FlexonyoPizza/dapl-test-kit.git', branch: 'main'

group :development, :test do
  gem 'debug'
  gem 'rubocop', '~> 1.9'
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'database_cleaner-sequel', '~> 1.8'
  gem 'factory_bot', '~> 6.1'
  gem 'rack-test'
  gem 'rspec', '~> 3.10'
  gem 'simplecov', '0.21.2', require: false
  gem 'webmock', '~> 3.11'
end