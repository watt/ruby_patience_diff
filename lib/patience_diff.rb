require 'patience_diff/differ'
require 'patience_diff/formatter'
require 'patience_diff/formatting_context'
require 'patience_diff/sequence_matcher'
require 'patience_diff/usage_error'
PatienceDiff.autoload(:Html, 'patience_diff/html/formatter')

module PatienceDiff
  VERSION = "1.0.1"
  TEMPLATE_PATH = File.expand_path(File.join(File.dirname(__FILE__),'..','templates'))
end
