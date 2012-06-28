require 'patience_diff/sequence_matcher'
require 'patience_diff/usage_error'
require 'patience_diff/differs/unified'
PatienceDiff::Differs.autoload(:Html, 'patience_diff/differs/html')

module PatienceDiff
  VERSION = "1.0.1"
  TEMPLATE_PATH = File.expand_path(File.join(File.dirname(__FILE__),'..','templates'))
end
