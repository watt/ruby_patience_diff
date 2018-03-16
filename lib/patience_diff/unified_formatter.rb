# frozen_string_literal: true

module PatienceDiff
  # Formats a plaintext unified diff.
  class UnifiedFormatter
    # Yields the formatted diff one line at a time. If a block is not provided,
    # returns an array of all lines instead.
    def format(a:, b:, hunks:, **metadata)
      return to_enum(:format, a: a, b: b, hunks: hunks, **metadata).to_a unless block_given?

      render_header(metadata) { |line| yield line }
      hunks.each do |opcodes|
        render_hunk(a: a, b: b, opcodes: opcodes) { |line| yield line }
      end
    end

    private

    def render_header(a_name: 'Original', b_name: 'Current', a_timestamp: Time.now, b_timestamp: Time.now)
      yield a_header_line(name: a_name, timestamp: a_timestamp)
      yield b_header_line(name: b_name, timestamp: b_timestamp)
    end

    def render_hunk(a:, b:, opcodes:)
      yield hunk_marker(opcodes: opcodes)
      lines = opcodes.map do |(code, a_start, a_end, b_start, b_end)|
        case code
        when :equal
          b[b_start..b_end].map { |line| ' ' + line }
        when :delete
          a[a_start..a_end].map { |line| '-' + line }
        when :insert
          b[b_start..b_end].map { |line| '+' + line }
        end
      end
      lines.each { |line| yield line }
    end

    def hunk_marker(opcodes:)
      a_start = opcodes.first[1] + 1
      a_end = opcodes.last[2] + 2
      b_start = opcodes.first[3] + 1
      b_end = opcodes.last[4] + 2

      sprintf('@@ -%d,%d +%d,%d @@', a_start, a_end - a_start, b_start, b_end - b_start)
    end

    def a_header_line(name:, timestamp:)
      sprintf("--- %s\t%s", name, timestamp.strftime('%Y-%m-%d %H:%m:%S.%N %z'))
    end

    def b_header_line(name:, timestamp:)
      sprintf("+++ %s\t%s", name, timestamp.strftime('%Y-%m-%d %H:%m:%S.%N %z'))
    end
  end
end
