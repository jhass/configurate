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
      ValidConfigurationProvider.should_receive(:new).with(:extra)
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
      setting.stub(:clone).and_return(setting)
      @provider.each do |provider|
        provider.should_receive(:lookup).with(setting).and_raise(Configurate::SettingNotFoundError)
      end
      
      subject.lookup(setting)
    end

    it "converts a string to a SettingPath" do
      provider = @provider.first
      path = stub
      path.stub(:clone).and_return(path)
      provider.should_receive(:lookup).with(path).and_raise(Configurate::SettingNotFoundError)
      setting = "bar"
      Configurate::SettingPath.should_receive(:new).with(setting).and_return(path)
      subject.lookup(setting)
    end

    it "passes a copy of the SettingPath to the provider" do
      provider = @provider.first
      path = mock("path")
      copy = stub("copy")
      path.should_receive(:clone).at_least(:once).and_return(copy)
      provider.should_receive(:lookup).with(copy).and_raise(Configurate::SettingNotFoundError)
      subject.lookup(path)
    end
    
    it "stops if a value is found" do
      @provider[0].should_receive(:lookup).and_return("something")
      @provider[1].should_not_receive(:lookup)
      subject.lookup("bla")
    end
    
    it "converts numbers to strings" do
      @provider[0].stub(:lookup).and_return(5)
      subject.lookup("foo").should == "5"
    end
    
    it "does not convert false to a string" do
      @provider[0].stub(:lookup).and_return(false)
      subject.lookup("enable").should be_false
    end

    it "converts 'true' to true" do
      @provider[0].stub(:lookup).and_return("true")
      subject.lookup("enable").should be_true
    end

    it "converts 'false' to false" do
      @provider[0].stub(:lookup).and_return("false")
      subject.lookup("enable").should be_false
    end

    it "returns the value unchanged if it can't be converted" do
      value = mock
      value.stub(:respond_to?).with(:to_s).and_return(false)
      @provider[0].stub(:lookup).and_return(value)
      subject.lookup("enable").should == value
    end
    
    it "returns nil if no value is found" do
      @provider.each { |p| p.stub(:lookup).and_raise(Configurate::SettingNotFoundError) }
      subject.lookup("not.me").should be_nil
    end
  end
end
