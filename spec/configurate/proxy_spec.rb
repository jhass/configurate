require 'spec_helper'

describe Configurate::Proxy do
  let(:lookup_chain) { mock }
  before do
    lookup_chain.stub(:lookup).and_return("something")
  end
  
  describe "#method_missing" do
    it "calls #target if the method ends with a ?" do
      lookup_chain.should_receive(:lookup).and_return(false)
      described_class.new(lookup_chain).method_missing(:enable?)
    end
    
    it "calls #target if the method ends with a =" do
      lookup_chain.should_receive(:lookup).and_return(false)
      described_class.new(lookup_chain).method_missing(:url=)
    end
  end

  describe "delegations" do
    it "calls the target when negating" do
      target = mock
      lookup_chain.stub(:lookup).and_return(target)
      target.should_receive(:!)
      described_class.new(lookup_chain).something.__send__(:!)
    end

    it "calls __send__ on send" do
      proxy = described_class.new(lookup_chain)
      proxy.should_receive(:__send__).with(:foo).and_return(nil)
      proxy.send(:foo)
    end
  end

  describe "#proxy" do
    subject { described_class.new(lookup_chain)._proxy? }
    it { should be_true }
  end
  
  describe "#target" do
    [:to_str, :to_s, :to_xml, :respond_to?, :present?, :!=,
     :each, :try, :size, :length, :count, :==, :=~, :gsub, :blank?, :chop,
     :start_with?, :end_with?].each do |method|
      it "is called for accessing #{method} on the proxy" do
        target = mock
        lookup_chain.stub(:lookup).and_return(target)
        target.stub(:respond_to?).and_return(true)
        target.stub(:_proxy?).and_return(false)
        target.should_receive(method).and_return("something")
        described_class.new(lookup_chain).something.__send__(method, mock)
      end
    end
    
    described_class::COMMON_KEY_NAMES.each do |method|
      it "is not called for accessing #{method} on the proxy" do
        target = mock
        lookup_chain.should_not_receive(:lookup)
        target.should_not_receive(method)
        described_class.new(lookup_chain).something.__send__(method, mock)
      end
    end
    
    it "returns nil if no setting is given" do
      described_class.new(lookup_chain).target.should be_nil
    end
  end
end
