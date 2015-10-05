# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

# This plugin fulfills the simple role of executing a encode/decode operation
# of a chosen codec over the received event.
class LogStash::Filters::Codec < LogStash::Filters::Base

  # Setting the codec and mode here is required.
  #
  # filter {
  #   codec {
  #     codec => dots
  #     mode => encode
  #   }
  # }
  #
  config_name "codec"
  
  # Which codec to use. e.g. "dots", "json"
  config :codec, :validate => :codec, :required => true

  # Execute either an encode or decode operation.
  # If `encode` is specified, the event is passed to the codec
  # for encoding and the output is placed in the `target` field
  # of the new event.
  #
  # If `decode` is used instead, the contents of the `source` field
  # of the filtered event are passed to the decode function of the codec,
  # and a new event is generated as a result. The original event is canceled.
  config :mode, :validate => ["encode", "decode"], :required => true

  # Only relevant if mode is decode.
  # Name of the field in the event from where to extract data to be decoded.
  config :source, :validate => :string, :default => "message"

  # Only relevant if mode is encode.
  # Name of the field in the new event that will contain the encoded event.
  config :target, :validate => :string, :default => "message"

  public
  def register
    @codec.on_event { |new_event, payload| payload }
  end # def register

  public
  def filter(event)

    if @mode == "encode" then
      yield LogStash::Event.new(@target => @codec.encode(event))
    else # decode
      # TODO: allow merging of the original event and the decoded event
      @codec.decode(event[@source]) do |event|
        yield event
      end
    end

    # either in encode or decode mode we generate a new event
    # so the original one can be cancelled
    event.cancel
  end # def filter
end # class LogStash::Filters::Example
