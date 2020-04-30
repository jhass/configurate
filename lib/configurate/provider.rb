# frozen_string_literal: true

module Configurate
  module Provider
    # This provides a basic {#lookup} method for other providers to build
    # upon. Childs are expected to define +lookup_path(path, *args)+.
    # The method should return nil if the setting
    # wasn't found and {#lookup} will raise an {SettingNotFoundError} in that
    # case.
    class Base
      def lookup(*args)
        result = lookup_path(*args)
        return result unless result.nil?

        raise Configurate::SettingNotFoundError, "The setting #{args.first} was not found"
      end
    end

    # Utility function to lookup a settings path in a hash
    # @param setting_path [SettingPath]
    # @param hash [Hash]
    # @yield fallback value if not found
    # @return [Object]
    def self.lookup_in_hash setting_path, hash, &fallback
      fallback ||= proc { nil }
      while hash.is_a?(Hash) && hash.has_key?(setting_path.first) && !setting_path.empty?
        hash = hash[setting_path.shift]
      end
      return fallback.call unless setting_path.empty?

      hash
    end
  end
end

require "configurate/provider/string_hash"
require "configurate/provider/yaml"
require "configurate/provider/env"
require "configurate/provider/dynamic"
