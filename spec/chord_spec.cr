require "./spec_helper"

module Mystic
  describe Chord do
    root = Note.new("C4")

    root_position_chord = Chord.new(Note.new("C4"), "major")
    first_inversion_chord =
      Chord.new(Note.new("C4"), "major", notes: [Note.new("E4"), Note.new("G4"), Note.new("C5")])
    second_inversion_chord =
      Chord.new(Note.new("C4"), "major", notes: [Note.new("G4"), Note.new("C5"), Note.new("E5")])
    mystic_chord = Chord.new(Note.new("C4"), "mystic")

    custom_intervals = [Interval.new("M2"), Interval.new("P5")]
    custom_notes = [Note.new("C4"), Note.new("D4"), Note.new("G4")]

    describe "initialize" do
      it "returns the correct chord when given intervals" do
        c = Chord.new(root, intervals: custom_intervals)

        c.root.should eq(root)
        c.intervals.should eq(custom_intervals)
        c.notes.should eq(custom_notes)
      end

      it "returns the correct chord when given intervals and notes" do
        notes = [Note.new("D4"), Note.new("G4"), Note.new("C5")]
        c = Chord.new(root, intervals: custom_intervals, notes: notes)

        c.root.should eq(root)
        c.intervals.should eq(custom_intervals)
        c.notes.should eq(notes)
      end

      it "returns the correct chord when given notes" do
        c = Chord.new(custom_notes)

        c.root.should eq(root)
        c.intervals.should eq(custom_intervals)
        c.notes.should eq(custom_notes)
      end

      it "returns the correct chord when given a root and notes" do
        c = Chord.new(root, notes: custom_notes)

        c.root.should eq(root)
        c.intervals.should eq(custom_intervals)
        c.notes.should eq(custom_notes)
      end

      it "returns the correct chord when given root and quality" do
        c = Chord.new(root, quality: "minor")

        c.root.should eq(root)
        c.intervals.should eq([Interval.new("m3"), Interval.new("P5")])
        c.notes.should eq([Note.new("C4"), Note.new("Eb4"), Note.new("G4")])
      end

      it "returns the correct chord when given root, quality, and notes" do
        notes = [Note.new("Eb4"), Note.new("G4"), Note.new("C5")]
        c = Chord.new(root, quality: "minor", notes: notes)

        c.root.should eq(root)
        c.intervals.should eq([Interval.new("m3"), Interval.new("P5")])
        c.notes.should eq(notes)
      end

      it "returns the correct chord when given chord symbols" do
        c = Chord.new("C#Maj7#9")

        c.root.should eq(Note.new("C#4"))
        c.intervals.should eq([
          Interval.new("M3"),
          Interval.new("P5"),
          Interval.new("M7"),
          Interval.new("M9"),
        ])
        c.notes.should eq([
          Note.new("C#4"),
          Note.new("E#4"),
          Note.new("G#4"),
          Note.new("B#4"),
          Note.new("D#5"),
        ])
      end
    end

    describe "#quality" do
      it "returns the quality" do
        mystic_chord.quality.should eq("mystic")
      end

      it "returns \"unknown\" when the quality is unknown" do
        c = Chord.new(root, intervals: custom_intervals)
        c.quality.should eq("unknown")
      end
    end

    describe "#bass" do
      it "returns the first (lowest) note" do
        first_inversion_chord.bass.should eq(Note.new("E4"))
      end
    end

    describe "#inversion" do
      it "returns the correct inversion" do
        first_inversion_chord.inversion.should eq(1)
      end

      it "returns 0 if in root position" do
        root_position_chord.inversion.should eq(0)
      end
    end

    describe "#invert" do
      it "returns the correct inverted chord" do
        root_position_chord.invert.should eq(first_inversion_chord)
      end

      it "returns the correct result when inverting a chord with a large span" do
        expected = [
          Note.new("F#4"),
          Note.new("Bb4"),
          Note.new("C5"),
          Note.new("E5"),
          Note.new("A5"),
          Note.new("D6"),
        ]

        mystic_chord.invert.notes.should eq(expected)
      end

      it "returns root position chord if inversion cycles" do
        second_inversion_chord.invert.should eq(root_position_chord)
      end

      it "returns a chord with an adjusted root if specified" do
        expected = root_position_chord + Interval.new("P8")
        second_inversion_chord.invert(keep_root: false).should eq(expected)
      end

      it "returns the correct chord when inverting multiple times" do
        root_position_chord.invert(2).should eq(second_inversion_chord)
      end
    end

    describe "#root_position" do
      it "returns the correct root position chord" do
        first_inversion_chord.root_position.should eq(root_position_chord)
      end

      it "returns itself if already in root position" do
        root_position_chord.root_position.should eq(root_position_chord)
      end
    end

    # describe "#name" do
    #   it "returns the correct name" do
    #     mystic_chord.name.should eq("C mystic")
    #   end
    # end

    describe "#note_names" do
      it "returns the correct note names" do
        mystic_chord.note_names.should eq(["C", "F#", "Bb", "E", "A", "D"])
      end
    end

    describe "#get" do
      it "returns the correct member when an interval is given" do
        first_inversion_chord.get(Interval.new("P5")).should eq(Note.new("G4"))
      end

      it "raises an error if interval does not exist" do
        expect_raises(Error, "Interval A5 not in chord") do
          first_inversion_chord.get(Interval.new("A5"))
        end
      end

      it "returns the correct member when numerical chord member given" do
        first_inversion_chord.get(3).should eq(Note.new("E4"))
      end

      it "raises an error if member does not exist" do
        expect_raises(Error, "Chord member 4 not in chord") do
          first_inversion_chord.get(4).should eq(Note.new("E4"))
        end
      end
    end

    describe "#+" do
      it "returns true if same" do
        c = root_position_chord + Interval.new("M2")

        c.root.should eq(Note.new("D4"))
        # c.quality.should eq("major")
        c.intervals.should eq([Interval.new("M3"), Interval.new("P5")])
        c.notes.should eq([Note.new("D4"), Note.new("F#4"), Note.new("A4")])
      end
    end

    describe "#==" do
      it "returns true if same" do
        c1 = Chord.new(root, "major")
        c2 = Chord.new(root, "major")

        (c1 == c2).should be_true
      end

      it "returns false if not the same" do
        c1 = Chord.new(root, "major")
        c2 = Chord.new(root, "minor")

        (c1 == c2).should be_false
      end
    end
  end
end
