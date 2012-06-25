require 'English'
require 'patience_diff/sequence_matcher'

module PatienceDiff
  module Differs
    
    # Produces plaintext unified diffs.
    class Unified
      
      # Delegate object returned by the #format method.
      class Formatter
        def initialize(differ)
          @differ = differ
        end
        def diff(*args)
          puts @differ.diff(*args)
        end
      end
      
      attr_reader :matcher
      attr_accessor :all_context, :line_ending, :ignore_whitespace
      
      # Options:
      #   * :all_context: Output the entirety of each file. This overrides the sequence matcher's context setting.
      #   * :line_ending: Delimiter to use when joining diff output. Defaults to $RS.
      #   * :ignore_whitespace: Before comparing lines, strip trailing whitespace, and treat leading whitespace as either present or not. Does not affect output.
      # Any additional options (e.g. :context) are passed on to the sequence matcher.
      def initialize(opts = {})
        @all_context = opts.delete(:all_context)
        @line_ending = opts.delete(:line_ending) || $RS
        @ignore_whitespace = opts.delete(:ignore_whitespace)
        @matcher = SequenceMatcher.new(opts)
      end
      
      # Produce a multi-file formatted diff.
      # Yields a delegate object, on which you should call #diff on for each set of files you want in the formatted diff.
      def format
        yield Formatter.new(self)
      end
      
      # Diff 2 files.
      # File names and timestamps do not affect the diff algorithm, but are used in the header text.
      def diff(left, right, left_name=nil, right_name=nil, left_timestamp=nil, right_timestamp=nil)
        if @ignore_whitespace
          a = left.map  { |line| line.rstrip.gsub(/^\s+/, ' ') }
          b = right.map { |line| line.rstrip.gsub(/^\s+/, ' ') }
        else
          a = left
          b = right
        end
        
        if @all_context
          groups = [@matcher.diff_opcodes(a, b)]
        else
          groups = @matcher.grouped_opcodes(a, b)
        end
        
        lines = header
        last_shown_line = -1
        groups.each do |group|
          b_start = group.first[3]
          if b_start - last_shown_line > 1
            lines << render_collapsed(b, last_shown_line + 1, b_start - 1)
          end
          last_shown_line = group.last[4]
          lines << render_diff_group(a, b, group)
        end
        lines.flatten.compact.join(@line_ending)
      end
      
      private
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
      
      def render_diff_group(a, b, opcodes)
        return nil if opcodes.empty?
        
        a_start = opcodes.first[1] + 1
        a_end = opcodes.last[2] + 2
        b_start = opcodes.first[3] + 1
        b_end = opcodes.last[4] + 2
        
        lines = ["@@ -%d,%d +%d,%d @@" % [a_start, a_end-a_start, b_start, b_end-b_start]]
        
        lines << opcodes.collect do |(code, a_start, a_end, b_start, b_end)|
          case code
          when :equal
            b[b_start..b_end].map { |line| process_line(' ' + line, code) }
          when :delete
            a[a_start..a_end].map { |line| process_line('-' + line, code) }
          when :insert
            b[b_start..b_end].map { |line| process_line('+' + line, code) }
          end
        end
        lines
      end
      
      def process_line(line, code)
        line
      end
      
      def render_collapsed(lines, first_line, last_line)
        nil
      end
    end
  end
end
