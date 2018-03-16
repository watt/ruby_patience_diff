# frozen_string_literal: true

require 'English'
require 'patience_diff/formatter'
require 'patience_diff/sequence_matcher'

module PatienceDiff
  class Differ
    attr_reader :matcher
    attr_accessor :all_context, :line_ending, :ignore_whitespace

    # Options:
    #   * :all_context: Output the entirety of each file. This overrides the sequence matcher's context setting.
    #   * :line_ending: Delimiter to use when joining diff output. Defaults to $RS.
    #   * :ignore_whitespace: Before comparing lines, strip trailing whitespace, and treat leading whitespace
    #     as either present or not. Does not affect output.
    # Any additional options (e.g. :context) are passed on to the sequence matcher.
    def initialize(opts = {})
      @all_context = opts.delete(:all_context)
      @line_ending = opts.delete(:line_ending) || $RS
      @ignore_whitespace = opts.delete(:ignore_whitespace)
      @formatter = opts.delete(:formatter) || UnifiedFormatter.new
      @matcher = SequenceMatcher.new(opts)
      @grouper = ContextGrouper.new(opts)
    end

    # Generates a formatted diff from the contents of the files at the paths specified.
    def diff_files(left_file, right_file)
      (left_data, left_timestamp), (right_data, right_timestamp) = [left_file, right_file].map do |filename|
        # Read in binary encoding, so that we can diff any encoding and split() won't complain
        File.open(filename, external_encoding: Encoding::BINARY) do |file|
          [file.read.split($RS), file.mtime]
        end
      end
      diff_sequences(
        left_data,
        right_data,
        left_file: left_file,
        right_file: right_file,
        left_timestamp: left_timestamp,
        right_timestamp: right_timestamp
      )
    end

    # Generate a formatted diff of two strings. File names and timestamps do
    # not affect the diff algorithm, but are used in the header text.
    # TODO: rdoc
    def diff_sequences(left, right, options = {})
      left_name = options[:left_name]
      right_name = options[:right_name]
      left_timestamp = options[:left_timestamp]
      right_timestamp = options[:right_timestamp]

      if @ignore_whitespace
        a = left.map  { |line| line.rstrip.gsub(/^\s+/, ' ') }
        b = right.map { |line| line.rstrip.gsub(/^\s+/, ' ') }
      else
        a = left
        b = right
      end

      opcodes = @matcher.diff_opcodes(a, b)
      hunks = @all_context ? [opcodes] : @grouper.group(opcodes: opcodes)

      return nil unless hunks.any?

      @formatter.format(
        a: left,
        b: right,
        hunks: hunks,
        a_name: left_name,
        b_name: right_name,
        a_timestamp: left_timestamp,
        b_timestamp: right_timestamp
      )
    end
  end
end
