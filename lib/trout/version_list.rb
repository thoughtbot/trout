require 'yaml'
require 'trout/managed_file'

module Trout
  class VersionList
    attr_reader :path, :entries

    def initialize(path)
      @path = path
    end

    def [](filename)
      read
      attributes = entries[filename] || { :filename => filename }
      ManagedFile.new(attributes)
    end

    def []=(filename, managed_file)
      read
      entries[filename] = managed_file.to_hash
      write
    end

    def <<(managed_file)
      self[managed_file.filename] = managed_file
    end

    private

    def read
      if File.exist?(path)
        @entries = YAML.load(IO.read(path))
      else
        @entries = {}
      end
    end

    def write
      File.open(path, 'w') do |file|
        file.write(YAML.dump(entries))
      end
    end
  end
end
