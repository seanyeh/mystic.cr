class Mystic::Scale
  getter tonic : Note
  getter type : String
  getter intervals : Array(Interval)

  private WS = Interval.new("M2")
  private HS = Interval.new("m2")

  SCALE_INTERVALS = {
    major:           [WS, WS, HS, WS, WS, WS],
    minor:           [WS, HS, WS, WS, HS, WS],
    "melodic minor": [WS, HS, WS, WS, WS, WS],
    dorian:          [WS, HS, WS, WS, WS, HS, WS],
    phrygian:        [HS, WS, WS, WS, HS, WS, WS],
    lydian:          [WS, WS, WS, HS, WS, WS, HS],
    mixolydian:      [WS, WS, HS, WS, WS, HS, WS],
    locrian:         [HS, WS, WS, HS, WS, WS, WS],
  }

  SCALE_ALIASES = {
    ionian:          "major",
    aeolian:         "minor",
    "natural minor": "minor",
  }

  def initialize(@tonic, @type, @intervals)
  end

  def initialize(@tonic, @type)
    key = SCALE_ALIASES.fetch(type, type)
    intervals = SCALE_INTERVALS[key]?

    raise Error.new("Invalid scale type: #{type}") if intervals.nil?

    initialize(tonic, type, intervals)
  end

  def initialize(tonic_type : String, @type)
    initialize(Note.new(tonic_type), type)
  end

  def notes
    intervals.reduce([tonic]) do |acc, interval|
      new_note = acc.last + interval
      acc.push(new_note)
    end
  end

  def name(include_octave = false)
    "#{include_octave ? tonic : tonic.letter} #{type}"
  end

  def to_s
    name(include_octave: true)
  end
end
