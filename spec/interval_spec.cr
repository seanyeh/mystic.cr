require "./spec_helper"

macro run_addition_tests(test_cases)
  {% for test_case in test_cases %}
    {% i1, i2, expected = test_case %}

    it "returns #{{{ expected }}} for #{{{ i1 }}} + #{{{ i2 }}}" do
        i1 = Interval.new({{ i1 }})
        i2 = Interval.new({{ i2 }})
        (i1 + i2).to_s.should eq({{ expected }})
    end
  {% end %}
end

module Mystic
  describe Interval do
    ascending_interval = Interval.new("M3")
    descending_interval = Interval.new("M-3")
    compound_interval = Interval.new("M24") # 3 octaves + M3

    describe ".new" do
      it "returns the correct descending interval" do
        interval = Interval.new("M3")

        interval.quality.should eq("M")
        interval.value.should eq(3)
      end

      it "returns the correct descending interval" do
        interval = Interval.new("P-8")

        interval.quality.should eq("P")
        interval.value.should eq(-8)
      end

      it "returns the correct interval when given an extended quality" do
        interval = Interval.new("AAA4")

        interval.quality.should eq("AAA")
        interval.value.should eq(4)
      end
    end

    describe ".from_coords" do
      it "creates the correct simple intervals" do
        Interval.from_coords(Coords.new(3, -5)).to_s.should eq("m2")
        Interval.from_coords(Coords.new(2, -5)).to_s.should eq("M-7")
        Interval.from_coords(Coords.new(0, -1)).to_s.should eq("P-5")
        Interval.from_coords(Coords.new(4, -8)).to_s.should eq("A-5")
        Interval.from_coords(Coords.new(-4, 8)).to_s.should eq("A5")
        Interval.from_coords(Coords.new(4, -6)).to_s.should eq("d5")
      end

      it "creates the correct compound intervals" do
        Interval.from_coords(Coords.new(4, -5)).to_s.should eq("m9")
        Interval.from_coords(Coords.new(3, -8)).to_s.should eq("A-12")
      end
    end

    describe "#coords" do
      it "returns the correct coords for ascending simple interval coords" do
        Interval.new("P1").coords.should eq(Coords.new(0, 0))
        Interval.new("m6").coords.should eq(Coords.new(3, -4))
        Interval.new("A4").coords.should eq(Coords.new(-3, 6))
        Interval.new("d3").coords.should eq(Coords.new(6, -10))
      end

      it "returns the correct coords for descending interval coords" do
        Interval.new("m-2").coords.should eq(Coords.new(-3, 5))
        Interval.new("P-8").coords.should eq(Coords.new(-1, 0))
      end

      it "returns the correct coords for compound intervals" do
        Interval.new("m9").coords.should eq(Coords.new(4, -5))
        Interval.new("dd-12").coords.should eq(Coords.new(-9, 13))
      end
    end

    describe "#number" do
      it "returns absolute value of value" do
        descending_interval.number.should eq(3)
      end
    end

    describe "#direction" do
      it "returns 1 if ascending" do
        ascending_interval.direction.should eq(1)
      end

      it "returns -1 if ascending" do
        descending_interval.direction.should eq(-1)
      end
    end

    describe "#simple?" do
      it "returns true if octave or less" do
        descending_interval.simple?.should eq(true)
      end

      it "returns false if greater than an octave" do
        compound_interval.simple?.should eq(false)
      end
    end

    describe "#compound?" do
      it "returns false if octave or less" do
        descending_interval.compound?.should eq(false)
      end

      it "returns true if greater than an octave" do
        compound_interval.compound?.should eq(true)
      end
    end

    describe "#octaves" do
      it "returns 0 for under an octave" do
        ascending_interval.octaves.should eq(0)
      end

      it "returns 0 for an octave" do
        interval = Interval.new("P8")

        interval.octaves.should eq(0)
      end

      it "returns the correct number of octaves for large intervals" do
        compound_interval.octaves.should eq(3)
      end
    end

    describe "#simple" do
      it "returns the correct result for a compound interval" do
        compound_interval.simple.should eq(Interval.new("M3"))
      end

      it "returns the same interval for a simple interval" do
        descending_interval.simple.should eq(descending_interval)
      end
    end

    describe "#reverse" do
      it "returns the same interval with opposite direction" do
        descending_interval.reverse.should eq(Interval.new("M3"))
      end
    end

    describe "#invert" do
      it "returns the correct result" do
        Interval.new("M6").invert.should eq(Interval.new("m3"))
      end

      it "returns the correct result for a descending interval" do
        Interval.new("A-5").invert.should eq(Interval.new("d-4"))
      end

      it "returns the correct result for an octave" do
        Interval.new("d8").invert.should eq(Interval.new("A1"))
      end

      it "returns the correct result for a compound interval" do
        Interval.new("P18").invert.should eq(Interval.new("P5"))
      end
    end

    describe "#quality_offset" do
      it "returns the correct value" do
        i = Interval.new("m3")

        i.quality_offset.should eq(0)
      end

      it "returns the correct value for a diminished interval" do
        i = Interval.new("d5")

        i.quality_offset.should eq(-1)
      end

      it "returns the correct value for a doubly augmented interval" do
        i = Interval.new("AA3")

        i.quality_offset.should eq(3)
      end
    end

    describe "#semitones" do
      it "returns the correct value for a minor interval" do
        interval = Interval.new("m3")

        interval.semitones.should eq(3)
      end

      it "returns the correct value for a major interval" do
        interval = Interval.new("M3")

        interval.semitones.should eq(4)
      end

      it "returns the correct value for a perfect interval" do
        interval = Interval.new("P4")

        interval.semitones.should eq(5)
      end

      it "returns the correct value for an augmented interval (A5)" do
        interval = Interval.new("A5")

        interval.semitones.should eq(8)
      end

      it "returns the correct value for an augmented interval (A6)" do
        interval = Interval.new("A6")

        interval.semitones.should eq(10)
      end

      it "returns the correct value for a diminished interval" do
        interval = Interval.new("d5")

        interval.semitones.should eq(6)
      end
    end

    describe "#+" do
      run_addition_tests([
        # imperfect + _ = perfect
        ["m3", "m3", "d5"],
        ["M3", "m6", "P8"],
        ["M3", "M3", "A5"],
        ["M3", "AA6", "AAA8"],
        ["d3", "d3", "ddd5"],

        ["m-3", "m-3", "d-5"],
        ["M-3", "AA-6", "AAA-8"],
        ["d-3", "d-3", "ddd-5"],
        ["M2", "A-2", "A-1"],

        # imperfect + _ = imperfect
        ["m2", "m6", "d7"],
        ["M2", "m6", "m7"],
        ["m2", "AA6", "A7"],
        ["m2", "P5", "m6"],
        ["m2", "AA5", "A6"],

        ["M3", "m-2", "A2"],
        ["m2", "m-3", "M-2"],
        ["m3", "m-2", "M2"],
        ["m2", "P-5", "A-4"],
        ["m-2", "A4", "A3"],

        # perfect + perfect
        ["P1", "P1", "P1"],
        ["P8", "P8", "P15"],
        ["A5", "P4", "A8"],
        ["A1", "dd1", "A-1"],
        ["P1", "d1", "A-1"],

        ["A8", "AA8", "AAA15"],
        ["A-5", "P-4", "A-8"],
        ["A-8", "AA-8", "AAA-15"],

        # compound intervals
        ["M9", "d15", "m23"],
        ["A-9", "M13", "d5"],
      ])
    end

    describe "#-" do
      it "returns the correct result" do
        i1 = Interval.new("m2")
        i2 = Interval.new("A11")

        (i1 - i2).should eq(Interval.new("A-10"))
      end

      it "returns the correct result when subtracting a descending interval" do
        i1 = Interval.new("m-2")
        i2 = Interval.new("A-11")

        (i1 - i2).should eq(Interval.new("A10"))
      end
    end

    describe "#==" do
      it "returns true if same" do
        i1 = Interval.new("M3")
        i2 = Interval.new("M3")

        (i1 == i2).should be_true
      end

      it "returns false if not the same" do
        i1 = Interval.new("M3")
        i2 = Interval.new("M-3")

        (i1 == i2).should be_false
      end
    end

    describe "#to_s" do
      it "returns quality and value as a string" do
        ascending_interval.to_s.should eq("M3")
      end
    end
  end
end
