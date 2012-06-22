require 'English'
require 'patience_diff/sequence_matcher'

module PatienceDiff
  module Differs
    class Base
      attr_reader :matcher
      attr_accessor :line_ending, :ignore_whitespace
      
      def initialize(opts = {})
        @line_ending = opts.delete(:line_ending) || $RS
        @ignore_whitespace = opts.delete(:ignore_whitespace)
        @matcher = SequenceMatcher.new(opts)
      end
      
      def format
        yield
      end
      
      def header(left_name=nil, right_name=nil, left_timestamp=nil, right_timestamp=nil)
        left_name ||= "Original"
        right_name ||= "Current"
        left_timestamp ||= right_timestamp || Time.now
        right_timestamp ||= left_timestamp || Time.now
        [
          "--- %s\t%s" % [left_name, left_timestamp.strftime("%Y-%m-%d %H:%m:%S.%N %z")],
          "+++ %s\t%s" % [right_name, right_timestamp.strftime("%Y-%m-%d %H:%m:%S.%N %z")]
        ]
      end
    end
  end
end
