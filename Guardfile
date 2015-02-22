guard :rspec, cmd: "bundle exec rspec" do
  watch(/^spec\/.+_spec\.rb$/)
  watch(/^lib\/(.+)\.rb$/) {|m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/open_graph_reader/(.+)\.rb$}) {|m| "spec/#{m[1]}_spec.rb" }
  watch(/^lib\/(.+)\.rb$/) { "spec/integration" }
  watch("spec/spec_helper.rb") { "spec" }
end

guard "yard" do
  watch(/lib\/.+\.rb/)
end

guard "Rubocop" do
  watch(/(?:lib|spec)\/.+\.rb/)
end
