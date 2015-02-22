require "spec_helper"

describe Configurate::Provider::Base do
  describe "#lookup" do
    subject { described_class.new }
    it "calls #lookup_path" do
      path = Configurate::SettingPath.new(%w(foo bar))
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
end
