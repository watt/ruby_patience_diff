require 'patience_diff/differs/unified'
require 'erubis'
require 'stringio'
require 'cgi'

module PatienceDiff
  module Differs
    class Html < Unified
      
      class Formatter
        attr_reader :files
        
        def initialize(differ)
          @differ = differ
          @files = []
          @out = StringIO.new
        end
        
        def diff(left, right, left_name=nil, right_name=nil, left_timestamp=nil, right_timestamp=nil)
          @files << left_name
          @out.puts @differ.diff(left, right, left_name, right_name, left_timestamp, right_timestamp)
        end
        
        def to_s
          @out.string
        end
      end
      
      def format
        raise "Block required" unless block_given?
        
        formatter = Formatter.new(self)
        erb = Erubis::Eruby.new(TEMPLATE)
        out = erb.evaluate do
          yield formatter
          #todo: create TOC here, handle no files
          formatter.to_s
        end
        puts out
      end
            
      private
      def render_collapsed(lines, first_line, last_line)
        "<span>#{last_line - first_line + 1} lines collapsed</span>"
      end
      
      def process_line(line, code)
        "<span class='#{code}'>#{escape(line)}</span>"
      end
      
      def escape(raw)
        CGI::escape_html(raw)
      end

      TEMPLATE = <<-EOF
<!DOCTYPE html>
<html lang="en">
  <head>
  <meta charset="utf-8" />
  <title>diff</title>
  </head>
  <body>
  <pre><%= yield %></pre>
  </body>
</html>
EOF

    end
  end
end
