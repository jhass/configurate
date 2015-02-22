require "spec_helper"

describe Configurate::Proxy do
  let(:lookup_chain) { double(lookup: "something") }
  let(:proxy) { described_class.new(lookup_chain) }

  describe "in case statements" do
    it "acts like the target" do
      pending "If anyone knows a sane way to overwrite Module#===, please tell me :P"
      result = case proxy
               when String
                 "string"
               else
                 "wrong"
               end
      expect(result).to eq "string"
    end
  end

  describe "#method_missing" do
    it "calls #target if the method ends with a ?" do
      expect(lookup_chain).to receive(:lookup).and_return(false)
      proxy.method_missing(:enable?)
    end

    it "calls #target if the method ends with a !" do
      expect(lookup_chain).to receive(:lookup).and_return(false)
      proxy.method_missing(:do_it!)
    end

    it "calls #target if the method ends with a =" do
      expect(lookup_chain).to receive(:lookup).and_return(false)
      proxy.method_missing(:url=)
    end
  end

  describe "delegations" do
    it "calls the target when negating" do
      target = double
      allow(lookup_chain).to receive(:lookup).and_return(target)
      expect(target).to receive(:!)
      proxy.something.__send__(:!)
    end

    it "enables sends even though be BasicObject" do
      expect(proxy).to receive(:foo)
      proxy.send(:foo)
    end
  end

  describe "#proxy" do
    subject { proxy._proxy? }
    it { should be_truthy }
  end

  describe "#target" do
    %i(to_s to_xml respond_to? present? != eql? each try size length
       count == =~ gsub blank? chop start_with? end_with?).each do |method|
      it "is called for accessing #{method} on the proxy" do
        target = double(respond_to?: true, _proxy?: false)
        allow(lookup_chain).to receive(:lookup).and_return(target)
        expect(target).to receive(method).and_return("something")
        proxy.something.__send__(method, double)
      end
    end

    described_class::COMMON_KEY_NAMES.each do |method|
      it "is not called for accessing #{method} on the proxy" do
        target = double
        expect(lookup_chain).to_not receive(:lookup)
        expect(target).to_not receive(method)
        proxy.something.__send__(method, double)
      end
    end

    it "returns nil if no setting is given" do
      expect(proxy.target).to be_nil
    end

    it "converts to a string" do
      allow(lookup_chain).to receive(:lookup).and_return("bar")
      expect("foo#{proxy.something}").to eq "foobar"
    end

    it "converts to a number" do
      allow(lookup_chain).to receive(:lookup).and_return(1)
      expect(2 + proxy.something).to eq 3
    end

    it "converts to an array" do
      allow(lookup_chain).to receive(:lookup).and_return([1, 2])
      expect(%i(a b).zip(proxy.something)).to eq [[:a, 1], [:b, 2]]
    end

    it "converts to a hash" do
      allow(lookup_chain).to receive(:lookup).and_return(a: :b)
      expect({c: :d}.merge(proxy.something)).to eq a: :b, c: :d
    end
  end
end
