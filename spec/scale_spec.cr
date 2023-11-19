module Mystic
  describe Scale do
    c_major = Scale.new(Note.new("C4"), "major")

    describe "#initialize" do
      it "creates the correct scale" do
        scale = Scale.new(Note.new("C#3"), "minor")

        scale.tonic.should eq(Note.new("C#3"))
        scale.type.should eq("minor")
        scale.intervals.should eq(Scale::SCALE_INTERVALS["minor"])
      end

      it "creates the correct scale when given a note type" do
        scale = Scale.new("C#3", "minor")

        scale.tonic.should eq(Note.new("C#3"))
        scale.type.should eq("minor")
        scale.intervals.should eq(Scale::SCALE_INTERVALS["minor"])
      end

      it "creates a custom scale when given intervals" do
        intervals = [Interval.new("P8"), Interval.new("A2")]
        tonic = Note.new("A1")
        scale = Scale.new(tonic, "custom", intervals)

        scale.tonic.should eq(tonic)
        scale.type.should eq("custom")
        scale.intervals.should eq(intervals)
      end
    end

    describe "notes" do
      it "returns the correct notes" do
        expected = [
          Note.new("C4"),
          Note.new("D4"),
          Note.new("E4"),
          Note.new("F4"),
          Note.new("G4"),
          Note.new("A4"),
          Note.new("B4"),
        ]

        c_major.notes.should eq(expected)
      end
    end

    describe "#name" do
      it "returns the name without the octave" do
        c_major.name.should eq("C major")
      end

      it "returns the name with the octave if specified" do
        c_major.name(include_octave: true).should eq("C4 major")
      end
    end

    describe "#to_s" do
      it "returns the correct string representation" do
        c_major.to_s.should eq("C4 major")
      end
    end
  end
end
