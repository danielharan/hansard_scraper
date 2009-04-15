class ArrayUtils
  class << self
    def firsts_in_sequence(elements)
      first = nil
      elements.select do |cur|
        ret = (cur != first)
        first = cur
        ret
      end
    end
  end
end