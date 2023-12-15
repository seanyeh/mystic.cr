# mystic.cr

![CI](https://github.com/seanyeh/mystic.cr/actions/workflows/ci.yml/badge.svg)

Mystic is a music theory library for Crystal, featuring methods for working with notes, intervals, scales, chords, and more.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     mystic:
       github: seanyeh/mystic.cr
   ```

2. Run `shards install`

## Usage

Here is some sample code showing what you can do with mystic. Check out the [docs](https://seanyeh.github.io/mystic.cr/) for a complete API reference.
```crystal
require "mystic"

# Notes
g5 = Mystic::Note.new("g5")
c4 = Mystic::Note.new("C") # default octave is 4

# Intervals
p12 = g5 - c4 # Interval of a Perfect 12th
p5 = p12.simple # Interval of a Perfect 5th
p4 = p5.invert # => Interval of a Perfect 4th

i = Interval.new("m-2") # Descending minor 2nd
a4 = p5 + i # Interval of an Augmented 4th

# Scales
g_lydian = Mystic::Scale.new(g5, "lydian")
g_lydian.note_names
# => ["G", "A", "B", "C#", "D", "E", "F#"]

a_lydian = scale + Mystic::Interval.new("M2") # Transpose up a M2

# Chords
eb4 = Mystic::Note.new("Eb")
g4 = Mystic::Note.new("G")
cm = Mystic::Chord.new([c4, eb4, g4])

cm.quality # => "minor"
cm == Mystic::Chord.new(c4, "minor") # => true
cm.get(3) # Gets the 3rd of the chord (Note object Eb4)

cm.invert.notes
# => Note objects Eb4, G4, C5

Mystic::Chord.new("Cmb9#11").note_names
# => ["C", "Eb", "G", "Bb", "Db", "F#"]

Mystic::Chord.new(c4, "mystic").note_names
# => ["C", "F#", "Bb", "E", "A", "D"]
```

## Contributing

1. Fork it (<https://github.com/seanyeh/mystic.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Sean Yeh](https://github.com/seanyeh) - creator and maintainer
