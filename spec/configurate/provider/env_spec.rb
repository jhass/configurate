require "spec_helper"

describe Configurate::Provider::Env do
  subject { described_class.new }
  let(:existing_path) { %w(existing setting) }
  let(:not_existing_path) { %w(not existing path) }
  let(:array_path) { ["array"] }
  before(:all) do
    ENV["EXISTING_SETTING"] = "there"
    ENV["ARRAY"] = "foo,bar,baz"
  end

  after(:all) do
    ENV["EXISTING_SETTING"] = nil
    ENV["ARRAY"] = nil
  end

  describe "#lookup_path" do
    it "joins and upcases the path" do
      expect(ENV).to receive(:[]).with("EXISTING_SETTING")
      subject.lookup_path existing_path
    end

    it "returns nil if the setting isn't available" do
      expect(subject.lookup_path not_existing_path).to be_nil
    end

    it "makes an array out of comma separated values" do
      expect(subject.lookup_path array_path).to eq %w(foo bar baz)
    end

    it "returns a unfrozen string" do
      expect {
        setting = subject.lookup_path(existing_path)
        setting << "foo"
      }.to_not raise_error
    end
  end
end
