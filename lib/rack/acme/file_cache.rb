# frozen_string_literal: true

module Rack::Acme
  class FileCache
    attr_accessor :path

    def initialize(path)
      @path = path
    end

    def [](token)
      dest = File.expand_path(token, path)

      File.read(dest) if File.exists?(dest)
    end

    def []=(token, value)
      dest = File.expand_path(token, path)

      File.write(dest, value)
    end
  end
end
