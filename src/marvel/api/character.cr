require "./api"

module Marvel::Api
  class Character < Record
    JSON.mapping(id: Int32?, name: String)

    def self.path
      "characters"
    end

    def self.find(name : String) : Resource
      get({"name" => name}).data.not_nil!.results.not_nil!.first.not_nil!
    end
  end
end
