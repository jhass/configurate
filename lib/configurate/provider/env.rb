module Configurate; module Provider
  # This provider looks for settings in the environment.
  # For the setting +foo.bar_baz+ this provider will look for an
  # environment variable +FOO_BAR_BAZ+, joining all components of the 
  # setting with underscores and upcasing the result.
  # If an value contains any commas (,) it's split at them and returned as array.
  class Env < Base
    def lookup_path(setting_path, *args)
      value = ENV[setting_path.join("_").upcase]
      unless value.nil?
        value = value.dup
        value = value.split(",") if value.include?(",")
      end
      value
    end
  end
end; end
