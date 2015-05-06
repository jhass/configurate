module Configurate
  module Provider
    # This provider knows nothing upon initialization, however if you access
    # a setting ending with +=+ and give one argument to that call it remembers
    # that setting, stripping the +=+ and will return it on the next call
    # without +=+. Sending +reset_dynamic!+ to it will make it forget all
    # settings. Also assigning nil will have the effect of it forgetting
    # a setting.
    class Dynamic < Base
      def lookup_path(setting_path, *args)
        if setting_path.to_s == "reset_dynamic!"
          @settings = nil
          return true
        end

        if setting_path.setter? && args.length > 0
          *root, key = setting_path.to_a
          hash = root.inject(settings) {|hash, key| hash[key] }
          hash[key] = extract_value(args)
        end

        Provider.lookup_in_hash setting_path, settings
      end

      private

      def settings
        @settings ||= Hash.new {|hash, key| hash[key] = Hash.new(&hash.default_proc) }
      end

      def extract_value args
        value = args.first
        value = value.get if value.respond_to?(:_proxy?) && value._proxy?
        value
      end
    end
  end
end
