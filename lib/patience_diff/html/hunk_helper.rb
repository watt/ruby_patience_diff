require 'patience_diff/html/escaping'

module PatienceDiff
  module Html
    class HunkHelper
      include Escaping
      attr_accessor :a, :b, :hunk_marker, :opcodes, :last_hunk_end, :syntax_highlighter
      
      def initialize(a, b, hunk_marker, opcodes, last_hunk_end, syntax_highlighter)
        @a = a
        @b = b
        @hunk_marker = hunk_marker
        @opcodes = opcodes
        @last_hunk_end = last_hunk_end
        @syntax_highlighter = syntax_highlighter
      end
      
      def hunk_start
        @opcodes.first[3]
      end
      
      def hidden_line_count
        hunk_start - @last_hunk_end - 1
      end
      
      def lines
        @b
      end
      
      def each_line
        opcodes.each do |(code, a_start, a_end, b_start, b_end)|
          case code
          when :delete
            a[a_start..a_end].each { |line| yield 'delete', '-' + line }
          when :equal
            b[b_start..b_end].each { |line| yield 'equal',  ' ' + line }
          when :insert
            b[b_start..b_end].each { |line| yield 'insert', '+' + line }
          end
        end
      end
      
      def format_line(line)
        if @syntax_highlighter
          @syntax_highlighter.highlight(escape(line))
        else
          escape(line)
        end
      end
    end
  end
end
