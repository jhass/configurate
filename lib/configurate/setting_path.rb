module Configurate
  # Class encapsulating the concept of a path to a setting
  class SettingPath < Array

    # Create a path from the string format (+foo.bar+).
    # @param path [String]
    # @return [SettingPath]
    def self.from_string(path)
      SettingPath.new(path.split("."))
    end

    # Whether the current path looks like a question or setter method
    def is_question_or_setter?
      last.to_s.end_with?("?") || is_setter?
    end

    # Whether the current path looks like a setter method
    def is_setter?
      last.to_s.end_with?("=")
    end

    def to_s
      join(".").chomp("?").chomp("=")
    end

    def inspect
      "<SettingPath path=#{to_s}>"
    end
  end
end
