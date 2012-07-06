require 'stringio'

module PatienceDiff
  # Delegate object yielded by the #format method.
  class FormattingContext
    attr_reader :names, :title
    
    def initialize(differ, title = nil)
      @differ = differ
      @names = []
      @out = StringIO.new
      @title = title || "Diff generated on #{Time.now.strftime('%c')}"
    end
    
    def files(left_file, right_file)
      @names << left_file
      @out.puts @differ.diff_files(left_file, right_file)
    end
    
    def sequences(left, right, left_name=nil, right_name=nil, left_timestamp=nil, right_timestamp=nil)
      @names << left_name
      @out.puts @differ.diff(left, right, left_name, right_name, left_timestamp, right_timestamp)
    end
    
    def format
      @out.string
    end
  end
end
