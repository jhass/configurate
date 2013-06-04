require 'spec_helper'

describe Configurate::SettingPath do
  let(:normal_path) { described_class.new([:foo]) }
  let(:question_path) { described_class.new([:foo?]) }
  let(:setter_path) { described_class.new([:foo=]) }
  let(:long_path) { described_class.new(["foo", "bar?"]) }

  describe "#initialize" do
    context "with a string" do
      it "creates a path" do
        described_class.new(long_path.to_s).should == long_path
      end
    end
  end

  describe "#is_question?" do
    context "with a question signature as setting" do
      subject { question_path.is_question? }
      it { should be_true }
    end

    context "with a normal path as setting" do
      subject { normal_path.is_question? }
      it { should be_false }
    end
  end

  describe "#is_setter?" do
    context "with a setter signature as setting" do
      subject { setter_path.is_setter? } 
      it { should be_true }
    end

    context "with a normal path as setting" do
      subject { normal_path.is_setter? }
      it { should be_false }
    end
  end

  describe "#initialize_copy" do
    it "modifying a copy leaves the original unchanged" do
      original = described_class.new ["foo", "bar"]
      copy = original.clone
      copy << "baz"
      copy.should include "baz"
      original.should_not include "baz"
    end
  end


  describe "#is_question_or_setter?" do
    context "with a question signature as setting" do
      subject { question_path.is_question_or_setter? }
      it { should be_true }
    end

    context "with a setter signature as setting" do
      subject { setter_path.is_question_or_setter? } 
      it { should be_true }
    end

    context "with a normal path as setting" do
      subject { normal_path.is_question_or_setter? }
      it { should be_false }
    end
  end

  describe "#each" do
    it "should strip special characters" do
      long_path.all? { |c| c.include? "?" }.should be_false
    end
  end

  [:join, :first, :last, :shift, :pop].each do |method|
    describe "##{method}" do
      subject { question_path.public_send method }
      it { should_not include "?" }
    end
  end

  [:<<, :unshift, :push].each do |method|
    describe "##{method}" do
      it 'converts the argument to a string' do
        arg = mock
        arg.should_receive(:to_s).and_return('bar')
        described_class.new.public_send method, arg
      end
    end
  end

  describe "#to_s" do
    let(:path) { "example.path" }
    subject { described_class.new(path.split(".")).to_s }
    it { should == path }

    context "with a question signature as setting" do
      subject { described_class.new("#{path}?".split(".")).to_s }
      it { should == path }
    end
  end

  describe "#inspect" do
    it "includes the dotted path" do
      path = described_class.new([:foo, :bar])
      path.inspect.should include "foo.bar"
    end
  end
end
