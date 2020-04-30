# frozen_string_literal: true

require "forwardable"

module Configurate
  # Class encapsulating the concept of a path to a setting
  class SettingPath
    include Enumerable
    extend Forwardable

    def initialize path=[]
      path = path.split(".") if path.is_a? String
      @path = path
    end

    def initialize_copy original
      super
      @path = @path.clone
    end

    def_delegators :@path, :empty?, :length, :size, :hsh

    # Whether the current path looks like a question or setter method
    def question_action_or_setter?
      question? || action? || setter?
    end

    # Whether the current path looks like a question method
    def question?
      @path.last.to_s.end_with?("?")
    end

    # Whether the current path looks like an action method
    def action?
      @path.last.to_s.end_with?("!")
    end

    # Whether the current path looks like a setter method
    def setter?
      @path.last.to_s.end_with?("=")
    end

    def each
      return to_enum(:each) unless block_given?

      @path.each do |component|
        yield clean_special_characters(component)
      end
    end

    %i[join first last shift pop].each do |method|
      define_method method do |*args|
        clean_special_characters @path.public_send(method, *args)
      end
    end

    %i[<< unshift push].each do |method|
      define_method method do |*args|
        @path.public_send method, *args.map(&:to_s)
      end
    end

    def to_s
      join(".")
    end

    def ==(other)
      to_s == other.to_s
    end

    def inspect
      "<SettingPath:#{object_id.to_s(16)} "\
      "path=#{self}:#{@path.object_id.to_s(16)} "\
      "question=#{question?} "\
      "action=#{action?} "\
      "setter=#{setter?}>"
    end

    private

    def clean_special_characters value
      value.to_s.chomp("?").chomp("=")
    end
  end
end
