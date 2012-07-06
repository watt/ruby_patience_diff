require 'patience_diff/differ'
require 'patience_diff/formatting_context'
require 'patience_diff/html/header_helper'
require 'patience_diff/html/hunk_helper'

require 'erubis'

module PatienceDiff
  module Html
    
    # Produces a fancy HTML-formatted unified diff. All your friends will be jealous.
    class Differ < PatienceDiff::Differ
      def initialize(*args)
        super(*args)
        @erbs = Hash.new do |hash, key|
          hash[key] = Erubis::Eruby.new(File.read(key))
        end
      end
      
      def format(opts = {})
        context = FormattingContext.new(self, opts[:title])
        yield context
        template.evaluate(context)
      end
            
      private
      def render_header(*args)
        helper = HeaderHelper.new(*super(*args))
        template("html_header.erb").evaluate(helper)
      end
      
      def render_hunk(a, b, opcodes, last_hunk_end)
        helper = HunkHelper.new(a, b, render_hunk_marker(opcodes), opcodes, last_hunk_end)
        template("html_hunk.erb").evaluate(helper)
      end
      
      def template(filename = "html.erb")
        @erbs[File.join(PatienceDiff::TEMPLATE_PATH, filename)]
      end
    end
  end
end
