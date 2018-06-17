
def hexify(*args)
  # Digests the passed in strings into a single hash
  Digest::MD5.digest do |ctx|
    args.each { |e| ctx.update(e) }
  end.to_slice.hexstring
end


module Marvel::Api


  class CachedClient
    def self.get(url, headers)
      cache_file_name = "./cache/#{get_cache_key(url)}.json"
      if File.exists?(cache_file_name)
        File.read(cache_file_name)
      else
        data = HTTP::Client.get(url, headers).body
        File.write(cache_file_name, data)
        data
      end
    end

    def self.get_cache_key(url)
      new_url, params = url.split("?")
      new_params = params.split("&").reject(&.match /ts|hash|apikey/)
      base = [new_url, new_params.join("&")].join("?")
      hexify(base)
    end
  end

  class ResponseWrapper(T)
    JSON.mapping(code: Int32?,
      status: String?,
      data: Container(T)?)
  end

  class Container(T)
    JSON.mapping(
      offset: Int32?,
      limit: Int32?,
      total: Int32?,
      count: Int32?,
      results: Array(T)
    )
  end

  class ListWrapper(T)
    JSON.mapping(available: Int32, collectionURI: String, returned: Int32, items: Array(T))

    def has_more?
      available != returned
    end
  end

  module Errors
    class MissingParameter
      JSON.mapping(code: String, message: String)
    end
  end

  abstract class Record
    BASE_URL = "https://gateway.marvel.com:443/v1/public/"

    macro inherited
      {% begin %}
        alias Resource={{@type}}
      {% end %}
      alias Success = Api::ResponseWrapper(Resource)
      alias Error = Api::Errors::MissingParameter
      R = Success | Error

      def self.get(params) : Success
        headers = HTTP::Headers{"Accept" => "application/json"}
        salt = Random.new.rand.to_s
        hash = hexify(salt, PRIVATE_KEY, PUBLIC_KEY)
        params.merge!({
          "ts" => salt,
          "apikey" => PUBLIC_KEY,
          "hash" => hash
        })

        query_params = params.map(&.join("=")).join("&")
        url = "#{BASE_URL}/#{path}?#{query_params}"
        res = CachedClient.get(url, headers)
        case response_body = R.from_json(res)
        when Success
          response_body
        when Error
          raise "Error: #{response_body.message}"
        else
          raise "Error no response"
        end
      end

      def self.all(params : Hash(String, String)) : Array(Resource)
        res = [] of Resource
        keep_collecting = true
        offset = 0
        while (keep_collecting)
          data = get_page(params, offset)
          res += data[:page]
          offset += 100
          keep_collecting = data[:has_more]
        end
        res
      end

      def self.get_page(params : Hash(String, String), offset : Int32) : NamedTuple(page: Array(Resource), has_more: Bool)
        res = get(params.merge({"limit" => 100, "offset" => offset}))
        data = res.data.not_nil!
        count = data.count.not_nil!
        limit = data.limit.not_nil!
        {
          page: data.results.not_nil!,
          has_more: count == limit
        }
      end
    end
  end
end
