require "spec_helper"

describe Configurate::Provider::YAML do
  let(:settings) {
    {
      "toplevel" => "bar",
      "some"     => {
        "nested" => {"some" => "lala", "setting" => "foo"}
      }
    }
  }

  describe "#initialize" do
    it "loads the file" do
      file = "foobar.yml"
      expect(::YAML).to receive(:load_file).with(file).and_return({})
      described_class.new file
    end

    it "raises if the file is not found" do
      allow(::YAML).to receive(:load_file).and_raise(Errno::ENOENT)
      expect {
        silence_stderr do
          described_class.new "foo"
        end
      }.to raise_error Errno::ENOENT
    end

    context "with a namespace" do
      it "looks in the file for that namespace" do
        namespace = "some.nested"
        allow(::YAML).to receive(:load_file).and_return(settings)
        provider = described_class.new "bla", namespace: namespace
        expect(provider.instance_variable_get :@settings).to eq settings["some"]["nested"]
      end

      it "raises if the namespace isn't found" do
        allow(::YAML).to receive(:load_file).and_return({})
        expect {
          described_class.new "bla", namespace: "bar"
        }.to raise_error
      end

      it "works with an empty namespace in the file" do
        allow(::YAML).to receive(:load_file).and_return("foo" => {"bar" => nil})
        expect {
          described_class.new "bla", namespace: "foo.bar"
        }.to_not raise_error
      end
    end

    context "with required set to false" do
      it "doesn't raise if a file isn't found" do
        allow(::YAML).to receive(:load_file).and_raise(Errno::ENOENT)
        expect {
          described_class.new "not_me", required: false
        }.not_to raise_error
      end

      it "doesn't raise if a namespace isn't found" do
        allow(::YAML).to receive(:load_file).and_return({})
        expect {
          described_class.new "bla", namespace: "foo", required: false
        }.not_to raise_error
      end
    end
  end

  describe "#lookup_path" do
    before do
      allow(::YAML).to receive(:load_file).and_return(settings)
      @provider = described_class.new "dummy"
    end

    it "looks up the whole nesting" do
      expect(@provider.lookup_path %w(some nested some)).to eq settings["some"]["nested"]["some"]
    end

    it "returns nil if no setting is found" do
      expect(@provider.lookup_path ["not_me"]).to be_nil
    end

    context "with raise_on_missing set to true" do
      before do
        @provider = described_class.new "dummy", raise_on_missing: true
      end

      it "looks up the whole nesting" do
        expect(@provider.lookup_path %w(some nested some)).to eq settings["some"]["nested"]["some"]
      end

      it "returns nil if no setting is found" do
        expect {
          @provider.lookup_path ["not_me"]
        }.to raise_error Configurate::MissingSetting
      end
    end
  end
end
