# Polisher Gemfile Represenation
#
# Licensed under the MIT license
# Copyright (C) 2013 Red Hat, Inc.

require 'bundler'

require 'polisher/version_checker'

# Override bundler's gem registration
module Bundler
  class << self
    attr_accessor :bundler_gems

    def init_gems
      Bundler.bundler_gems = []
    end
  end

  class Dsl
    alias :old_gem :gem
    def gem(name, *args)
      Bundler.bundler_gems ||= []
      version = args.first.is_a?(Hash) ? nil : args.first
      Bundler.bundler_gems << [name, version]
      old_gem(name, *args)
    end
  end
end

module Polisher
  class Gemfile
    include VersionedDependencies

    # always nil, for interface compatability
    attr_accessor :version

    attr_accessor :deps
    attr_accessor :dev_deps

    # always empty array, for interface compatability
    attr_accessor :files

    def initialize(args={})
      @version  = nil
      @deps     = args[:deps]
      @dev_deps = args[:dev_deps]
      @files    = []
    end

    # Parse the specified gemfile & return new Gemfile instance from metadata
    # 
    # @param [String] path to gemfile to parse
    # @return [Polisher::Gemfile] gemfile instantiated from parsed metadata
    def self.parse(path)
      path,g = File.split(path)
      Dir.chdir(path){
        Bundler.init_gems
        begin
          Bundler::Definition.build(g, nil, false)
        rescue Bundler::GemfileNotFound
          raise ArgumentError, "invalid gemfile: #{path}"
        end
      }
      metadata = {}
      metadata[:deps]     = Bundler.bundler_gems.collect { |n,v| n }
      metadata[:dev_deps] = [] # TODO

      self.new metadata
    end
  end # class Gemfile
end # module Polisher
