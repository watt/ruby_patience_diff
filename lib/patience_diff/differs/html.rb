require 'patience_diff/differs/unified'
require 'erubis'
require 'stringio'
require 'cgi'

module PatienceDiff
  module Differs
    
    # Produces a fancy HTML-formatted unified diff. All your friends will be jealous.
    class Html < Unified
      
      class Formatter < PatienceDiff::Differs::Unified::Formatter ; end
      class HtmlContext
      end
      class HunkHelper
        def render_line(line, code)
          case code
          when :equal
            "<div class='equal diff'> #{escape(line)}</div>"
          when :delete
            "<div class='delete diff'>-#{escape(line)}</div>"
          when :insert
            "<div class='insert diff'>+#{escape(line)}</div>"
          end
        end

        def escape(raw)
          CGI::escape_html(raw)
        end
      end
      
      def initialize
        @erbs = Hash.new do |hash, key|
          hash[key] = Erubis::Eruby.new(File.read(key))
        end
      end
      
      # Produce a multi-file formatted diff.
      # Yields a delegate object, on which you should call #diff on for each set of files you want in the formatted diff.
      def format
        buf = StringIO.new
        yield Formatter.new(self, buf)
        template.evaluate(HtmlContext.new(self, buf.string))
      end
            
      private
      def render_header(*args)
        left_header, right_header = *super(*args)
        [
          "<div class='left_title diff'>#{escape(left_header)}</div>",
          "<div class='right_title diff'>#{escape(right_header)}</div>"
        ]
      end
      
      def render_hunk(a, b, opcodes, last_hunk_end)
        hunk_start = opcodes.first[3]
        helper = HunkHelper.new(b, render_hunk_marker(opcodes), hunk_start, last_hunk_end)

        lines = template("html_header.erb").evaluate(helper)
        lines << opcodes.collect do |(code, a_start, a_end, b_start, b_end)|
          if code == :delete 
            a[a_start..a_end]
          else
            b[b_start..b_end]
          end.map { |line| helper.render_line(line, code) }
        end
        lines
      end
      
      
      def template(filename = "html.erb")
        @erbs[File.join(PatienceDiff::TEMPLATE_PATH, filename)]
      end
    end
  end
end
