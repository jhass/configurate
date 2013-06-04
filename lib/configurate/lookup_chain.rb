module Configurate
  # This object builds a chain of configuration providers to try to find
  # the value of a setting.
  class LookupChain
    def initialize
      @provider = []
    end
    
    # Adds a provider to the chain. Providers are tried in the order
    # they are added, so the order is important.
    #
    # @param provider [#lookup]
    # @param *args the arguments passed to the providers constructor
    # @raise [ArgumentError] if an invalid provider is given
    # @return [void]
    def add_provider(provider, *args)
      unless provider.respond_to?(:instance_methods) && provider.instance_methods.include?(:lookup)
        raise ArgumentError, "the given provider does not respond to lookup"
      end
      
      @provider << provider.new(*args)
    end
    
    
    # Tries all providers in the order they were added to provide a response
    # for setting.
    #
    # @param setting [SettingPath,String] nested settings as strings should
    #   be separated by a dot
    # @param ... further args passed to the provider
    # @return [Array,Hash,String,Boolean,nil] whatever the responding
    #   provider provides is casted to a {String}, except for some special values
    def lookup(setting, *args)
      setting = SettingPath.new setting if setting.is_a? String
      @provider.each do |provider|
        begin
          return special_value_or_string(provider.lookup(setting.clone, *args))
        rescue SettingNotFoundError; end
      end
      
      nil
    end
    alias_method :[], :lookup
    
    private 
    
    def special_value_or_string(value)
      if [TrueClass, FalseClass, NilClass, Array, Hash].include?(value.class)
        return value
      elsif value.is_a?(String)
        return case value.strip
          when "true" then true
          when "false" then false
          when "", "nil" then nil
          else value
        end
      elsif value.respond_to?(:to_s)
        return value.to_s
      else
        return value
      end
    end
  end
end
