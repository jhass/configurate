require 'forwardable'

require 'configurate/setting_path'
require 'configurate/lookup_chain'
require 'configurate/provider'
require 'configurate/proxy'


# A flexible and extendable configuration system.
# The calling logic is isolated from the lookup logic
# through configuration providers, whose only requirement
# is to define the +#lookup+ method and show a certain behavior on that.
# The providers are asked in the order they were added until one provides
# a response. This allows to even add multiple providers of the same type,
# you never easier defined your default configuration parameters.
# There is no shared state, you can have an unlimited amount of
# independent configuration sources at the same time.
#
# See {Settings} for a quick start.
module Configurate
  # This is your main entry point. Instead of lengthy explanations
  # let an example demonstrate its usage:
  # 
  #     require 'configuration_methods'
  #     
  #     AppSettings = Configurate::Settings.create do
  #       add_provider Configurate::Provider::Env
  #       add_provider Configurate::Provider::YAML, '/etc/app_settings.yml',
  #                    namespace: Rails.env, required: false
  #       add_provider Configurate::Provider::YAML, 'config/default_settings.yml'
  #       
  #       extend YourConfigurationMethods
  #     end
  #
  #     AppSettings.setup_something if AppSettings.something.enable?
  #
  # Please also read the note at {Proxy}!
  class Settings
  
    attr_reader :lookup_chain
    
    undef_method :method # Remove possible conflicts with common setting names

    extend Forwardable

    def initialize
      @lookup_chain = LookupChain.new
      $stderr.puts "Warning you called Configurate::Settings.new with a block, you really meant to call #create" if block_given?
    end
    
    # @!method lookup(setting)
    # (see {LookupChain#lookup})

    # @!method add_provider(provider, *args)
    # (see {LookupChain#add_provider})

    # @!method [](setting)
    # (see {LookupChain#[]})

    def_delegators :@lookup_chain, :lookup, :add_provider, :[]

    # See description and {#lookup}, {#[]} and {#add_provider}
    def method_missing(method, *args, &block)
      Proxy.new(@lookup_chain).public_send(method, *args, &block)
    end
    
    # Create a new configuration object
    # @yield the given block will be evaluated in the context of the new object
    def self.create(&block)
      config = self.new
      config.instance_eval(&block) if block_given?
      config
    end
  end
  
  class SettingNotFoundError < RuntimeError; end
end
