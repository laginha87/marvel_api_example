require "./dependecies"
require "./marvel/*"

# TODO: Write documentation for `MarvelApiExample`
module Marvel
  # TODO: Put your code here
  def self.run
    chars = %w(deadpool thanos).map { |e| Marvel::Api::Character.find(e) }
    comics = Marvel::Api::Comic.with_characters(chars)
    aggregator = Aggregator.new
    comics.each { |e| aggregator.process(e) }
    comics.flat_map(&.characters).each { |c| aggregator.process(c) }

    puts aggregator.report
  end
end

Marvel.run
