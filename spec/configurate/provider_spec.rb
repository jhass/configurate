# frozen_string_literal: true

require "spec_helper"

describe Configurate::Provider::Base do
  describe "#lookup" do
    subject { described_class.new }
    it "calls #lookup_path" do
      path = Configurate::SettingPath.new(%w[foo bar])
      expect(subject).to receive(:lookup_path).with(path).and_return("something")
      expect(subject.lookup(path)).to eq "something"
    end

    it "raises SettingNotFoundError if the #lookup_path returns nil" do
      allow(subject).to receive(:lookup_path).and_return(nil)
      expect {
        subject.lookup("bla")
      }.to raise_error Configurate::SettingNotFoundError
    end
  end

  describe "::lookup_in_hash" do
    let(:hash) { {foo: {bar: nil}} }
    it "returns nil if key is nil" do
      expect(Configurate::Provider.lookup_in_hash(%i[foo bar], hash) { :fallback }).to be_nil
    end

    it "returns fallback for a non-existent key" do
      expect(Configurate::Provider.lookup_in_hash(%i[foo bar baz], hash) { :fallback }).to eq :fallback
    end
  end
end
