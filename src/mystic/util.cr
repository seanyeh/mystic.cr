class Mystic::Util
  PERFECT_INTERVALS = [1, 4, 5, 8]

  def self.perfect?(number)
    PERFECT_INTERVALS.includes?(number.abs % 7)
  end

  def self.offset_to_quality(offset : Int32, is_perfect : Bool)
    if offset == 0
      raise "Cannot determine quality with 0 offset for imperfect interval" if !is_perfect

      "P"
    elsif offset < 0
      return "d" * offset.abs if is_perfect

      offset == -1 ? "m" : "d" * (offset.abs - 1)
    else
      return "A" * offset if is_perfect

      offset == 1 ? "M" : "A" * (offset - 1)
    end
  end
end
