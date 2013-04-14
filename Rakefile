require "bundler/gem_tasks"

class Bundler::GemHelper
  def build_gem
    file_name = nil
    sh("gem build -V '#{spec_path}' --sign") { |out, code|
      file_name = File.basename(built_gem_path)
      FileUtils.mkdir_p(File.join(base, 'pkg'))
      FileUtils.mv(built_gem_path, 'pkg')
      Bundler.ui.confirm "#{name} #{version} built to pkg/#{file_name}."
    }
    File.join(base, 'pkg', file_name)
  end
end

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:rspec)

task default: :rspec
