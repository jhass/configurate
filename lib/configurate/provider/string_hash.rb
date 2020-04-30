# frozen_string_literal: true

module Configurate
  module Provider
    # This provider takes a nested string keyed hash and does nested lookups in it.
    class StringHash < Base
      # @param hash [::Hash] the string keyed hash to provide values from
      # @param namespace [String] optionally set this as the root
      # @param required [Boolean] whether or not to raise an error if
      #   the namespace, if given, is not found. Defaults to +true+.
      # @param raise_on_missing [Boolean]  whether to raise {Configurate::MissingSetting}
      #   if a setting can't be provided. Defaults to +false+.
      # @param source [String] optional hint of what's the source of this configuration. Used in error messages.
      # @raise [ArgumentError] if the namespace isn't found in the hash or the given object is not a hash
      def initialize hash, namespace: nil, required: true, raise_on_missing: false, source: nil
        raise ArgumentError, "Please provide a hash" unless hash.is_a?(Hash)

        @required = required
        @raise_on_missing = raise_on_missing
        @source = source
        @settings = root_from hash, namespace
      end

      def lookup_path setting_path, *_
        Provider.lookup_in_hash(setting_path, @settings) {
          raise MissingSetting.new "#{setting_path} is not a valid setting." if @raise_on_missing

          nil
        }
      end

      private

      def root_from hash, namespace
        return hash if namespace.nil?

        Provider.lookup_in_hash(SettingPath.new(namespace), hash) do
          raise ArgumentError, "Namespace #{namespace} not found #{"in #{@source}" if @source}" if @required

          warn "WARNING: Namespace #{namespace} not found #{"in #{@source}" if @source}"
          nil
        end
      end
    end
  end
end
