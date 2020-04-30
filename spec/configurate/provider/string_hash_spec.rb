# frozen_string_literal: true

require "spec_helper"

describe Configurate::Provider::StringHash do
  let(:settings) {
    {
      "toplevel" => "bar",
      "some"     => {
        "nested" => {"some" => "lala", "setting" => "foo"}
      }
    }
  }

  describe "#initialize" do
    it "raises if the argument is not hash" do
      expect {
        described_class.new "foo"
      }.to raise_error ArgumentError
    end

    context "with a namespace" do
      it "looks in the hash for that namespace" do
        namespace = "some.nested"
        provider = described_class.new settings, namespace: namespace
        expect(provider.instance_variable_get(:@settings)).to eq settings["some"]["nested"]
      end

      it "raises if the namespace isn't found" do
        expect {
          described_class.new({}, namespace: "bar")
        }.to raise_error
      end

      it "works with an empty namespace in the file" do
        expect {
          described_class.new({"foo" => {"bar" => nil}}, namespace: "foo.bar")
        }.to_not raise_error
      end
    end

    context "with required set to false" do
      it "doesn't raise if a namespace isn't found" do
        expect {
          described_class.new({}, namespace: "foo", required: false)
        }.not_to raise_error
      end
    end
  end

  describe "#lookup_path" do
    before do
      @provider = described_class.new settings
    end

    it "looks up the whole nesting" do
      expect(@provider.lookup_path(%w[some nested some])).to eq settings["some"]["nested"]["some"]
    end

    it "returns nil if no setting is found" do
      expect(@provider.lookup_path(["not_me"])).to be_nil
    end

    context "with raise_on_missing set to true" do
      before do
        @provider = described_class.new settings, raise_on_missing: true
      end

      it "looks up the whole nesting" do
        expect(@provider.lookup_path(%w[some nested some])).to eq settings["some"]["nested"]["some"]
      end

      it "returns nil if no setting is found" do
        expect {
          @provider.lookup_path ["not_me"]
        }.to raise_error Configurate::MissingSetting
      end
    end
  end
end
