module Configurate
  # Proxy object to support nested settings
  #
  # *Cavehats*: Since this object is always true, adding a +?+ at the end
  # returns the value, if found, instead of the proxy object.
  # So instead of +if settings.foo.bar+ use +if settings.foo.bar?+
  # to check for boolean values, +if settings.foo.bar.nil?+ to
  # check for nil values and of course you can do +if settings.foo.bar.present?+ to check for
  # empty values if you're in Rails. Call {#get} to actually return the value,
  # commonly when doing +settings.foo.bar.get || "default"+. Also don't
  # use this in case statements since +Module#===+ can't be fooled, again
  # call {#get}.
  #
  # If a setting ends with +=+ it's too called directly, just like with +?+.
  class Proxy < BasicObject
    # @param lookup_chain [#lookup]
    def initialize lookup_chain
      @lookup_chain = lookup_chain
      @setting_path = SettingPath.new
    end
    
    def !
      !target
    end
    
    [:!=, :==, :eql?].each do |method|
      define_method method do |other|
        target.public_send method, target_or_object(other)
      end
    end
    
    def _proxy?
      true
    end
    
    def respond_to? method, include_private=false
      method == :_proxy? || target_respond_to?(method, include_private)
    end
    
    def send *args, &block
      __send__(*args, &block)
    end
    alias_method :public_send, :send
    
    def method_missing setting, *args, &block
      return target.public_send(setting, *args, &block) if target_respond_to? setting

      @setting_path << setting
      
      return target(*args) if @setting_path.is_question_or_setter?
      
      self
    end
    
    # Get the setting at the current path, if found.
    # (see LookupChain#lookup)
    def target *args
      return if @setting_path.empty?

      @lookup_chain.lookup @setting_path, *args
    end
    alias_method :get, :target
    
    private
    COMMON_KEY_NAMES = [:key, :method]

    def target_respond_to? setting, include_private=false
      return false if COMMON_KEY_NAMES.include? setting

      value = target
      return false if proxy? value

      value.respond_to? setting, include_private
    end

    def proxy? obj
      obj.respond_to?(:_proxy?) && obj._proxy?
    end

    def target_or_object obj
      proxy?(obj) ? obj.target : obj
    end
  end
end
