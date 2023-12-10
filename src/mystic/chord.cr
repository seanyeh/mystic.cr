# Represents a chord
# A chord has a root note, intervals (indicating the intervals above the root in root position),
# and an array of notes
#
# Some ways to create a Chord:
# ```
# # Create with root note and quality
# Chord.new(Note.new("C4"), "major")
#
# # Create a chord with notes. The lowest will be assumed to be the root
# # (C major)
# Chord.new([Note.new("C4"), Note.new("E4"), Note.new("G4")])
#
# # Create with root note and notes
# # (C major, 1st inversion)
# Chord.new(Note.new("C4"), [Note.new("E4"), Note.new("G4"), Note.new("C5")])
#
# # Create chord with custom intervals
# Chord.new(Note.new("C4"), [Interval.new("M2"), Interval.new("P5")])
#
# # Shorthand with chord symbols
# Chord.new("CMb9#11")
# ```
class Mystic::Chord
  getter root : Note
  getter intervals : Array(Interval)
  getter notes : Array(Note)

  private OCTAVE = Interval.new("P8")

  QUALITY_INTERVALS = {
    major:                      ["M3", "P5"],
    minor:                      ["m3", "P5"],
    diminished:                 ["m3", "d5"],
    augmented:                  ["M3", "A5"],
    "major seventh":            ["M3", "P5", "M7"],
    "dominant seventh":         ["M3", "P5", "m7"],
    "minor seventh":            ["m3", "P5", "m7"],
    "minor major seventh":      ["m3", "P5", "M7"],
    "half diminished seventh":  ["m3", "d5", "m7"],
    "fully diminished seventh": ["m3", "d5", "d7"],
    "augmented seventh":        ["M3", "A5", "m7"],
    "augmented major seventh":  ["M3", "A5", "M7"],
    mystic:                     ["A4", "m7", "M10", "M13", "M16"],
  }

  INTERVAL_QUALITIES = QUALITY_INTERVALS.to_h.invert

  ALIASES = {
    dominant:                     "dominant seventh",
    diminished:                   "fully diminished",
    "augmented dominant seventh": "augmented seventh",
  }

  def initialize(@root, intervals : Array(Interval), notes : Array(Note) | Nil = nil)
    @intervals = intervals.sort
    @notes = (notes || [root] + intervals.map { |interval| root + interval }).sort
  end

  def initialize(notes : Array(Note))
    notes = notes.sort
    initialize(notes.first, notes)
  end

  def initialize(@root, @notes : Array(Note))
    # TODO: improve algorithm - adjust octave of notes to be closest to (but higher than) root
    @intervals = notes.sort.compact_map { |n| n.name == root.name ? nil : n - root }
  end

  def initialize(@root, quality : String, notes : Array(Note) | Nil = nil)
    quality_key = ALIASES[quality]? ? ALIASES[quality] : quality

    if (chord_definition = QUALITY_INTERVALS[quality_key]?)
      intervals = chord_definition.map { |s| Interval.new(s) }
      initialize(root, intervals, notes: notes)
    else
      raise Error.new("Unknown quality: \"#{quality}\"")
    end
  end

  def self.new(s : String)
    ChordParser.parse(s)
  end

  # Returns the chord quality
  def quality
    intervals_string = intervals.map(&.to_s)
    (INTERVAL_QUALITIES[intervals_string]? || "unknown").to_s
  end

  # Returns the lowest note
  def bass
    notes.first
  end

  # Returns the inversion number, or 0 if in root position
  def inversion
    root_position.notes.index(bass)
  end

  # Returns the result of inverting the chord once (upwards).
  # If *keep_root* is true, will maintain the same root note if inverted back to root position.
  # This will result in all the notes shifting down some number of octave(s).
  # Otherwise, the resulting chord will have a higher root note if inverted back to root position
  def invert(keep_root = true)
    new_notes = notes.dup
    old_bass = new_notes.shift

    # Move previous bass note up by octaves until no longer lowest
    while old_bass < new_notes.first
      old_bass += OCTAVE
    end

    new_notes.push(old_bass)

    new_root = root
    new_bass = new_notes.first
    # Adjust either notes or root if new bass is the same note as root but higher octave
    if new_bass.name == root.name && new_bass > new_root
      if keep_root
        # Shift down all notes so that the new bass = root
        offset = new_bass - new_root
        new_notes = new_notes.map { |n| n - offset }
      else
        new_root = new_bass.dup
      end
    end

    Chord.new(new_root, notes: new_notes, intervals: intervals)
  end

  # Returns the result of inverting the chord *num* times (upwards)
  def invert(num : Int32, keep_root = true)
    num.times.reduce(self) { |chord, _| chord.invert(keep_root: keep_root) }
  end

  # Returns the root position of the chord
  def root_position
    notes = [root] + intervals.map { |interval| root + interval }
    Chord.new(root, intervals: intervals, notes: notes)
  end

  def name
    "#{root.name} #{quality}"
  end

  def note_names
    notes.map(&.name)
  end

  # Return the member of the chord given a specific *interval_from_root*
  # This is a more specific version of Chord#get(member).
  # This is useful if a chord has multiple notes with the same member number.
  #
  # For example:
  # ```
  # # Split 3rd chord (has 2 "3rds")
  # chord = Chord.new([Note.new("C4"), Note.new("Eb4"), Note.new("E4"), Note.new("G4")])
  # chord.get(Interval.new("M3")) # => Note.new("E4")
  # ```
  def get(interval_from_root : Interval)
    if !intervals.includes?(interval_from_root)
      raise Error.new("Interval #{interval_from_root} not in chord")
    end

    note_name = (root + interval_from_root).name
    notes.find { |n| n.name == note_name }
  end

  # Return the given *member*
  # For example, chord.get(3) will return the 3rd of the chord
  def get(member : Int32)
    intervals_from_root = intervals.select { |interval| interval.value == member }

    raise Error.new("Chord member #{member} not in chord") if intervals_from_root.empty?

    get(intervals_from_root.first)
  end

  def +(interval : Interval)
    new_notes = notes.map { |n| n + interval }
    new_root = root + interval

    Chord.new(new_root, intervals: intervals, notes: new_notes)
  end

  def ==(other : Chord)
    root = other.root && intervals == other.intervals && notes == other.notes
  end
end
