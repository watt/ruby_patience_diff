module PatienceDiff
  class Card
    attr_accessor :previous, :index, :value
    def initialize(index, value)
      @index = index
      @value = value
    end
  end
end
