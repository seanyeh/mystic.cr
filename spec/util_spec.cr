require "./spec_helper"

module Mystic
  describe Util do
    describe ".perfect?" do
      it "returns true if perfect" do
        Util.perfect?(15).should eq(true)
      end

      it "returns false if not perfect" do
        Util.perfect?(16).should eq(false)
      end
    end

    describe ".offset_to_quality" do
      it "returns the P if 0 and perfect" do
        Util.offset_to_quality(0, true).should eq("P")
      end

      it "returns the A if 1 and imperfect" do
        Util.offset_to_quality(1, true).should eq("A")
      end

      it "returns the M if 1 and imperfect" do
        Util.offset_to_quality(1, false).should eq("M")
      end

      it "returns the A if 2 and imperfect" do
        Util.offset_to_quality(2, false).should eq("A")
      end

      it "returns the d if -1 and imperfect" do
        Util.offset_to_quality(-1, true).should eq("d")
      end

      it "returns the m if -1 and imperfect" do
        Util.offset_to_quality(-1, false).should eq("m")
      end

      it "returns the d if -2 and imperfect" do
        Util.offset_to_quality(-2, false).should eq("d")
      end
    end

    describe ".normalize_accidental" do
      it "returns empty string if 0" do
        Util.normalize_accidental(0).should eq("")
      end

      it "returns the correct flats" do
        Util.normalize_accidental(-2).should eq("bb")
      end

      it "returns the correct sharp" do
        Util.normalize_accidental(1).should eq("#")
      end

      it "returns the correct double sharp" do
        Util.normalize_accidental(2).should eq("x")
      end
    end

    describe ".accidental_offset" do
      it "returns the correct offset with multiple sharps" do
        Util.accidental_offset("#####").should eq(5)
      end

      it "returns the correct offset with triple sharp" do
        Util.accidental_offset("#x").should eq(3)
      end

      it "returns the correct offset with flats" do
        Util.accidental_offset("bbb").should eq(-3)
      end

      it "returns the correct offset with unicode accidentals" do
        Util.accidental_offset("♭").should eq(-1)
      end
    end
  end
end
