require 'optparse'
require 'trout/managed_file'

module Trout
  class CLI
    def self.run(arguments)
      new(arguments).run
    end

    attr_accessor :command, :option_parser, :arguments, :file

    def initialize(arguments)
      self.arguments     = arguments
      self.option_parser = parse_options
    end

    def run
      case command
      when 'checkout'
        build_file
        git_url = next_argument
        end_arguments
        file.copy_from(git_url)
      when 'update'
        build_file
        end_arguments
        file.update
      when 'help', nil
        puts option_parser
        if arguments_left?
          puts
          usage_for(next_argument)
        end
      else
        unknown_command(command)
      end
    end

    private

    def parse_options
      option_parser = OptionParser.new do |parser|
        parser.banner =
          "trout helps you sync individual files from other git repositories.\n\n" +
          "Usage: trout [options] command arguments"

        parser.separator ""
        parser.separator "Options:"
        parser.separator ""

        parser.on("-h", "--help", "View this help document")

        parser.separator ""
        parser.separator "Commands:"
        parser.separator ""
        parser.separator "  checkout - start tracking a file from another repository"
        parser.separator "  help     - get usage details for a specific command"
        parser.separator "  update   - synchronize changes to a tracked file"
      end

      option_parser.parse!(arguments)

      if arguments_left?
        self.command = next_argument
      else
        self.command = 'help'
      end

      option_parser
    end

    def next_argument
      arguments.shift or invalid_arguments
    end

    def arguments_left?
      !arguments.empty?
    end

    def invalid_arguments
      puts "I don't understand the options you provided."
      puts %{Run "trout help #{command}" for usage information.}
      exit
    end

    def end_arguments
      invalid_arguments if arguments_left?
    end

    def build_file
      self.file = ManagedFile.new(next_argument)
    end

    def usage_for(command)
      case command
      when 'checkout'
        puts "Usage: trout checkout filename git_url"
      when 'update'
        puts "Usage: trout update filename"
      else
        unknown_command(command)
      end
    end

    def unknown_command(command)
      puts %{I don't know how to "#{command}."}
      puts %{Run "trout help" for usage information.}
    end
  end
end
