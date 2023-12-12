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

  def quality
    intervals_string = intervals.map(&.to_s)
    (INTERVAL_QUALITIES[intervals_string]? || "unknown").to_s
  end

  def bass
    notes.first
  end

  def inversion
    root_position.notes.index(bass)
  end

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

  def invert(num : Int32, keep_root = true)
    num.times.reduce(self) { |chord, _| chord.invert(keep_root: keep_root) }
  end

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

  def get(interval_from_root : Interval)
    if !intervals.includes?(interval_from_root)
      raise Error.new("Interval #{interval_from_root} not in chord")
    end

    note_name = (root + interval_from_root).name
    notes.find { |n| n.name == note_name }
  end

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
