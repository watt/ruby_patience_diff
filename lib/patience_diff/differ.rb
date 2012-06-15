require 'patience_diff/card'

module PatienceDiff
  class Differ
    attr_accessor :context
    
    def initialize(opts = {})
      @context = opts[:context] || 3
    end
    
    def unified_diff(a, b)
      lines = []
      diff_opcodes(a, b).each do |(code, left_start, left_end, right_start, right_end)|
        case code
        when :equal
          b[right_start..right_end].map { |line| ' ' + line }
        when :delete
          a[left_start..left_end].map { |line| '-' + line }
        when :insert
          b[right_start..right_end].map { |line| '+' + line }
        end.tap do |opcode_lines|
          lines.concat opcode_lines
        end
      end
      lines
    end
  
    def diff_opcodes(a, b)
      common = []
      recurse_matches(a, b, 0, 0, a.length, b.length, common)
      left_pos = right_pos = 0
      opcodes = []
      sequences = collapse_sequences(common)
      sequences << [a.length, b.length, 0]
  
      sequences.each do |(i, j, len)|
        if left_pos < i
          opcodes << [:delete, left_pos, i-1, right_pos, right_pos]
        end
        if right_pos < j
          opcodes << [:insert, left_pos, left_pos, right_pos, j-1]
        end
        if len > 0
          opcodes << [:equal, i, i+len-1, j, j+len-1]
        end
        left_pos = i+len
        right_pos = j+len
      end
      puts "opcodes:"
      print_tuples(opcodes)
      opcodes
    end
      
    private
    def print_tuples(array)
      puts(array.map do |tuple|
        "[#{tuple.join(", ")}]"
      end.join(", "))
    end

    def recurse_matches(a, b, a_lo, b_lo, a_hi, b_hi, answer = [])
      return if a_lo == a_hi or b_lo == b_hi
      old_answer_length = answer.length
      last_a_pos = a_lo - 1
      last_b_pos = b_lo - 1
      
      longest_unique_subsequence(a[a_lo...a_hi], b[b_lo...b_hi]).each do |(a_pos, b_pos)|
        # recurse betwen unique lines
        a_pos += a_lo
        b_pos += b_lo
        if (last_a_pos+1 != a_pos) or (last_b_pos+1 != b_pos)
          recurse_matches(a, b, last_a_pos+1, last_b_pos+1, a_pos, b_pos, answer)
        end
        last_a_pos = a_pos
        last_b_pos = b_pos
        answer << [a_pos, b_pos]
      end
      
      if answer.length > old_answer_length
        # there was at least one match
        # recurse between last match and end
        recurse_matches(a, b, last_a_pos+1, last_b_pos+1, a_hi, b_hi, answer)
      elsif a[a_lo] == b[b_lo]
        # no unique lines
        # diff forward from beginning
        while a_lo < a_hi and b_lo < b_hi and a[a_lo] == b[b_lo]
          answer << [a_lo, b_lo]
          a_lo += 1
          b_lo += 1
        end
        recurse_matches(a, b, a_lo, b_lo, a_hi, b_hi, answer)
      elsif a[a_hi-1] == b[b_hi-1]
        # no unique lines
        # diff back from end
        a_mid = a_hi - 1
        b_mid = b_hi - 1
        while a_mid > a_lo and b_mid > b_lo and a[a_mid-1] == b[b_mid-1]
          a_mid -= 1
          b_mid -= 1
        end
        puts "last_a_pos doesn't match a_lo-1" if last_a_pos != a_lo-1
        puts "last_b_pos doesn't match b_lo-1" if last_b_pos != b_lo-1
        recurse_matches(a, b, a_lo, b_lo, a_mid, b_mid, answer)
        0...(a_hi-a_mid).each do |i|
          answer << [a_mid+i, b_mid+i]
        end
      end
    end
    
    def collapse_sequences(matches)
      return matches if matches.empty?
      answer = []
      start_a, start_b = *(matches.first)
      len = 1
      matches[1..-1].each do |(i_a, i_b)|
        if i_a == start_a + len and i_b == start_b + len
          len += 1
        else
          answer << [start_a, start_b, len]
          start_a = i_a
          start_b = i_b
          len = 1
        end
      end
      answer << [start_a, start_b, len]
      answer
    end
  
    def longest_unique_subsequence(a, b)
      deck = Array.new(b.length)
      unique_a = {}
      unique_b = {}
      
      a.each_with_index do |val, index|
        if unique_a.has_key? val
          unique_a[val] = nil
        else
          unique_a[val] = index
        end
      end
      
      b.each_with_index do |val, index|
        a_index = unique_a[val]
        next unless a_index
        dupe_index = unique_b[val]
        if dupe_index
          deck[dupe_index] = nil
          unique_a.delete(val)
        else
          unique_b[val] = index
          deck[index] = a_index
        end
      end
      
      longest_increasing_subsequence(deck)
    end
  
    def longest_increasing_subsequence(deck)
      card = patience_sort(deck).last
      result = []
      while card
        result.unshift [card.value, card.index]
        card = card.previous
      end
      result
    end
  
    def patience_sort(deck)
      piles = []
      pile = 0
      deck.each_with_index do |card_value, index|
        next if card_value.nil?
        card = Card.new(index, card_value)
        
        if piles.any? and piles.last.value < card_value
          pile = piles.size
        elsif piles.any? and piles[pile].value < card_value and 
              (pile == piles.size-1 or piles[pile+1].value > card_value)
          pile += 1
        else
          pile = bisect(piles, card_value)
        end
        
        card.previous = piles[pile-1] if pile > 0
        
        if pile < piles.size
          #puts "putting card #{card.value} on pile #{pile}"
          piles[pile] = card
        else
          #puts "putting card #{card.value} on new pile"
          piles << card
        end
      end
      
      piles
    end
    
    def bisect(piles, target, low=0, high=nil)
      high = piles.size-1 unless high
      while (low <= high)
        mid = (low + high)/2
        if piles[mid].value < target
          low = mid + 1
        else
          high = mid - 1
        end
      end
      low
    end
  end
end
