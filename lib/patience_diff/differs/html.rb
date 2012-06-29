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
        render(formatter)
      end
            
      private
      def render_header(*args)
        left_header, right_header = *super(*args)
        [
          "<div class='left_header'>#{escape(left_header)}</div>",
          "<div class='right_header'>#{escape(right_header)}</div>"
        ]
      end
        
      def render_group_header(b, opcodes, last_line_shown)
        header = super(b, opcodes, last_line_shown)
        b_start = opcodes.first[3]
        number_hidden = b_start - last_line_shown - 1
        if number_hidden > 0
          [
            "<div class='collapsed' id='collapsed_#{b_start}'><div>",
            "<div class='divider' onclick='page.toggleCollapse(#{b_start})'>",
            "<span class='group_header'>#{'&nbsp;' * header.length}</span>",
            "Click to collapse #{number_hidden} lines</div>",
            b[(last_line_shown+1)...b_start].map { |line| render_line(line, :equal) },
            "</div></div>",
            "<div class='divider' onclick='page.toggleCollapse(#{b_start})'>",
            "<span class='group_header'>#{escape(header)}</span>",
            "<span class='hint'>Click to expand #{number_hidden} lines</span></div>",
          ]
        else
          "<div class='divider'><span class='group_header'>#{escape(header)}</span></div>"
        end
      end
      
      def render_line(line, code)
        case code
        when :equal
          "<div class='equal'> #{escape(line)}</div>"
        when :delete
          "<div class='delete'>-#{escape(line)}</div>"
        when :insert
          "<div class='insert'>+#{escape(line)}</div>"
        end
      end
      
      def escape(raw)
        CGI::escape_html(raw)
      end

      def template
        File.join(PatienceDiff::TEMPLATE_PATH, 'html.erb')
      end
      
      def render(formatter)
        @erb ||= Erubis::Eruby.new(File.read(template))
        @erb.evaluate(formatter)
      end
    end
  end
end
