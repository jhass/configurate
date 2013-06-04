require 'yaml'

module Configurate; module Provider
  # This provider tries to open a YAML file and does nested lookups
  # in it.
  class YAML < Base
    # @param file [String] the path to the file
    # @param opts [Hash]
    # @option opts [String] :namespace optionally set this as the root
    # @option opts [Boolean] :required wheter or not to raise an error if
    #   the file or the namespace, if given, is not found. Defaults to +true+.
    # @raise [ArgumentError] if the namespace isn't found in the file
    # @raise [Errno:ENOENT] if the file isn't found
    def initialize(file, opts = {})
      @settings = {}
      required = opts.delete(:required) { true }
      
      @settings = ::YAML.load_file(file)
      
      namespace = opts.delete(:namespace)
      unless namespace.nil?
        @settings = lookup_in_hash(SettingPath.new(namespace), @settings) do
          raise ArgumentError, "Namespace #{namespace} not found in #{file}" if required
          $stderr.puts "WARNING: Namespace #{namespace} not found in #{file}"
        end
      end
    rescue Errno::ENOENT => e
      $stderr.puts "WARNING: Configuration file #{file} not found, ensure it's present"
      raise e if required
    end
    
    
    def lookup_path(setting_path, *)
      lookup_in_hash(setting_path, @settings)
    end
    
    private
    
    def lookup_in_hash(setting_path, hash, &fallback)
      fallback ||= proc { nil }
      while hash.is_a?(Hash) && hash.has_key?(setting_path.first) && !setting_path.empty?
        hash = hash[setting_path.shift]
      end
      return fallback.call unless setting_path.empty?
      hash
    end
  end
end; end
