source "https://rubygems.org"

gem "coveralls", require: false, group: :coverage

group :development do
  gem "guard-rspec"
  gem "guard-yard"
  gem "guard-rubocop"
  gem "rubocop", require: false
end

group :doc do
  gem "yard", require: false
  gem "redcarpet", require: false
end

platform :rbx do
  gem "psych"
  gem "rubysl-singleton"
end

gemspec
