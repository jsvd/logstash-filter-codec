require "logstash/filters/codec"
require "logstash/codecs/base"
require "json"

describe LogStash::Filters::Codec do

  subject { LogStash::Filters::Codec.new(config) }

  before :each do
    subject.register
  end

  describe "encode" do
    let(:original_event) { LogStash::Event.new("message" => "test") }
    let(:config) { { "mode" => "encode", "codec" => "json" } }
    it "should create a new event with encoded event in target field" do
      subject.filter(original_event) do |event|
        obj = JSON.load(event.get("message"))
        expect(obj["message"]).to eq("test")
      end
    end
  end

  describe "decode" do
    let(:original_event) { LogStash::Event.new("message" => '{"hey": 1}') }
    let(:config) { { "mode" => "decode", "codec" => "json" } }
    it "should create a new event with decoded data in target field" do
      subject.filter(original_event) do |event|
        expect(event.get("hey")).to eq(1)
      end
    end
  end
end
