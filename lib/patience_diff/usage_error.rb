module PatienceDiff
  class UsageError
    def print_usage(out=$stderr)
      out.puts "Usage: #{$0} left-file right-file"
    end
  end
end
