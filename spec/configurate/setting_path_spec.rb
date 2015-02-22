require "spec_helper"

describe Configurate::SettingPath do
  let(:normal_path) { described_class.new([:foo]) }
  let(:question_path) { described_class.new([:foo?]) }
  let(:action_path) { described_class.new([:foo!]) }
  let(:setter_path) { described_class.new([:foo=]) }
  let(:long_path) { described_class.new(["foo", "bar?"]) }

  describe "#initialize" do
    context "with a string" do
      it "creates a path" do
        expect(described_class.new long_path.to_s).to eq long_path
      end
    end
  end

  describe "#question?" do
    context "with a question signature as setting" do
      subject { question_path.question? }
      it { should be_truthy }
    end

    context "with a normal path as setting" do
      subject { normal_path.question? }
      it { should be_falsey }
    end
  end

  describe "#action?" do
    context "with a action signature as setting" do
      subject { action_path.action? }
      it { should be_truthy }
    end

    context "with a normal path as setting" do
      subject { normal_path.action? }
      it { should be_falsey }
    end
  end

  describe "#setter?" do
    context "with a setter signature as setting" do
      subject { setter_path.setter? }
      it { should be_truthy }
    end

    context "with a normal path as setting" do
      subject { normal_path.setter? }
      it { should be_falsey }
    end
  end

  describe "#initialize_copy" do
    it "modifying a copy leaves the original unchanged" do
      original = described_class.new %w(foo bar)
      copy = original.clone
      copy << "baz"
      expect(copy).to include "baz"
      expect(original).not_to include "baz"
    end
  end

  describe "#question_action_or_setter?" do
    context "with a question signature as setting" do
      subject { question_path.question_action_or_setter? }
      it { should be_truthy }
    end

    context "with an action signature as setting" do
      subject { action_path.question_action_or_setter? }
      it { should be_truthy }
    end

    context "with a setter signature as setting" do
      subject { setter_path.question_action_or_setter? }
      it { should be_truthy }
    end

    context "with a normal path as setting" do
      subject { normal_path.question_action_or_setter? }
      it { should be_falsey }
    end
  end

  describe "#each" do
    it "should strip special characters" do
      expect(long_path.all? {|c| c.include? "?" }).to be_falsey
    end
  end

  %i(join first last shift pop).each do |method|
    describe "##{method}" do
      subject { question_path.public_send method }
      it { should_not include "?" }
    end
  end

  %i(<< unshift push).each do |method|
    describe "##{method}" do
      it "converts the argument to a string" do
        arg = double
        expect(arg).to receive(:to_s).and_return("bar")
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
      path = described_class.new(%i(foo bar))
      expect(path.inspect).to include "foo.bar"
    end
  end
end
