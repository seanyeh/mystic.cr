require "./spec_helper"

module Mystic
  describe PitchClass do
    pc = PitchClass.new(6)

    describe "#+" do
      it "returns the correct result" do
        (pc + 7).should eq(PitchClass.new(1))
      end
    end

    describe "#-" do
      it "returns the correct result" do
        (pc - 7).should eq(PitchClass.new(11))
      end
    end

    describe "#-" do
      pc2 = PitchClass.new(7)
      it "returns the correct result" do
        (pc - pc2).should eq(11)
      end
    end

    describe "#ic_distance" do
      pc1 = PitchClass.new(1)
      pc2 = PitchClass.new(11)

      it "returns the correct distance" do
        pc1.ic_distance(pc2).should eq(2)
      end
    end

    describe "#<=>" do
      it "returns -1 if less" do
        pc1 = PitchClass.new(1)
        pc2 = PitchClass.new(11)

        (pc1 <=> pc2).should eq(-1)
      end

      it "returns 1 if greater" do
        pc1 = PitchClass.new(11)
        pc2 = PitchClass.new(1)

        (pc1 <=> pc2).should eq(1)
      end

      it "returns 0 if equal" do
        pc1 = PitchClass.new(1)
        pc2 = PitchClass.new(1)

        (pc1 <=> pc2).should eq(0)
      end
    end

    describe "#==" do
      it "returns true if same" do
        pc1 = PitchClass.new(1)
        pc2 = PitchClass.new(1)

        (pc1 == pc2).should be_true
      end

      it "returns false if not same" do
        pc1 = PitchClass.new(1)
        pc2 = PitchClass.new(2)

        (pc1 == pc2).should be_false
      end
    end

    describe "#to_s" do
      it "returns the correct string representation" do
        pc.to_s.should eq("6")
      end
    end
  end
end
