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

    def initialize_copy original
      super
      @path = @path.clone
    end

    def_delegators :@path, :empty?, :length, :size, :hsh

    # Whether the current path looks like a question or setter method
    def is_question_or_setter?
      is_question? || is_setter?
    end

    # Whether the current path looks like a question method
    def is_question?
      @path.last.to_s.end_with?("?")
    end

    # Whether the current path looks like a setter method
    def is_setter?
      @path.last.to_s.end_with?("=")
    end

    def each
      return to_enum(:each) unless block_given?
      @path.each do |component|
        yield clean_special_characters(component)
      end
    end

    [:join, :first, :last, :shift, :pop].each do |method|
      define_method method do |*args|
        clean_special_characters @path.public_send(method, *args)
      end
    end

    [:<<, :unshift, :push].each do |method|
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
      "<SettingPath:#{object_id.to_s(16)} path=#{to_s}:#{@path.object_id.to_s(16)} setter=#{is_setter?} question=#{is_question?}>"
    end

    private

    def clean_special_characters value
      value.to_s.chomp("?").chomp("=")
    end
  end
end
