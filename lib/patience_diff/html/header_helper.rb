require 'patience_diff/html/escaping'

module PatienceDiff
  module Html
    class HeaderHelper
      include Escaping
      attr_accessor :left_header, :right_header
      
      def initialize(left_header, right_header)
        @left_header = left_header
        @right_header = right_header
      end
    end
  end
end
