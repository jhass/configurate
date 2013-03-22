require 'spec_helper'

describe Configurate::SettingPath do
  describe "::from_string" do
    it "creates a path" do
      described_class.from_string("foo.bar").should == described_class.new(["foo", "bar"])
    end
  end

  describe "#is_setter?" do
    context "with a setter signature as setting" do
      subject { described_class.new([:foo=]).is_setter? } 
      it { should be_true }
    end

    context "with a normal path as setting" do
      subject { described_class.new([:foo]).is_setter? }
      it { should be_false }
    end
  end


  describe "#is_question_or_setter?" do
    context "with a question signature as setting" do
      subject { described_class.new([:foo?]).is_question_or_setter? }
      it { should be_true }
    end

    context "with a setter signature as setting" do
      subject { described_class.new([:foo=]).is_question_or_setter? } 
      it { should be_true }
    end

    context "with a normal path as setting" do
      subject { described_class.new([:foo]).is_question_or_setter? }
      it { should be_false }
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
