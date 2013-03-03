require 'spec_helper'

describe Configurate::Provider::Base do
  describe "#lookup" do
    subject { described_class.new }
    it "calls #lookup_path" do
      path = Configurate::SettingPath.new(["foo", "bar"])
      subject.should_receive(:lookup_path).with(path).and_return("something")
      subject.lookup(path).should == "something"
    end
    
    it "raises SettingNotFoundError if the #lookup_path returns nil" do
      subject.stub(:lookup_path).and_return(nil)
      expect {
        subject.lookup("bla")
      }.to raise_error Configurate::SettingNotFoundError
    end
  end
end
