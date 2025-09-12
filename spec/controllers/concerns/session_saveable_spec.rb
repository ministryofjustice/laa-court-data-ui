require 'rails_helper'

RSpec.describe SessionSaveable do
  let(:test_class) { Class.new { include SessionSaveable } }
  let(:object) { TestClass.new }

  before { stub_const("TestClass", test_class) }

  describe "#session_safe" do
    subject(:output) { object.session_safe(data, max_string_length:) }

    let(:max_string_length) { 5 }

    context "when data is a class" do
      let(:data) { User.new }

      it "converts it to a hash" do
        expect(output).to be_a(Hash)
      end
    end

    context "when data is a string" do
      let(:data) { "123456" }

      it "truncates it" do
        expect(output).to eq "12345"
      end
    end

    context "when data is a number" do
      let(:data) { 1.23456 }

      it "leaves it alone" do
        expect(output).to eq 1.23456
      end
    end

    context "when data is an array" do
      let(:data) { [1.23456, "123456"] }

      it "truncates the strings" do
        expect(output).to eq [1.23456, "12345"]
      end
    end

    context "when data is a hash" do
      let(:data) { { a: 1.23456, b: "123456" } }

      it "truncates the strings" do
        expect(output).to eq({ "a" => 1.23456, "b" => "12345" })
      end
    end

    context "when data is a nested hash" do
      let(:data) { { a: 1.23456, b: { c: "123456" } } }

      it "truncates the strings" do
        expect(output).to eq({ "a" => 1.23456, "b" => { "c" => "12345" } })
      end
    end
  end
end
