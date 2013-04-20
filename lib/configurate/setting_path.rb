require 'forwardable'

module Configurate
  # Class encapsulating the concept of a path to a setting
  class SettingPath
    include Enumerable
    extend Forwardable

    def initialize path=[]
      path = path.split(".") if path.is_a? String
      @path = path
    end

    def_delegators :@path, :empty?, :last, :join, :length, :size, :hsh

    # Whether the current path looks like a question or setter method
    def is_question_or_setter?
      is_question? || is_setter?
    end

    # Whether the current path looks like a question method
    def is_question?
      last.to_s.end_with?("?")
    end

    # Whether the current path looks like a setter method
    def is_setter?
      last.to_s.end_with?("=")
    end

    def each
      return to_enum(:each) unless block_given?
      @path.each do |component|
        yield clean_special_characters(component)
      end
    end

    def <<(component)
      @path << component.to_s
    end

    def to_s
      clean_special_characters join(".")
    end

    def shift
      clean_special_characters @path.shift
    end

    def pop
      clean_special_characters @path.pop
    end

    def dup
      SettingPath.new(@path.dup)
    end

    def ==(other)
      to_s == other.to_s
    end

    def inspect
      "<SettingPath:#{object_id.to_s(16)} path=#{to_s}:#{@path.object_id.to_s(16)} setter=#{is_setter?} question=#{is_question?}>"
    end

    private

    def clean_special_characters(value)
      value.to_s.chomp("?").chomp("=")
    end
  end
end
