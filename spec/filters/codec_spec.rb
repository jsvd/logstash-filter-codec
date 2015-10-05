require 'spec_helper'
require "logstash/filters/codec"

describe LogStash::Filters::Codec do
  let(:test_codec_class) do
    Class.new(LogStash::Codecs::Base) do
      config_name "test_codec"
      def encode(event)
        @on_event.call(event, event["message"].size)
      end
      def decode(data)
        LogStash::Event.new("message" => "a"*data.to_i)
      end
    end
  end

  subject { LogStash::Filters::Codec.new(config) }

  before :each do
    allow(LogStash::Plugin).to receive(:lookup).with("codec", "test_codec") { test_codec_class }
    subject.register
  end

  describe "encode" do
    let(:original_event) { LogStash::Event.new("message" => "test") }
    let(:config) { { "mode" => "encode", "codec" => "test_codec" } }
    it "should create a new event with encoded event in target field" do
      subject.filter(original_event) do |event|
        expect(event.to_hash).to include("message" => 4)
      end
    end
  end

  describe "decode" do
    let(:original_event) { LogStash::Event.new("message" => 5) }
    let(:config) { { "mode" => "decode", "codec" => "test_codec" } }
    it "should create a new event with decoded data in target field" do
      subject.filter(original_event) do |event|
        expect(event.to_hash).to include("message" => "aaaaa")
      end
    end
  end
end
