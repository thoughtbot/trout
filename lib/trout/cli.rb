require 'trout/managed_file'

module Trout
  class CLI
    def self.run(arguments)
      new(arguments).run
    end

    attr_reader :arguments, :git_url, :filename, :file, :command

    def initialize(arguments)
      self.arguments = arguments
      self.file = ManagedFile.new(filename)
    end

    def run
      case command
      when 'checkout'
        self.git_url = arguments[2]
        file.copy_from(git_url)
      when 'update'
        file.update
      end
    end

    private

    def arguments=(arguments)
      @arguments    = arguments
      self.command  = arguments[0]
      self.filename = arguments[1]
    end

    attr_writer :git_url, :filename, :file, :command
  end
end
