require 'English'

module PatienceDiff
  class UnifiedDiffer
    attr_reader :differ
    attr_accessor :no_grouping, :line_ending
    alias :no_grouping? :no_grouping
    
    def initialize(opts = {})
      @no_grouping = opts.delete(:no_grouping)
      @line_ending = opts.delete(:line_ending) || $RS
      @differ = SequenceMatcher.new(opts)
    end

    def diff(left, right, left_name=nil, right_name=nil, left_timestamp=nil, right_timestamp=nil)
      left_name ||= "Original"
      right_name ||= "Current"
      left_timestamp ||= right_timestamp || Time.now
      right_timestamp ||= left_timestamp || Time.now
      if @no_grouping
        groups = [@differ.diff_opcodes(left, right)]
      else
        groups = @differ.grouped_opcodes(left, right)
      end
      [
        "--- %s\t%s" % [left_name, left_timestamp.strftime("%Y-%m-%d %H:%m:%S.%N %z")],
        "+++ %s\t%s" % [right_name, right_timestamp.strftime("%Y-%m-%d %H:%m:%S.%N %z")],
        groups.collect { |group| unified_diff_group(left, right, group) }.flatten.compact
      ].join(@line_ending)
    end
    
    private
    def unified_diff_group(a, b, opcodes)
      return nil if opcodes.empty?
      
      a_start = opcodes.first[1] + 1
      a_end = opcodes.last[2] + 2
      b_start = opcodes.first[3] + 1
      b_end = opcodes.last[4] + 2
      
      lines = ["@@ -%d,%d +%d,%d @@" % [a_start, a_end-a_start, b_start, b_end-b_start]]
      
      lines << opcodes.collect do |(code, a_start, a_end, b_start, b_end)|
        case code
        when :equal
          b[b_start..b_end].map { |line| ' ' + line }
        when :delete
          a[a_start..a_end].map   { |line| '-' + line }
        when :insert
          b[b_start..b_end].map { |line| '+' + line }
        end
      end
      lines
    end
  end
end
