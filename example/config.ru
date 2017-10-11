# frozen_string_literal: true
lib = File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift(lib)

require "rack/acme"

use Rack::Acme::Endpoint

run ->(env) { [200, {}, ["Hello world"]] }
