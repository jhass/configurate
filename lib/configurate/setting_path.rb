module Configurate
  class SettingPath < Array
    def is_question_or_setter?
      last.to_s.end_with?("?") || last.to_s.end_with?("=")
    end

    def to_s
      join(".").chomp("?")
    end

    def inspect
      "<SettingPath path=#{to_s}>"
    end
  end
end
