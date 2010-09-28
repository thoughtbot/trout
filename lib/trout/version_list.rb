require 'yaml'
require 'trout/managed_file'

module Trout
  class VersionList
    FILE_VERSION = '1.0'

    attr_accessor :path, :data, :files

    def initialize(path)
      @path = path
    end

    def [](filename)
      read
      attributes = files[filename] || { :filename => filename }
      ManagedFile.new(attributes)
    end

    def []=(filename, managed_file)
      read
      files[filename] = managed_file.to_hash
      write
    end

    def <<(managed_file)
      self[managed_file.filename] = managed_file
    end

    private

    def read
      if File.exist?(path)
        self.data = YAML.load(IO.read(path))
      else
        self.data = { :files   => {},
                      :version => FILE_VERSION }
      end
      self.files = data[:files]
    end

    def write
      File.open(path, 'w') do |file|
        file.write(YAML.dump(data))
      end
    end
  end
end
