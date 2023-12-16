# Represents an interval
#
# To create an Interval:
# ```
# # Ascending Major 3rd
# Interval.new("M3")
#
# # Descending intervals have a negative value
# # Descending Perfect 5th
# Interval.new("P-5")
# ```
# Available qualities are:
# M (major), m (minor), P (perfect), d (diminished), A (augmented).
# Going further is also possible, for example dd (doubly diminished) and AAA (triply augmented)
class Mystic::Interval
  getter quality : String
  getter value : Int32

  BASE_SEMITONES           = [0, 2, 3, 5, 7, 8, 10]
  QUALITY_SEMITONE_OFFSETS = {
    P: 0,

    m: 0, # imperfect intervals use m as base offset
    M: 1,

    A: 1,
    d: -1,
  }

  INTERVAL_COORDS = {
    "1": Coords.new(0, 0),
    "2": Coords.new(3, -5),
    "3": Coords.new(2, -3),
    "4": Coords.new(1, -1),
    "5": Coords.new(0, 1),
    "6": Coords.new(3, -4),
    "7": Coords.new(2, -2),
    "8": Coords.new(1, 0),
  }

  SHARP_COORDS = Coords.new(-4, 7)

  protected def initialize(@quality, @value)
  end

  def initialize(s : String)
    pattern = (
      "^" \
      "([PmM]|[Ad]+)" \
      "(-?\\d+)" \
      "$"
    )
    match = %r{#{pattern}}.match(s)

    raise Error.new("Invalid interval format: #{s}") unless match

    quality = match[1]
    value = match[2].to_i
    initialize(quality, value)
  end

  def self.from_coords(coords : Coords) : Interval
    fifths, value = coords.fifths, coords.value

    # 6th fifth away begins the first altered interval (augmented 4th)
    alterations = (fifths.abs + 1).tdiv(7)

    direction = value >= 0 ? 1 : -1

    # If unison, use ascending direction if non-negative fifths
    fifths_direction = fifths >= 0 ? 1 : -1
    direction = fifths_direction if value == 0

    # Check if perfect interval
    simple_value = (value.abs % 7) + 1
    is_perfect = Util.perfect?(simple_value)

    # Use increasing alteration if:
    # 1) ascending fifths (sharps) and ascending interval, or
    # 2) descending fifths (flats) and descending interval
    alteration_increasing = direction.positive? == fifths.positive?

    # For imperfect intervals, increase by 1 since we consider m/M as a -1/1 offset
    alterations += 1 if !is_perfect
    offset = alteration_increasing ? alterations : -1 * alterations

    quality = Util.offset_to_quality(offset, is_perfect: is_perfect)

    Interval.new(quality, value + direction)
  end

  # Returns `Coords` representation
  def coords : Coords
    octave_offset = Coords.new(octaves, 0)

    base_coords = INTERVAL_COORDS[simple.number.to_s]
    (base_coords + (SHARP_COORDS * quality_offset) + octave_offset) * direction
  end

  # Returns the (positive) number
  def number : Int32
    value.abs
  end

  # Returns 1 if ascending and -1 if descending
  def direction : Int32
    value >= 0 ? 1 : -1
  end

  # Returns if simple (an octave or smaller)
  def simple? : Bool
    number <= 8
  end

  # Returns if compound (greater than an octave)
  def compound? : Bool
    !simple?
  end

  # Returns number of octaves above the simple interval
  # Note: an octave is considered a simple interval
  def octaves : Int32
    (number - 2).tdiv(7)
  end

  # Returns the simple form
  def simple : Interval
    return self if simple?

    simple_number = ((number - 1) % 7) + 1
    # Simplify to octave instead of unison
    simple_number = 8 if simple_number == 1

    simple_value = direction * simple_number

    Interval.new(quality, simple_value)
  end

  # Returns the same interval going in the opposite direction
  def reverse : Interval
    Interval.new(quality, -1 * value)
  end

  # Returns the inversion
  # If compound, returns the inversion of the simple form
  def invert : self
    new_value = 9 - simple.number

    new_quality =
      case quality
      when "P"             then "P"
      when "m"             then "M"
      when "M"             then "m"
      when .includes?("A") then "d" * quality.size
      when .includes?("d") then "A" * quality.size
      else
        raise Error.new("Cannot invert unknown quality: #{quality}")
      end

    Interval.new(new_quality, direction * new_value)
  end

  # Returns the accidental offset based on the quality
  def quality_offset : Int32
    # If augmented and imperfect interval (e.g. A6),
    # raise 2 semitones above base (since we use minor as a base)
    number_perfect = Util.perfect?(simple.number)
    augmented_imperfect_offset = !number_perfect && quality.includes?("A") ? 1 : 0

    augmented_imperfect_offset + quality.chars.sum { |c| QUALITY_SEMITONE_OFFSETS[c.to_s] }
  end

  # Returns the number of semitones the interval spans
  def semitones : Int32
    base_semitone = BASE_SEMITONES[simple.number - 1]

    absolute_semitones = (octaves * 12) + (base_semitone + quality_offset)
    direction * absolute_semitones
  end

  def +(other : self) : Interval
    Interval.from_coords(coords + other.coords)
  end

  def -(other : self) : Interval
    self + other.reverse
  end

  # Adding intervals to notes is defined in the Note class
  def +(note : Note) : Note
    note + self
  end

  # Note: this compares intervals as ordered on a staff rather than by pitch.
  # For example, an A2 < d3 even though an A2 spans more semitones
  # Also note: this compares magnitude only, so direction is not taken into account
  def <=>(other : self) : Int32
    return number.<=>(other.number) if number != other.number

    quality_offset.<=>(other.quality_offset)
  end

  def <(other : self) : Bool
    self.<=>(other) == -1
  end

  def >(other : self) : Bool
    self.<=>(other) == 1
  end

  def ==(other : self) : Bool
    quality == other.quality && value == other.value
  end

  def to_s(io : IO)
    io << "#{quality}#{value}"
  end
end
