require 'spec_helper'

class InvalidConfigurationProvider; end
class ValidConfigurationProvider
  def lookup(setting, *args); end
end

describe Configurate::LookupChain do
  subject { described_class.new }

  describe "#add_provider" do
    it "adds a valid provider" do
      expect {
        subject.add_provider ValidConfigurationProvider
      }.to change { subject.instance_variable_get(:@provider).size }.by 1
    end

    it "doesn't add an invalid provider" do
      expect {
        subject.add_provider InvalidConfigurationProvider
      }.to raise_error ArgumentError
    end

    it "passes extra args to the provider" do
      expect(ValidConfigurationProvider).to receive(:new).with(:extra)
      subject.add_provider ValidConfigurationProvider, :extra
    end
  end

  describe "#lookup" do
    before do
      subject.add_provider ValidConfigurationProvider
      subject.add_provider ValidConfigurationProvider
      @provider = subject.instance_variable_get(:@provider)
    end

    it "it tries all providers" do
      setting = Configurate::SettingPath.new "some.setting"
      allow(setting).to receive(:clone).and_return(setting)
      @provider.each do |provider|
        expect(provider).to receive(:lookup).with(setting).and_raise(Configurate::SettingNotFoundError)
      end

      subject.lookup(setting)
    end

    it "converts a string to a SettingPath" do
      provider = @provider.first
      path = double
      allow(path).to receive(:clone).and_return(path)
      expect(provider).to receive(:lookup).with(path).and_raise(Configurate::SettingNotFoundError)
      setting = "bar"
      expect(Configurate::SettingPath).to receive(:new).with(setting).and_return(path)
      subject.lookup(setting)
    end

    it "passes a copy of the SettingPath to the provider" do
      provider = @provider.first
      path = double("path")
      copy = double("copy")
      expect(path).to receive(:clone).at_least(:once).and_return(copy)
      expect(provider).to receive(:lookup).with(copy).and_raise(Configurate::SettingNotFoundError)
      subject.lookup(path)
    end

    it "stops if a value is found" do
      expect(@provider[0]).to receive(:lookup).and_return("something")
      expect(@provider[1]).to_not receive(:lookup)
      subject.lookup("bla")
    end

    it "converts numbers to strings" do
      allow(@provider[0]).to receive(:lookup).and_return(5)
      expect(subject.lookup "foo").to eq "5"
    end

    it "does not convert false to a string" do
      allow(@provider[0]).to receive(:lookup).and_return(false)
      expect(subject.lookup "enable").to be_falsey
    end

    it "converts 'true' to true" do
      allow(@provider[0]).to receive(:lookup).and_return("true")
      expect(subject.lookup "enable").to be_truthy
    end

    it "converts 'false' to false" do
      allow(@provider[0]).to receive(:lookup).and_return("false")
      expect(subject.lookup "enable").to be_falsey
    end

    it "returns the value unchanged if it can't be converted" do
      value = double
      allow(value).to receive(:respond_to?).with(:to_s).and_return(false)
      allow(@provider[0]).to receive(:lookup).and_return(value)
      expect(subject.lookup "enable").to eq value
    end

    it "returns nil if no value is found" do
      @provider.each { |p| allow(p).to receive(:lookup).and_raise(Configurate::SettingNotFoundError) }
      expect(subject.lookup "not.me").to be_nil
    end
  end
end
