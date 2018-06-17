require "./api/*"
module Marvel
  class CounterTable(K) < Hash(K, Int32)
    def inc(key : K)
      self[key] = (self[key]? || 0) + 1
    end

    def sorted
      to_a.sort_by(&.[1])
    end

    def top
      sorted.reverse
    end

    def bottom
      sorted
    end

    def top(n : Int32)
      top.first(10)
    end

    def bottom(n : Int32)
      bottom.first(10)
    end
  end

  class Aggregator
    alias Comic = Api::Comic
    alias Character = Api::Character

    def initialize
      @named_thanos_titles = [] of Comic
      @named_deadpool_titles = [] of Comic
      @other_titles = [] of Comic
      @formats = CounterTable(Comic::Format).new
      @characters = CounterTable(String).new
    end

    def process(comic : Comic)
      count(comic.format)
      count(comic)
    end

    def count(format : Comic::Format)
      @formats.inc(format)
    end

    def count(comic : Comic)
      case comic
      when .no_title?, .paperback?
      when .match?(/[dD]eadpool/)
        @named_deadpool_titles << comic
      when .match?(/[tT]hanos/)
        @named_thanos_titles << comic
      else
        @other_titles << comic
      end
    end

    def process(character : Character)
      case character.name
      when /[Tt]hanos/, /[dD]eadpool/
        # SKIP
      else
        @characters.inc(character.name)
      end
    end

    def total
      @formats.values.sum
    end

    def report
      <<-REPORT
      There are #{total} comics with deadpool and thanos in it.
      There are #{@named_deadpool_titles.size} with deadpool name on the title.
      There are #{@named_thanos_titles.size} with thanos name on the title.
      The other #{@other_titles.size} have neither name on the title.
      They come in the following formats:
      #{format_report}

      Involving a total of #{@characters.size} different characters.
      Top character appearances are:
      #{top_character_report}

      The most obscure characters by number of appearnces are:
      #{obscure_character_report}
      REPORT
    end

    def top_character_report
      @characters.top(10).map { |k, v| "  #{k} with #{v} appearances" }.join("\n")
    end

    def obscure_character_report
      @characters.bottom(10).map { |k, v| "  #{k} with #{v} appearances" }.join("\n")
    end

    def format_report
      @formats.top.map { |k, v| "  #{k}: #{v}" }.join("\n")
    end
  end
end
