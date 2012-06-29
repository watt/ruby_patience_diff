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
          @differ.diff(*args)
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
        
        lines = render_header(left_name, right_name, left_timestamp, right_timestamp)
        last_line_shown = -1
        groups.each do |group|
          lines << render_group_header(b, group, last_line_shown)
          lines << render_diff_group(a, b, group)
          last_line_shown = group.last[4]
        end
        lines.flatten.compact.join(@line_ending)
      end
      
      private
      def render_header(left_name=nil, right_name=nil, left_timestamp=nil, right_timestamp=nil)
        left_name ||= "Original"
        right_name ||= "Current"
        left_timestamp ||= right_timestamp || Time.now
        right_timestamp ||= left_timestamp || Time.now
        [
          "--- %s\t%s" % [left_name, left_timestamp.strftime("%Y-%m-%d %H:%m:%S.%N %z")],
          "+++ %s\t%s" % [right_name, right_timestamp.strftime("%Y-%m-%d %H:%m:%S.%N %z")]
        ]
      end
      
      def render_group_header(b, opcodes, last_line_shown)
        a_start = opcodes.first[1] + 1
        a_end = opcodes.last[2] + 2
        b_start = opcodes.first[3] + 1
        b_end = opcodes.last[4] + 2
        
        "@@ -%d,%d +%d,%d @@" % [a_start, a_end-a_start, b_start, b_end-b_start]
      end
      
      def render_diff_group(a, b, opcodes)
        opcodes.collect do |(code, a_start, a_end, b_start, b_end)|
          if code == :delete 
            a[a_start..a_end]
          else
            b[b_start..b_end]
          end.map { |line| render_line(line, code) }
        end
      end
      
      def render_line(line, code)
        case code
        when :equal
          ' ' + line
        when :delete
          '-' + line
        when :insert
          '+' + line
        end
      end
    end
  end
end
