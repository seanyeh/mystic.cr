# Miscellaneous utility methods
class Mystic::Util
  PERFECT_INTERVALS = [1, 4, 5, 8]

  ACCIDENTAL_OFFSETS = {
    "#": 1,
    "x": 2,
    "b": -1,

    # Accept some unicode characters
    "♯": 1,
    "♭": -1,
    "𝄫": -2,
    "𝄪": 2,
  }

  # Return if given *number* is a perfect interval
  def self.perfect?(number : Int32) : Bool
    PERFECT_INTERVALS.includes?(number.abs % 7)
  end

  # Return a quality corresponding to the *offset* (number of alterations) and whether it *is_perfect*
  def self.offset_to_quality(offset : Int32, is_perfect : Bool) : String
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

  # Return the proper accidental given a numerical *accidental_offset*
  def self.normalize_accidental(accidental_offset : Int32) : String
    case accidental_offset
    when .negative? then "b" * accidental_offset.abs
    when 1          then "#"
    when 2          then "x"
    when 3          then "#x"
    else
      # No standard way to denote > 3 sharps
      "#" * accidental_offset
    end
  end

  # Return the number of alterations given an *accidental*
  def self.accidental_offset(accidental : String) : Int32
    accidental.chars.sum { |c| ACCIDENTAL_OFFSETS.fetch(c.to_s, 0) }
  end
end
