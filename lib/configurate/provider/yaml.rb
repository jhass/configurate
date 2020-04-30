# frozen_string_literal: true

require "yaml"

module Configurate
  module Provider
    # This provider tries to open a YAML file and does nested lookups
    # in it.
    class YAML < StringHash
      # @param file [String] the path to the file
      # @param namespace [String] optionally set this as the root
      # @param required [Boolean] whether or not to raise an error if
      #   the file or the namespace, if given, is not found. Defaults to +true+.
      # @param raise_on_missing [Boolean]  whether to raise {Configurate::MissingSetting}
      #   if a setting can't be provided. Defaults to +false+.
      # @raise [ArgumentError] if the namespace isn't found in the file
      # @raise [Errno:ENOENT] if the file isn't found
      def initialize file, namespace: nil, required: true, raise_on_missing: false
        super(::YAML.load_file(file),
          namespace:        namespace,
          required:         required,
          raise_on_missing: raise_on_missing,
          source:           file
        )
      rescue Errno::ENOENT => e
        warn "WARNING: Configuration file #{file} not found, ensure it's present"
        raise e if required
      end
    end
  end
end
