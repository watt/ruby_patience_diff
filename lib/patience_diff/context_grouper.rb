# frozen_string_literal: true

module PatienceDiff
  class ContextGrouper
    def initialize(context: 3, **)
      @context = context
    end

    # Takes an array of diff opcodes, and splits them into groups whenever an
    # :equal range is encountered that is longer than @context * 2.
    # Returns an array of arrays of 5-tuples as described for #diff_opcodes.
    def group(opcodes:)
      return [opcodes] if opcodes.length < 2

      groups = split_opcodes(opcodes: opcodes).slice_when do |elt_before, elt_after|
        elt_before[0] == :equal && elt_after[0] == :equal
      end

      groups.to_a
    end

    private

    def split_opcodes(opcodes:)
      return to_enum(:split_opcodes, opcodes: opcodes) unless block_given?

      # Handle the first and last opcodes separately.
      first = opcodes.first
      middle = (1...(opcodes.size - 1)).lazy.map { |i| opcodes[i] }
      last = opcodes.last

      yield first[0] == :equal ? split_range(opcode: first, threshold: @context).last : first

      middle_threshold = @context * 2
      middle.each do |opcode|
        if opcode[0] == :equal
          split_range(opcode: opcode, threshold: middle_threshold).each { |piece| yield piece }
        else
          yield opcode
        end
      end

      yield last[0] == :equal ? split_range(opcode: last, threshold: @context).first : last
    end

    def split_range(opcode:, threshold:)
      code, a_start, a_end, b_start, b_end = *opcode
      if (b_end - b_start + 1) > threshold
        [
          [
            code,
            a_start,
            a_start + @context - 1,
            b_start,
            b_start + @context - 1
          ],
          [
            code,
            a_end - @context + 1,
            a_end,
            b_end - @context + 1,
            b_end
          ]
        ]
      else
        [opcode]
      end
    end
  end
end
