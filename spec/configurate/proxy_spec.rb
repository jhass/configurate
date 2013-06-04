require 'spec_helper'

describe Configurate::Proxy do
  let(:lookup_chain) { mock(lookup: "something") }
  let(:proxy) { described_class.new(lookup_chain) }

  describe "in case statements" do
    it "acts like the target" do
      pending "If anyone knows a way to overwrite ===, please tell me :P"
      result = case proxy
               when String
                "string"
               else
                "wrong"
               end
      result.should == "string"
    end
  end
  
  describe "#method_missing" do
    it "calls #target if the method ends with a ?" do
      lookup_chain.should_receive(:lookup).and_return(false)
      proxy.method_missing(:enable?)
    end
    
    it "calls #target if the method ends with a =" do
      lookup_chain.should_receive(:lookup).and_return(false)
      proxy.method_missing(:url=)
    end
  end

  describe "delegations" do
    it "calls the target when negating" do
      target = mock
      lookup_chain.stub(:lookup).and_return(target)
      target.should_receive(:!)
      proxy.something.__send__(:!)
    end

    it "enables sends even though be BasicObject" do
      proxy.should_receive(:foo)
      proxy.send(:foo)
    end
  end

  describe "#proxy" do
    subject { proxy._proxy? }
    it { should be_true }
  end
  
  describe "#target" do
    [:to_str, :to_s, :to_xml, :respond_to?, :present?, :!=, :eql?,
     :each, :try, :size, :length, :count, :==, :=~, :gsub, :blank?, :chop,
     :start_with?, :end_with?].each do |method|
      it "is called for accessing #{method} on the proxy" do
        target = mock
        lookup_chain.stub(:lookup).and_return(target)
        target.stub(:respond_to?).and_return(true)
        target.stub(:_proxy?).and_return(false)
        target.should_receive(method).and_return("something")
        proxy.something.__send__(method, mock)
      end
    end
    
    described_class::COMMON_KEY_NAMES.each do |method|
      it "is not called for accessing #{method} on the proxy" do
        target = mock
        lookup_chain.should_not_receive(:lookup)
        target.should_not_receive(method)
        proxy.something.__send__(method, mock)
      end
    end
    
    it "returns nil if no setting is given" do
      proxy.target.should be_nil
    end
  end
end
