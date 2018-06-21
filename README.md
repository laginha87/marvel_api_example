# marvel_api_example

This is a sample app I built as a companion to this [blog post](https://revs.runtime-revolution.com/crystal-is-not-ruby-pt-2-7c3d988aa9a1)

## Installation

1. If you don't have crystal set up follow the [instructions from the crystal wiki](https://crystal-lang.org/docs/installation/)
1. Create an account in https://developer.marvel.com/docs and get your own keys
1. ```shards install```
1. ```cp .env.example .env``` and place your keys in the .env file

## Usage

Run ```shards build``` to build the binary then run it with from ```bin/marvel_api_example```.
The program takes a bit to finish because the api requests are really long, the requests then get cached into the ```cache``` folder.

If you get an invalid request because the keys are wrong or something like that, you need to clear the cache folder before running again.

## Contributing

1. Fork it ( https://github.com/laginha87/marvel_api_example/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [laginha87](https://github.com/laginha87)  - creator, maintainer
