require "yaml"

module Configurate
  module Provider
    # This provider tries to open a YAML file and does nested lookups
    # in it.
    class YAML < Base
      # @param file [String] the path to the file
      # @param namespace [String] optionally set this as the root
      # @param required [Boolean] whether or not to raise an error if
      #   the file or the namespace, if given, is not found. Defaults to +true+.
      # @param raise_on_missing [Boolean]  whether to raise {Configurate::MissingSetting}
      #   if a setting can't be provided. Defaults to +false+.
      # @raise [ArgumentError] if the namespace isn't found in the file
      # @raise [Errno:ENOENT] if the file isn't found
      def initialize file, namespace: nil, required: true, raise_on_missing: false
        @raise_on_missing = raise_on_missing
        @settings = {}

        @settings = ::YAML.load_file(file)

        unless namespace.nil?
          @settings = Provider.lookup_in_hash(SettingPath.new(namespace), @settings) do
            raise ArgumentError, "Namespace #{namespace} not found in #{file}" if required
            $stderr.puts "WARNING: Namespace #{namespace} not found in #{file}"
            nil
          end
        end
      rescue Errno::ENOENT => e
        warn "WARNING: Configuration file #{file} not found, ensure it's present"
        raise e if required
      end

      def lookup_path setting_path, *_
        Provider.lookup_in_hash(setting_path, @settings) {
          raise MissingSetting.new "#{setting_path} is not a valid setting." if @raise_on_missing
          nil
        }
      end
    end
  end
end
