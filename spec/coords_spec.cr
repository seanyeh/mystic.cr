module Mystic
  describe Coords do
    coords = Coords.new(2, -3)
    coords2 = Coords.new(-7, 1)

    describe "value" do
      it "returns the correct value" do
        coords.value.should eq(2)
      end
    end

    describe "#+" do
      it "returns the correct result" do
        (coords + coords2).should eq(Coords.new(-5, -2))
      end
    end

    describe "#-" do
      it "returns the correct result" do
        (coords - coords2).should eq(Coords.new(9, -4))
      end
    end

    describe "#*" do
      it "returns the correct result" do
        (coords * 3).should eq(Coords.new(6, -9))
      end
    end

    describe "#==" do
      it "returns true if octave and fifths are the same" do
        c1 = Coords.new(1, 2)
        c2 = Coords.new(1, 2)
        (c1 == c2).should be_true
      end

      it "returns false if octave and fifths are not the same" do
        c1 = Coords.new(1, 2)
        c2 = Coords.new(1, -2)

        (c1 == c2).should be_false
      end
    end
  end
end
