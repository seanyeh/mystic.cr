struct Mystic::Coords
  getter octaves, fifths

  def initialize(@octaves : Int32, @fifths : Int32)
  end

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
