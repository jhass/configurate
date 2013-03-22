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
        namespace = SettingPath.from_string(namespace)
        actual_settings = lookup_in_hash(namespace, @settings)
        if !actual_settings.nil?
          @settings = actual_settings
        elsif required
          raise ArgumentError, "Namespace #{namespace} not found in #{file}"
        else
          $stderr.puts "WARNING: Namespace #{namespace} not found in #{file}"
        end
      end
    rescue Errno::ENOENT => e
      $stderr.puts "WARNING: Configuration file #{file} not found, ensure it's present"
      raise e if required
    end
    
    
    def lookup_path(setting_path, *args)
      lookup_in_hash(setting_path, @settings)
    end
    
    private
    
    def lookup_in_hash(setting_path, hash)
      setting = setting_path.shift
      if hash.has_key?(setting)
        if setting_path.length > 0 && hash[setting].is_a?(Hash)
          return lookup_in_hash(setting_path, hash[setting]) if setting.length >= 1
        else
          return hash[setting]
        end
      end
    end
  end
end; end
