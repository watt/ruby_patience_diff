# frozen_string_literal: true

require 'minitest/autorun'

require 'patience_diff'

module PatienceDiff
  class SequenceMatcherTest < Minitest::Test
    TEST_CASE_PATH = File.expand_path(File.join(__dir__, '..', 'cases'))

    def format_opcodes(a:, b:, opcodes:)
      lines = opcodes.flat_map do |(code, a_start, a_end, b_start, b_end)|
        case code
        when :equal
          b[b_start..b_end].map { |line| ' ' + line }
        when :delete
          a[a_start..a_end].map { |line| '-' + line }
        when :insert
          b[b_start..b_end].map { |line| '+' + line }
        end
      end
      lines.join($RS)
    end

    cases = Dir.glob("#{TEST_CASE_PATH}/*").select { |f| File.directory?(f) }

    cases.each do |case_dir|
      case_number = File.basename(case_dir)
      define_method("test_case_#{case_number}") do
        a = File.read(File.join(case_dir, 'a'), external_encoding: Encoding::BINARY).split($RS, -1)
        b = File.read(File.join(case_dir, 'b'), external_encoding: Encoding::BINARY).split($RS, -1)
        expected_diff = File.read(File.join(case_dir, 'diff'))

        opcodes = PatienceDiff::SequenceMatcher.new.diff_opcodes(a, b)
        actual_diff = format_opcodes(a: a, b: b, opcodes: opcodes)

        message = <<~EOF
          >>> expected:
          #{expected_diff}
          >>> actual:
          #{actual_diff}
          >>>
        EOF

        # Using `assert` rather than `assert_equal` to avoid generating a
        # diff-of-a-diff in failure messages.
        assert(expected_diff == actual_diff, message)
      end
    end
  end
end
