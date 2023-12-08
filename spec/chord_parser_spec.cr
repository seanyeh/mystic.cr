require "./spec_helper"

macro run_parse_tests(test_cases)
  {% for test_case in test_cases %}
    {% s, expected = test_case %}

    it "returns the correct chord for #{{{ s }}}" do
      c = ChordParser.parse({{s}})
      c.intervals.map(&.to_s).should eq({{expected}})
    end
  {% end %}
end

module Mystic
  T = ChordParser::Token

  describe ChordParser do
    describe ".parse" do
      run_parse_tests([
        ["C#", ["M3", "P5"]],
        ["C#7", ["M3", "P5", "m7"]],
        ["C#M7#9", ["M3", "P5", "M7", "M9"]],
        ["C#Maj7#9", ["M3", "P5", "M7", "M9"]],
        ["C#7sus", ["P4", "P5", "m7"]],
        ["C#7sus2", ["M2", "P5", "m7"]],
        ["C#add13", ["M3", "P5", "M13"]],
        ["C#no5add13", ["M3", "M13"]],
        ["Cb13", ["M3", "P5", "m7", "M9", "P11", "M13"]],
        ["C(b13)", ["M3", "P5", "m7", "M9", "P11", "m13"]],
        ["C6", ["M3", "P5", "M6"]],
        ["Cm7", ["m3", "P5", "m7"]],
        ["Cdim7", ["m3", "d5", "d7"]],
        ["C+7", ["M3", "A5", "M7"]],

        # TODO: Be able to parse chords with altered 5ths labeled after 7th, e.g. C7+5
      ])
    end

    describe ".parse_extensions" do
      it "returns the correct intervals" do
        tokens = [
          T.new(7, "#"),
          T.new(9, "b"),
          T.new(11, "b"),
          T.new(13, "#x"),
        ]

        expected = [
          Interval.new("M7"),
          Interval.new("m9"),
          Interval.new("d11"),
          Interval.new("AA13"),
        ]

        ChordParser.parse_extensions(tokens).should eq(expected)
      end

      it "returns the correct intervals with implied members" do
        tokens = [
          T.new(11, "b"),
        ]

        expected = [
          Interval.new("m7"),
          Interval.new("M9"),
          Interval.new("d11"),
        ]

        ChordParser.parse_extensions(tokens).should eq(expected)
      end

      it "returns the correct intervals with implied members and already having a seventh" do
        tokens = [
          T.new(11, "b"),
        ]

        expected = [
          Interval.new("M9"),
          Interval.new("d11"),
        ]

        ChordParser.parse_extensions(tokens, has_seventh: true).should eq(expected)
      end

      it "returns the correct intervals skipping non-member tokens" do
        tokens = [
          T.new(7, "#"),
          T.new(5, "", ChordParser::Token::OMIT),
          T.new(4, "", ChordParser::Token::SUS),
        ]

        expected = [
          Interval.new("P4"),
          Interval.new("M7"),
        ]

        ChordParser.parse_extensions(tokens).should eq(expected)
      end

      it "returns the correct intervals with default accidentals" do
        tokens = [
          T.new(7, ""),
          T.new(9, ""),
          T.new(11, ""),
          T.new(12, ""),
          T.new(13, ""),
        ]

        expected = [
          Interval.new("m7"),
          Interval.new("M9"),
          Interval.new("P11"),
          Interval.new("P12"),
          Interval.new("M13"),
        ]

        ChordParser.parse_extensions(tokens).should eq(expected)
      end
    end

    describe ".tokenize_extensions" do
      it "returns the correct tokens" do
        s = "#7b911#x13"
        expected = [
          T.new(7, "#"),
          T.new(9, "b"),
          T.new(11, ""),
          T.new(13, "#x"),
        ]

        ChordParser.tokenize_extensions(s).should eq(expected)
      end

      it "returns the correct tokens with omit" do
        s = "7no5"
        expected = [
          T.new(7, ""),
          T.new(5, "", ChordParser::Token::OMIT),
        ]

        ChordParser.tokenize_extensions(s).should eq(expected)
      end

      it "returns the correct tokens with sus" do
        s = "7sus9"
        expected = [
          T.new(7, ""),
          T.new(4, "", ChordParser::Token::SUS),
          T.new(9, ""),
        ]

        ChordParser.tokenize_extensions(s).should eq(expected)
      end

      it "returns the correct tokens with sus with member" do
        s = "7sus29"
        expected = [
          T.new(7, ""),
          T.new(2, "", ChordParser::Token::SUS),
          T.new(9, ""),
        ]

        ChordParser.tokenize_extensions(s).should eq(expected)
      end

      it "returns the correct tokens with add" do
        s = "7add13"
        expected = [
          T.new(7, ""),
          T.new(13, "", ChordParser::Token::ADD),
        ]

        ChordParser.tokenize_extensions(s).should eq(expected)
      end
    end
  end
end
