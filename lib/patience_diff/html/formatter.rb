require 'patience_diff/formatter'
require 'patience_diff/formatting_context'
require 'patience_diff/html/header_helper'
require 'patience_diff/html/hunk_helper'

require 'erubis'

module PatienceDiff
  module Html
    
    # Produces a fancy HTML-formatted unified diff. All your friends will be jealous.
    class Formatter < PatienceDiff::Formatter
      def initialize(*args)
        super(*args)
        @erbs = Hash.new do |hash, key|
          hash[key] = Erubis::Eruby.new(File.read(key))
        end
      end
      
      def format
        context = FormattingContext.new(@differ, self)
        yield context
        template.evaluate(context)
      end
            
      def render_header(*args)
        left_header, right_header = *super(*args)
        helper = HeaderHelper.new(left_header, right_header, @names.count)
        template("html_header.erb").evaluate(helper)
      end
      
      def render_hunk(a, b, opcodes, last_hunk_end)
        helper = HunkHelper.new(a, b, render_hunk_marker(opcodes), opcodes, last_hunk_end)
        template("html_hunk.erb").evaluate(helper)
      end
      
      # Render a single file as if it were a diff with no changes & full context
      def render_orphan(sequence, name, timestamp)
        @names << name
        left_header = "--- New file"
        right_header = right_header_line(name, timestamp)
        helper = HeaderHelper.new(left_header, right_header, @names.count)
        result = template("html_header.erb").evaluate(helper)
        
        # create one opcode with the entire content
        opcodes = [
          [:equal, 0, sequence.length-1, 0, sequence.length-1]
        ]
        helper = HunkHelper.new(sequence, sequence, nil, opcodes, 0)
        result << template("html_hunk.erb").evaluate(helper)
        result
      end
      
      private
      def template(filename = "html.erb")
        @erbs[File.join(PatienceDiff::TEMPLATE_PATH, filename)]
      end
    end
  end
end
