require 'yaml'

module Trout
  class VersionList
    attr_reader :path, :entries

    def initialize(path)
      @path = path
    end

    def git_url_for(filename)
      read
      entries[filename]['git_url']
    end

    def version_for(filename)
      read
      entries[filename]['version']
    end

    def update(filename, info)
      read
      entries[filename] ||= {}
      entries[filename].update(info)
      write
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
