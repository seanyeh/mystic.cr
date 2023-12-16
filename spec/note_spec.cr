require "./spec_helper"

module Mystic
  describe Note do
    natural_note = Note.new("C", "", 4)
    flat_note = Note.new("D", "b", 3)
    sharp_note = Note.new("F", "#", 5)

    describe ".new" do
      it "returns the correct note for a sharp note" do
        note = Note.new("C#4")

        note.to_s.should eq("C#4")
      end

      it "returns the correct note for a flat note" do
        note = Note.new("Db5")

        note.to_s.should eq("Db5")
      end

      it "returns the correct note for a note without accidentals" do
        note = Note.new("C3")

        note.to_s.should eq("C3")
      end

      it "returns standardized accidentals when given nonstandard format" do
        note = Note.new("Cx#3")

        note.to_s.should eq("C#x3")
      end

      it "returns standardized accidentals when given unicode characters" do
        note = Note.new("C𝄫3")

        note.to_s.should eq("Cbb3")
      end

      it "returns a note with the default octave when octave not provided" do
        note = Note.new("C")

        note.to_s.should eq("C4")
      end
    end

    describe ".from_midi" do
      it "returns the correct note" do
        note = Note.from_midi(61)

        note.to_s.should eq("C#4")
      end
    end

    describe ".from_coords" do
      it "returns the correct note without accidentals" do
        note = Note.from_coords(Coords.new(-1, 3))

        note.to_s.should eq("A4")
      end

      it "returns the correct sharp note" do
        note = Note.from_coords(Coords.new(-2, 7))

        note.to_s.should eq("C#6")
      end

      it "returns the correct double sharp note" do
        note = Note.from_coords(Coords.new(-6, 13))

        note.to_s.should eq("Fx5")
      end

      it "returns the correct flat note" do
        note = Note.from_coords(Coords.new(1, -3))

        note.to_s.should eq("Eb3")
      end

      it "returns the correct double flat note" do
        note = Note.from_coords(Coords.new(6, -11))

        note.to_s.should eq("Abb3")
      end
    end

    describe "#coords" do
      it "returns the correct coords for a note without accidentals" do
        natural_note.coords.should eq(Coords.new(0, 0))
      end

      it "returns the correct coords for a flat note" do
        sharp_note.coords.should eq(Coords.new(-2, 6))
      end

      it "returns the correct coords for a flat note" do
        flat_note.coords.should eq(Coords.new(2, -5))
      end
    end

    describe "#name" do
      it "returns the correct name" do
        sharp_note.name.should eq("F#")
      end

      it "returns the correct name for a note without accidentals" do
        natural_note.name.should eq("C")
      end
    end

    describe "#chroma" do
      it "returns the correct chroma" do
        sharp_note.chroma.should eq(6)
      end

      it "returns the correct chroma if accidentals wrap around octave" do
        n = Note.new("Bx#4")

        n.chroma.should eq(2)
      end
    end

    describe "#pitch_class" do
      it "returns the correct pitch class" do
        natural_note.pitch_class.should eq(PitchClass.new(0))
      end
    end

    describe "#midi" do
      it "returns the correct midi value" do
        natural_note.midi.should eq(60)
      end
    end

    describe "#frequency" do
      a4 = Note.new("A4")

      it "returns the correct frequency" do
        a4.frequency.should eq(440)
      end

      it "returns the correct frequency when given a custom tuning" do
        a4.frequency(415).should eq(415)
      end
    end

    describe "#accidental_offset" do
      it "returns the correct offset" do
        note = Note.new("C#4")

        note.accidental_offset.should eq(1)
      end
    end

    describe "#+" do
      it "returns the resulting note from adding an ascending interval" do
        i = Interval.new("A3")

        (natural_note + i).should eq(Note.new("E#4"))
      end

      it "returns the resulting note from adding a descending interval" do
        i = Interval.new("m-3")

        (natural_note + i).should eq(Note.new("A3"))
      end
    end

    describe "#- (interval)" do
      it "returns the resulting note from subtracting an ascending interval" do
        i = Interval.new("A3")

        (natural_note - i).should eq(Note.new("Abb3"))
      end

      it "returns the resulting note from subtracting a descending interval" do
        i = Interval.new("m-3")

        (natural_note - i).should eq(Note.new("Eb4"))
      end
    end

    describe "#- (note)" do
      it "returns the correct interval between the 2 notes" do
        n1 = Note.new("C#3")
        n2 = Note.new("C2")

        (n1 - n2).should eq(Interval.new("A8"))
      end

      it "returns the correct interval between the 2 notes when the other note is higher" do
        n1 = Note.new("C#3")
        n2 = Note.new("C4")

        (n1 - n2).should eq(Interval.new("d-8"))
      end
    end

    describe "#<=>" do
      it "returns the correct result for notes in different octaves" do
        n1 = Note.new("C3")
        n2 = Note.new("D2")

        (n1.<=>(n2)).should eq(1)
      end

      it "returns the correct result for notes in the same octave" do
        n1 = Note.new("Cx3")
        n2 = Note.new("Dbb3")

        (n1.<=>(n2)).should eq(-1)
      end

      it "returns the correct result for notes with the same letter and octave" do
        n1 = Note.new("Cx3")
        n2 = Note.new("Cb3")

        (n1.<=>(n2)).should eq(1)
      end

      it "returns the correct result for the same note" do
        n1 = Note.new("Cx3")
        n2 = Note.new("Cx3")

        (n1.<=>(n2)).should eq(0)
      end
    end

    describe "#<" do
      n1 = Note.new("C#3")
      n2 = Note.new("Db3")

      it "returns true if lower" do
        (n1 < n2).should be_true
      end

      it "returns false if higher" do
        (n2 < n1).should be_false
      end
    end

    describe "#>" do
      n1 = Note.new("C#3")
      n2 = Note.new("Db3")

      it "returns false if lower" do
        (n1 > n2).should be_false
      end

      it "returns true if higher" do
        (n2 > n1).should be_true
      end
    end

    describe "#==" do
      it "returns true if same" do
        n1 = Note.new("C#3")
        n2 = Note.new("C#3")

        (n1 == n2).should be_true
      end

      it "returns false if not the same" do
        n1 = Note.new("C#3")
        n2 = Note.new("Db3")

        (n1 == n2).should be_false
      end
    end

    describe "#to_s" do
      it "returns the correct string representation" do
        sharp_note.to_s.should eq("F#5")
      end
    end
  end
end
