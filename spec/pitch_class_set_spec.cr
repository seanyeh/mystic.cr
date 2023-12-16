require "./spec_helper"

module Mystic
  describe PitchClassSet do
    describe ".new" do
      it "creates the correct pitch class set without duplicates" do
        pc_set = PitchClassSet.new([PitchClass.new(1), PitchClass.new(1)])

        pc_set.pitch_classes.map(&.value).should eq([1])
      end

      it "creates the correct pitch class set given an array of pitch class values" do
        pitch_class_values = [0, 11, 1]
        pc_set = PitchClassSet.new(pitch_class_values)

        pc_set.pitch_classes.map(&.value).should eq(pitch_class_values)
      end
    end

    describe ".from_forte_number" do
      it "returns the correct pitch class set from the given forte number" do
        pc_set = PitchClassSet.from_forte_number("3-9")

        pc_set.pitch_classes.map(&.value).should eq([0, 2, 7])
      end

      it "raises an error if the given forte number is invalid" do
        expect_raises(Error, "Invalid forte number: invalid") do
          PitchClassSet.from_forte_number("invalid")
        end
      end
    end

    describe "#pitch_class_values" do
      it "returns the correct pitch class values" do
        pitch_class_values = [0, 11, 1]
        pc_set = PitchClassSet.new(pitch_class_values)

        pc_set.pitch_class_values.should eq(pitch_class_values)
      end
    end

    describe "#normal_form" do
      it "returns the correct result" do
        result = PitchClassSet.new([11, 7, 2, 3]).normal_form

        result.pitch_class_values.should eq([11, 2, 3, 7])
      end

      it "returns the set closest to 0 if tied" do
      end
    end

    describe "#prime_form" do
      it "returns the correct result" do
        result = PitchClassSet.new([10, 0, 2, 3, 5]).prime_form

        result.pitch_class_values.should eq([0, 2, 3, 5, 7])
      end
    end

    describe "#invert" do
      it "returns the inverted pitch class set (around 0)" do
        result = PitchClassSet.new([2, 4, 7]).invert

        result.pitch_class_values.should eq([10, 8, 5])
      end

      it "returns the inverted pitch class set around the given pitch class" do
        result = PitchClassSet.new([2, 4, 7]).invert(PitchClass.new(1))

        result.pitch_class_values.should eq([0, 10, 7])
      end

      it "returns the inverted pitch class set around the given pitch class value" do
        result = PitchClassSet.new([2, 4, 7]).invert(1)

        result.pitch_class_values.should eq([0, 10, 7])
      end
    end

    describe "#interval_vector" do
      it "returns the correct interval vector" do
        result = PitchClassSet.new([7, 10, 1, 5]).interval_vector

        result.should eq([0, 1, 2, 1, 1, 1])
      end
    end

    describe "#forte_number" do
      it "returns the correct forte number" do
        result = PitchClassSet.new([10, 0, 2, 3, 5]).forte_number

        result.should eq("5-23B")
      end
    end

    describe "#size" do
      it "returns the number of pitch classes" do
        pc_set = PitchClassSet.new([1, 2, 3])
        pc_set.size.should eq(3)
      end
    end

    describe "#first" do
      it "returns the first pitch class" do
        pc_set = PitchClassSet.new([1, 2, 3])
        pc_set.first.value.should eq(1)
      end
    end

    describe "#last" do
      it "returns the last pitch class" do
        pc_set = PitchClassSet.new([1, 2, 3])
        pc_set.last.value.should eq(3)
      end
    end

    describe "#sort" do
      it "returns the sorted version" do
        pc_set = PitchClassSet.new([2, 1])

        pc_set.sort.should eq(PitchClassSet.new([1, 2]))
      end
    end

    describe "#transpose_to" do
      it "returns the correct transposed pitch class set" do
        result = PitchClassSet.new([1, 9]).transpose_to(4)

        result.pitch_class_values.should eq([4, 0])
      end
    end

    describe "#ti" do
      it "returns the correct transposed and inverted pitch class set" do
        result = PitchClassSet.new([2, 4, 5]).ti(7)

        result.pitch_class_values.should eq([5, 3, 2])
      end
    end

    describe "#t" do
      it "returns the correct transposed pitch class set" do
        result = PitchClassSet.new([0, 9]).t(4)

        result.pitch_class_values.should eq([4, 1])
      end
    end

    describe "#+" do
      it "returns the correct transposed pitch class set" do
        result = PitchClassSet.new([0, 9]) + 4

        result.pitch_class_values.should eq([4, 1])
      end
    end

    describe "#-" do
      it "returns the correct transposed pitch class set" do
        result = PitchClassSet.new([0, 9]) - 4

        result.pitch_class_values.should eq([8, 5])
      end
    end

    describe "#<=>" do
      it "returns -1 when outer distance is less" do
        pc_set1 = PitchClassSet.new([0, 7])
        pc_set2 = PitchClassSet.new([1, 9])

        (pc_set1 <=> pc_set2).should eq(-1)
      end

      it "returns -1 when distances are equivalent and closer to 0" do
        pc_set1 = PitchClassSet.new([0, 7, 8])
        pc_set2 = PitchClassSet.new([1, 8, 9])

        (pc_set1 <=> pc_set2).should eq(-1)
      end
    end

    describe "#==" do
      it "returns true if same" do
        pc_set1 = PitchClassSet.new([1, 2])
        pc_set2 = PitchClassSet.new([1, 2])

        (pc_set1 == pc_set2).should be_true
      end

      it "returns false if not the same" do
        pc_set1 = PitchClassSet.new([1, 3])
        pc_set2 = PitchClassSet.new([1, 2])

        (pc_set1 == pc_set2).should be_false
      end
    end

    describe "#to_s" do
      it "returns the correct string representation" do
        pc_set = PitchClassSet.new([1, 2])

        pc_set.to_s.should eq("[1, 2]")
      end
    end
  end
end
