require 'patience_diff/differs/unified'
require 'erubis'
require 'stringio'
require 'cgi'

module PatienceDiff
  module Differs
    
    # Produces a fancy HTML-formatted unified diff. All your friends will be jealous.
    class Html < Unified
      
      # Delegate object yielded by the #format method.
      class Formatter
        attr_reader :files
        attr_accessor :title
        
        def initialize(differ)
          @differ = differ
          @files = []
          @out = StringIO.new
          @title = "Diff generated on #{Time.now.strftime('%c')}"
        end
        
        def diff(left, right, left_name=nil, right_name=nil, left_timestamp=nil, right_timestamp=nil)
          @files << left_name
          @out.puts @differ.diff(left, right, left_name, right_name, left_timestamp, right_timestamp)
        end
        
        def content
          @out.string
        end
      end
      
      # Produce a multi-file formatted diff.
      # Yields a delegate object, on which you should call #diff on for each set of files you want in the formatted diff.
      def format
        raise "Block required" unless block_given?
        
        formatter = Formatter.new(self)
        yield formatter
        render(formatter.files, formatter.to_s)
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

      def template
        File.join(PatienceDiff::TEMPLATE_PATH, 'html.erb')
      end
      
      def render(files, content)
        @erb ||= Erubis:Eruby.new(File.read(template))
        @erb.evaluate(formatter)
      end
    end
  end
end
