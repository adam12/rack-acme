# frozen_string_literal: true
require "rack"
require "acme-client"
require "openssl"
require "rack/acme/endpoint"
require "rack/acme/file_cache"

module Rack::Acme
  class << self
    attr_accessor :contact

    def configure
      yield self if block_given?
    end

    def cache
      path = "./tokens"
      @cache ||= FileCache.new(path)
    end
    attr_writer :cache

    def issue(domain)
      raise ArgumentError, "contact is nil" if contact.nil?

      authorization = client.authorize(domain: domain)

      case authorization.status
      when "pending"
        challenge = authorization.http01

        token = challenge.token
        challenge_content = challenge.file_content

        cache[token] = challenge_content

        challenge.request_verification

        sleep 1

        tries = 3
        while challenge.verify_status == "pending"
          sleep 1

          break if (tries -= 1) <= 0
        end

        csr = ::Acme::Client::CertificateRequest.new(names: [domain])
        certificate = client.new_certificate(csr)

        certificate_handler.call(certificate) if certificate_handler.respond_to?(:call)
        restart_handler.call if restart_handler.respond_to?(:call)

        certificate

      when "valid"
        csr = Acme::Client::CertificateRequest.new(names: [domain])
        certificate = client.new_certificate(csr)

        certificate_handler.call(certificate) if certificate_handler.respond_to?(:call)
        restart_handler.call if restart_handler.respond_to?(:call)

        certificate
      end
    end

    def certificate_handler
      @certificate_handler || proc {}
    end
    attr_writer :certificate_handler

    def restart_handler
      @restart_handler || proc {}
    end
    attr_writer :restart_handler

    def client
      @client ||= build_client
    end

    def build_client
      client = ::Acme::Client.new(
        private_key: private_key,
        endpoint: endpoint,
        connection_options: connection_options
      )

      registration = client.register(contact: "mailto:#{contact}")
      registration.agree_terms

      client
    end

    def endpoint
      @endpoint ||= default_endpoint
    end
    attr_writer :endpoint

    def default_endpoint
      "https://acme-staging.api.letsencrypt.org/"
    end

    def private_key
      @private_key ||= build_private_key
    end

    def build_private_key
      OpenSSL::PKey::RSA.new(4096)
    end

    def connection_options
      @connection_options ||= { request: { open_timeout: 5, timeout: 5 } }
    end
    attr_writer :connection_options
  end
end
