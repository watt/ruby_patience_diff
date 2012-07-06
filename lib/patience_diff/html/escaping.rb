require 'cgi'

module PatienceDiff
  module Html
    module Escaping
      # Escapes text for HTML output
      def escape(raw)
        CGI::escape_html(raw)
      end
    end
  end
end
