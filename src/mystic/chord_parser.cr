# Parser for chord symbols
class Mystic::ChordParser
  # Default accidentals for imperfect intervals
  DEFAULT_ACCIDENTALS = {
    "2": "#",
    "6": "#",
    "7": "b",
    "9": "#",
    # TODO: Do we need a default for 10?
    "13": "#",
    "14": "b",
  }
  IMPLIED_MEMBERS = {
    "9":  [7],
    "11": [7, 9],
    "13": [7, 9, 11],
  }

  ACCIDENTAL_ALIASES = {
    "+": "#",
    "-": "b",
  }

  struct Token
    property member, accidental, type

    SUS  = "sus"
    OMIT = "omit"
    EXT  = "extension"
    ADD  = "add"

    def initialize(@member : Int32, @accidental = "", @type = EXT)
    end

    def member?
      type != OMIT
    end
  end

  # Return a standardized format for qualities for a given string quality
  def self.normalize_basic_quality(s : String)
    if s.downcase.in?(["maj", "ma"])
      "M"
    elsif s.downcase.in?(["mi", "min"])
      "m"
    else
      s
    end
  end

  # Parse a string chord symbol and return the resulting `Chord`
  def self.parse(s : String)
    pattern = (
      "^" \
      "(?<root>#{Note::NAME_PATTERN})" \
      "(?<basic_quality>Ma?j?|mi?n?|dim|\\+)?" \
      "(?<seventh>7)?" \
      "(\\((?<ext>.*)\\)|(?<ext>.*))" \
      "$"
    )
    match = Regex.new(pattern).match(s)

    raise Error.new("Invalid chord format") if match.nil?

    root_name = match["root"]
    basic_quality = ChordParser.normalize_basic_quality(match["basic_quality"]? || "")
    seventh = match["seventh"]?
    extensions = match["ext"]? || ""

    # Parse extensions
    tokens = ChordParser.tokenize_extensions(extensions)
    ext_intervals = ChordParser.parse_extensions(tokens, has_seventh: !!seventh)

    # Build triad
    triad_intervals = [] of Interval

    skip_third = tokens.any? do |token|
      token.type == Token::SUS ||
        (token.type == Token::OMIT && token.member == 3)
    end

    skip_fifth = tokens.any? do |token|
      (token.type == Token::OMIT && token.member == 5) ||
        (token.type == Token::EXT && token.member == 5)
    end

    third_quality = basic_quality.in?(["m", "dim"]) ? "m3" : "M3"
    fifth_quality =
      case basic_quality
      when "+"   then "A5"
      when "dim" then "d5"
      else
        "P5"
      end

    triad_intervals.push(Interval.new(third_quality)) unless skip_third
    triad_intervals.push(Interval.new(fifth_quality)) unless skip_fifth

    # 7 is special because it can be modified by a major basic quality
    seventh_interval = begin
      if seventh
        case basic_quality
        when "M", "+" then Interval.new("M7")
        when "dim"    then Interval.new("d7")
        else
          Interval.new("m7")
        end
      end
    end

    # Create Chord
    root = Note.new(root_name)
    intervals = triad_intervals + [seventh_interval].compact + ext_intervals

    Chord.new(root, intervals: intervals)
  end

  # Uses the given *tokens* and returns a list of extended intervals (beyond the 3rd/5th)
  #
  # When *has_seventh* is true, the chord symbol has an explicit 7th,
  # so there is no need to add an implied 7th
  def self.parse_extensions(tokens : Array(Token), has_seventh = false)
    # Add implied members
    max_extension = tokens.compact_map do |token|
      next if token.type == Token::ADD || !IMPLIED_MEMBERS.has_key?(token.member.to_s)

      token.member
    end.max? || 0

    implied_tokens = IMPLIED_MEMBERS.fetch(max_extension.to_s, [] of Int32).compact_map do |member|
      next if tokens.any? { |token| token.member == member }

      next if has_seventh && member == 7

      Token.new(member)
    end

    (tokens + implied_tokens).compact_map do |token|
      next if !token.member?

      member = token.member
      accidental = ACCIDENTAL_ALIASES.fetch(token.accidental, token.accidental)

      quality = ChordParser.accidentals_to_quality(member, accidental)
      Interval.new("#{quality}#{member}")
    end.sort!
  end

  # Splits the given string into tokens
  def self.tokenize_extensions(s : String)
    tokens = [] of Token

    pattern = "^(?<prefix>add|no|omit)?(?<accidental>[#♯x𝄪]*|[b♭𝄫]+|[+-])(?<member>[245-9]|1[0-4])|^(?<sus>sus)(?<sus_member>[24]?)"

    current = s.dup
    while !current.empty?
      match = Regex.new(pattern).match(current)

      raise "Invalid extension format #{s}" if match.nil?

      prefix = match["prefix"]?
      sus = match["sus"]?

      if sus
        sus_member = match["sus_member"].presence.try(&.to_i) || 4

        tokens.push(Token.new(sus_member, type: Token::SUS))
      elsif prefix == "omit" || prefix == "no"
        member = match["member"].to_i

        raise Error.new("Interval required for \"omit/no\"") if member.nil?

        tokens.push(Token.new(member, type: Token::OMIT))
      else
        accidental = match["accidental"]
        member = match["member"].to_i

        raise Error.new("Interval required") if member.nil?

        token_type = prefix == "add" ? Token::ADD : Token::EXT
        tokens.push(Token.new(member, accidental: accidental, type: token_type))
      end

      current = current[match.end..]
    end

    tokens
  end

  protected def self.accidentals_to_quality(member : Int32, accidental = "")
    if accidental.empty?
      accidental = DEFAULT_ACCIDENTALS.fetch(member.to_s, "")
    end

    is_perfect = Util.perfect?(member)

    accidental_offset = Util.accidental_offset(accidental)
    Util.offset_to_quality(accidental_offset, is_perfect: is_perfect)
  end
end
