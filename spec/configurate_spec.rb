require "spec_helper"

describe Configurate::Settings do
  describe "#method_missing" do
    subject { described_class.create }

    it "delegates the call to a new proxy object" do
      proxy = double
      expect(Configurate::Proxy).to receive(:new).and_return(proxy)
      expect(proxy).to receive(:method_missing).with(:some_setting).and_return("foo")
      subject.some_setting
    end
  end

  %i(lookup add_provider []).each do |method|
    describe "#{method}" do
      subject { described_class.create }

      it "delegates the call to #lookup_chain" do
        expect(subject.lookup_chain).to receive(method)
        subject.send(method)
      end
    end
  end
end
