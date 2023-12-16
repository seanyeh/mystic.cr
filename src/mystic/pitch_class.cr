# Represents a pitch class in Set Theory
#
# To create a PitchClass:
#
# ```
# # C
# PitchClass.new(0)
# ```
struct Mystic::PitchClass
  getter value : Int32

  def initialize(@value)
    raise Error.new("Pitch class must be between 0 and 11 (inclusive)") unless 0 <= value <= 11
  end

  def +(i : Int32) : PitchClass
    PitchClass.new((value + i) % 12)
  end

  def -(i : Int32) : PitchClass
    self + -i
  end

  # Returns the numerical distance from the *other* pitch class
  def -(other : self) : Int32
    (value - other.value) % 12
  end

  # Returns the Interval Class distance from the *other* pitch class
  def ic_distance(other : self) : Int32
    distance = other - self

    distance > 6 ? 12 - distance : distance
  end

  def <=>(other : self) : Int32
    value <=> other.value
  end

  def ==(other : self) : Bool
    value == other.value
  end

  def to_s(io : IO) : Nil
    io << value.to_s
  end
end
