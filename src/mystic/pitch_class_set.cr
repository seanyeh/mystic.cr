# Represents a pitch class set in Set Theory
#
# To create a PitchClass:
#
# ```
# # C, E, G
# PitchClass.new([PitchClass.new(0), PitchClass.new(4), PitchClass.new(7)])
#
# # Shorthand
# PitchClass.new([0, 4, 7])
#
# # Can create from a chord
# Chord.new("C").pitch_class_set
# ```
class Mystic::PitchClassSet
  getter pitch_classes : Array(PitchClass)

  def initialize(@pitch_classes)
    @pitch_classes = pitch_classes.uniq
  end

  def initialize(pitch_class_nums : Array(Int32))
    pcs = pitch_class_nums.map { |i| PitchClass.new(i) }
    initialize(pcs)
  end

  # Returns the pitch class set (in prime form) given the Forte number
  def self.from_forte_number(s : String) : PitchClassSet
    pc_set = ForteNumbers::FORTE_TABLE[s]?

    raise Error.new("Invalid forte number: #{s}") unless pc_set

    PitchClassSet.new(pc_set)
  end

  # Returns the pitch classes as an array of ints
  def pitch_class_values : Array(Int32)
    pitch_classes.map(&.value)
  end

  # Returns the normal form.
  #
  # The normal form is the most compact form of a pitch class set
  def normal_form : PitchClassSet
    sorted_pitch_classes = pitch_classes.sort

    pc_sets = size.times.map do |i|
      PitchClassSet.new(sorted_pitch_classes[i..] + sorted_pitch_classes.first(i))
    end.to_a

    pc_sets.sort.first
  end

  # Returns the prime form.
  #
  # The prime form is calculated by:
  # 1. Finding the more compact version of either the normal form or inverted normal form
  # 2. Transposing it to start from 0
  def prime_form : PitchClassSet
    inverted = invert(first)
    pc_set = [normal_form, inverted.normal_form].sort.first

    # Transpose to 0
    pc_set.transpose_to(0)
  end

  # Returns the inversion around the given *axis*
  def invert(axis : PitchClass) : PitchClassSet
    new_pcs = pitch_classes.map do |pc|
      axis - (pc - axis)
    end

    PitchClassSet.new(new_pcs)
  end

  # Returns the inversion around the given *axis* (defaulting to 0)
  def invert(axis : Int32 = 0) : PitchClassSet
    invert(PitchClass.new(axis))
  end

  # The interval vector (also known as Interval Class Content) shows
  # which interval classes (with quantities) exist between all pairs of notes.
  #
  # Returns an array of 6 ints, denoting how many of each interval class (ic) exist.
  #
  # For example: an interval vector of [0, 0, 2, 0, 0, 1] means the following:
  # 1. 2 instances of interval class 3
  # 2. 1 instance of interval class 6
  def interval_vector : Array(Int32)
    # Get all pairs of pitch classes
    pairs = pitch_classes.map_with_index do |pc1, index|
      pitch_classes[index + 1...].map { |pc2| {pc1, pc2} }
    end.flatten

    # Create interval vector by aggregating number of each interval class
    pairs.reduce([0, 0, 0, 0, 0, 0]) do |acc, pair|
      pc1, pc2 = pair

      # Subtract 1 because interval classes are 1..6
      index = pc1.ic_distance(pc2) - 1
      acc[index] += 1

      acc
    end
  end

  def forte_number : String
    pc_set = normal_form.transpose_to(0)
    ForteNumbers::PRIME_TABLE.fetch(pc_set.pitch_class_values, "invalid")
  end

  # Returns the number of pitch classes
  def size : Int32
    pitch_classes.size
  end

  # Returns the first pitch class
  def first : PitchClass
    pitch_classes.first
  end

  # Returns the last pitch class
  def last : PitchClass
    pitch_classes.last
  end

  # Returns the pitch class set with pitch classes in ascending order
  def sort : PitchClassSet
    PitchClassSet.new(pitch_classes.sort)
  end

  # Transpose set to begin with given pitch class value
  def transpose_to(i : Int32)
    self + (i - first.value)
  end

  # Inversion + Transpose (TₙI or Iₙ)
  def ti(i : Int32) : PitchClassSet
    invert + i
  end

  # Transpose (Tₙ)
  def t(i : Int32) : PitchClassSet
    self + i
  end

  # :ditto:
  def +(i : Int32) : PitchClassSet
    PitchClassSet.new(pitch_classes.map { |pc| pc + i })
  end

  def -(i : Int32) : PitchClassSet
    self + -i
  end

  # Calculate outer distance and inner distances from the end (right-to-left)
  protected def sort_value
    outer_distance = last - first
    inner_distances = (size - 2).times.map do |i|
      # Get the 2nd to last, 3rd to last, etc.
      index = (size - 1) - i - 1

      last - pitch_classes[index]
    end.to_a

    {
      outer_distance:  outer_distance,
      inner_distances: inner_distances,
    }
  end

  # The more "compact" pitch class set is considered less than the other
  #
  # "Compactness" is determined by:
  # 1. Smallest outer distance
  # 2. If tie, rightmost largest inner distances
  # 3. If tie, the pitch class set beginning closest to 0
  def <=>(other : self) : Int32
    a, b = sort_value, other.sort_value

    # First, order by smallest outer distance
    return a[:outer_distance] <=> b[:outer_distance] if a[:outer_distance] != b[:outer_distance]

    # If tie, order by greatest inner distance from the end
    return b[:inner_distances] <=> a[:inner_distances] if a[:inner_distances] != b[:inner_distances]

    # Return pc set closest to 0 if all distances same
    first <=> other.first
  end

  def ==(other : self) : Bool
    pitch_classes == other.pitch_classes
  end

  def to_s(io : IO) : Nil
    io << pitch_class_values.to_s
  end
end
