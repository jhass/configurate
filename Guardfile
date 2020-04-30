# frozen_string_literal: true

guard :rspec, cmd: "bundle exec rspec" do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) {|m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/configurate/(.+)\.rb$}) {|m| "spec/#{m[1]}_spec.rb" }
  watch("spec/spec_helper.rb") { "spec" }
end

guard "yard" do
  watch(%r{lib/.+\.rb})
end

guard "Rubocop" do
  watch(%{(?:lib|spec)/.+\.rb})
end
