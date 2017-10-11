# frozen_string_literal: true
$LOAD_PATH.unshift(__dir__ + "/lib")

require "rack/acme"

Rack::Acme.configure do |config|
  config.cache = Rack::Acme::FileCache.new("./tokens")

  config.contact = "test@example.com"

  config.certificate_handler = lambda do |certificate|
    private_key = certificate.private_key || Rack::Acme.private_key.to_s
    File.write("#{certificate.common_name}.pem", certificate.fullchain_to_pem + private_key)
  end

  config.restart_handler = lambda do
    puts "Restarting haproxy"
  end
end

Rack::Acme.issue("example.com")
