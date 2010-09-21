require 'fileutils'
require 'trout/version_list'

module Trout
  class ManagedFile
    attr_reader :filename, :checked_out_url

    def initialize(filename)
      @filename = filename
    end

    def copy_from(git_url)
      checkout(git_url)
      copy_to_destination
      write_url_and_version
      puts "Checked out #{filename} from #{git_url}."
    ensure
      cleanup
    end

    def update
      checkout(previous_git_url)
      if up_to_date?
        puts "#{filename} already up to date."
      else
        merge_to_destination
        write_url_and_version
        puts "Merged changes to #{filename}."
      end
    ensure
      cleanup
    end

    private

    def checkout(git_url)
      run_or_fail("git clone #{git_url} #{working('git')}")
      @checked_out_url = git_url
    end

    def copy_to_destination
      FileUtils.cp(working('git', filename), filename)
    end

    def merge_to_destination
      upstream       = working('upstream')
      at_last_update = working('at_last_update')
      merge          = working('merge')

      FileUtils.cp(working('git', filename), upstream)

      checkout_last_version
      FileUtils.cp(working('git', filename), at_last_update)

      enforce_newline(upstream)
      enforce_newline(at_last_update)
      enforce_newline(filename)

      run("diff3 -mX #{filename} #{at_last_update} #{upstream} > #{merge}")
      FileUtils.mv(merge, filename)
    ensure
      FileUtils.rm_rf(upstream)
      FileUtils.rm_rf(at_last_update)
    end

    def cleanup
      FileUtils.rm_rf(working('git'))
      @checked_out_url = nil
    end

    def prepare_working_directory
      FileUtils.mkdir(working_root)
    end

    def write_url_and_version
      version_list.update(filename,
                          'git_url' => checked_out_url,
                          'version' => checked_out_version)
    end

    def checked_out_version
      git_command("rev-parse master")
    end

    def checkout_last_version
      git_command("checkout #{previous_git_version}")
    end

    def git_command(command)
      run_or_fail("git --git-dir=#{working('git/.git')} --work-tree=#{working('git')} #{command}").strip
    end

    def previous_git_url
      version_list.git_url_for(filename)
    end

    def previous_git_version
      version_list.version_for(filename)
    end

    def up_to_date?
      previous_git_version == checked_out_version
    end

    def version_list
      @version_list ||= VersionList.new('.trout')
    end

    def working(*paths)
      File.join('/tmp', *paths)
    end

    def enforce_newline(path)
      if IO.read(path)[-1].chr != "\n"
        File.open(path, "a") { |file| file.puts }
      end
    end

    def run(command)
      `#{command} 2>&1`
    end

    def run_or_fail(command)
      output = run(command)
      unless $? == 0
        raise "Command failed with status #{$?}:\n#{command}\n#{output}"
      end
      output
    end
  end
end
