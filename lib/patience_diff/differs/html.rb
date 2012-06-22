require 'patience_diff/differs/base'

module PatienceDiff
  module Differs
    class Html < Base
      
      def format
        #todo header html
        yield
        #todo footer html
      end
      
      def header(left_name=nil, right_name=nil, left_timestamp=nil, right_timestamp=nil)
        #todo
      end
      
      def diff(left, right, left_name=nil, right_name=nil, left_timestamp=nil, right_timestamp=nil)
        if @ignore_whitespace
          a = left.map  { |line| line.rstrip.gsub(/^\s+/, ' ') }
          b = right.map { |line| line.rstrip.gsub(/^\s+/, ' ') }
        else
          a = left
          b = right
        end
        
        opcodes = @matcher.diff_opcodes(a, b)
        
        #todo
      end
    end
  end
end
