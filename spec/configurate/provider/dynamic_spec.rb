require 'spec_helper'

describe Configurate::Provider::Dynamic do
  subject { described_class.new }
  describe "#lookup_path" do
    it "returns nil if the setting was never set" do
      expect(subject.lookup_path Configurate::SettingPath.new(["not_me"]) ).to be_nil
    end

    it "remembers the setting if it ends with =" do
      subject.lookup_path Configurate::SettingPath.new(["find_me", "later="]), "there"

      expect(subject.lookup_path Configurate::SettingPath.new(["find_me", "later"]) ).to eq "there"
    end

    it "calls .get on the argument if a proxy object is given" do
      proxy = double(respond_to: true, _proxy?: true)
      expect(proxy).to receive(:get)
      subject.lookup_path Configurate::SettingPath.new(["bla="]), proxy
    end

    it "resolves nested calls after group assignment" do
      subject.lookup_path Configurate::SettingPath.new(["find_me", "later="]), {"a" => "b"}
      expect(subject.lookup_path Configurate::SettingPath.new(["find_me", "later", "a"])).to eq "b"
    end

    it "clears out all overrides on reset_dynamic!" do
      subject.lookup_path Configurate::SettingPath.new(["find_me", "later="]), "there"
      subject.lookup_path Configurate::SettingPath.new(["reset_dynamic!"])
      expect(subject.lookup_path Configurate::SettingPath.new(["find_me", "later"]) ).to_not eq "there"
    end
  end
end
