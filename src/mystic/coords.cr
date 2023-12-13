# Coordinate representation of pitches
#
# Pitches are represented by a combination of octaves and fifths away from Middle C
#
# For example, the C#4 is represented as (-4, 7), and Db4 is (3, -5).
#
# The benefit of this approach over a semitone-based system is that it is easier to
# keep track of enharmonic notes, and it also makes interval math much simpler.
struct Mystic::Coords
  getter octaves, fifths

  def initialize(@octaves : Int32, @fifths : Int32)
  end

  # Returns the pitch offset from Middle C and can be used to calculate the pitch name
  def value
    (7 * octaves) + (4 * fifths)
  end

  def +(other : Coords)
    Coords.new(octaves + other.octaves, fifths + other.fifths)
  end

  def -(other : Coords)
    self + (other * -1)
  end

  def *(i : Int32)
    Coords.new(octaves * i, fifths * i)
  end

  def to_s(io : IO)
    io << "[#{octaves}, #{fifths}]"
  end

  def ==(other : Coords)
    octaves == other.octaves && fifths == other.fifths
  end
end
