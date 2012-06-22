require 'patience_diff/differs/base'

module PatienceDiff
  module Differs
    class Unified < Base
      attr_accessor :all_context, :line_ending, :ignore_whitespace
      
      def initialize(opts = {})
        @all_context = opts.delete(:all_context)
        super(opts)
      end
      
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
        
        [
          header(left_name, right_name, left_timestamp, right_timestamp),
          groups.collect { |group| unified_diff_group(left, right, group) }
        ].flatten.compact.join(@line_ending)
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
            a[a_start..a_end].map { |line| '-' + line }
          when :insert
            b[b_start..b_end].map { |line| '+' + line }
          end
        end
        lines
      end
    end
  end
end
