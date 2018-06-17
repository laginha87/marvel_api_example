require "json"
require "http"
require "digest"
require "dotenv"

Dotenv.load

PRIVATE_KEY = ENV["PRIVATE_KEY"]
PUBLIC_KEY  = ENV["PUBLIC_KEY"]
