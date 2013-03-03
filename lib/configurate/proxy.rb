module Configurate
  # Proxy object to support nested settings
  # Cavehat: Since this is always true, adding a ? at the end
  # returns the value, if found, instead of the proxy object.
  # So instead of +if settings.foo.bar+ use +if settings.foo.bar?+
  # to check for boolean values, +if settings.foo.bar.nil?+ to
  # check for nil values, +if settings.foo.bar.present?+ to check for
  # empty values if you're in Rails and call {#get} to actually return the value,
  # commonly when doing +settings.foo.bar.get || 'default'+. If a setting
  # ends with +=+ it's too called directly, just like with +?+.
  class Proxy < BasicObject
    # @param lookup_chain [#lookup]
    def initialize(lookup_chain)
      @lookup_chain = lookup_chain
      @setting_path = SettingPath.new
    end
    
    def !
      !self.target
    end
    
    def !=(other)
      self.target != other
    end
    
    def ==(other)
      self.target == other
    end
    
    def _proxy?
      true
    end
    
    def respond_to?(method, include_private=false)
      method == :_proxy? || self.target.respond_to?(method, include_private)
    end
    
    def send(*args, &block)
      self.__send__(*args, &block)
    end
    alias_method :public_send, :send
    
    def method_missing(setting, *args, &block)
      return target.public_send(setting, *args, &block) if target_respond_to? setting

      @setting_path << setting
      
      return self.target(*args) if @setting_path.is_question_or_setter?
      
      self
    end
    
    # Get the setting at the current path, if found.
    # (see LookupChain#lookup)
    def target(*args)
      return if @setting_path.empty?

      @lookup_chain.lookup(@setting_path, *args)
    end
    alias_method :get, :target
    
    private
    COMMON_KEY_NAMES = [:key, :method]

    def target_respond_to?(setting)   
      return false if COMMON_KEY_NAMES.include? setting

      value = target
      return false if value.respond_to?(:_proxy?) && value._proxy?

      value.respond_to?(setting)
    end
  end
end
