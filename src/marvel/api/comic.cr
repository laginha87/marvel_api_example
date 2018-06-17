require "./api"

module Marvel::Api
  class Comic < Record
    enum Format
      Unknown
      Comic
      Magazine
      TradePaperback
      Hardcover
      Digest
      GraphicNovel
      DigitalComic
      InfiniteComic

      def self.parse(string : String)
        return Unknown if string.empty?
        super(string.gsub(" ", ""))
      end
    end

    JSON.mapping(id: Int32?,
      title: String?,
      format: Format,
      characters: Api::ListWrapper(Character)
    )

    def no_title?
      if t = title
        t.empty?
      else
        false
      end
    end

    def match?(r : Regex)
      r.match(title.not_nil!)
    end

    def paperback?
      format.not_nil!.trade_paperback?
    end

    def self.path
      "comics"
    end

    def self.with_characters(chars : Array(Character))
      ids = chars.map(&.id.not_nil!).join(",")
      all({"characters" => ids, "noVariants" => "true"})
    end

    def characters
      @characters.items.not_nil!
    end
  end
end