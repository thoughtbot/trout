require 'fileutils'

module Trout
  class ManagedFile
    attr_accessor :filename, :git_url, :version, :latest_version, :source_root

    def initialize(attributes)
      self.filename    = attributes[:filename]
      self.git_url     = attributes[:git_url]
      self.version     = attributes[:version]
      self.source_root = attributes[:source_root] || '/'
    end

    def checkout
      clone_repository
      copy_to_destination
      puts "Checked out #{filename} from #{git_url}."
    ensure
      cleanup
    end

    def update
      clone_repository
      if up_to_date?
        puts "#{filename} already up to date."
      else
        merge_to_destination
        puts "Merged changes to #{filename}."
      end
    ensure
      cleanup
    end

    def to_hash
      { :filename    => filename,
        :git_url     => git_url,
        :version     => version,
        :source_root => source_root }
    end

    private

    def clone_repository
      run_or_fail("git clone #{git_url} #{working('git')}")
      self.latest_version = checked_out_version
    end

    def copy_to_destination
      FileUtils.cp(working('git', source_path), filename)
      self.version = checked_out_version
    end

    def merge_to_destination
      upstream       = working('upstream')
      at_last_update = working('at_last_update')
      merge          = working('merge')

      FileUtils.cp(working('git', source_path), upstream)

      checkout_last_version
      FileUtils.cp(working('git', source_path), at_last_update)

      enforce_newline(upstream)
      enforce_newline(at_last_update)
      enforce_newline(filename)

      run("diff3 -mE #{filename} #{at_last_update} #{upstream} > #{merge}")
      FileUtils.mv(merge, filename)

      self.version = latest_version
    ensure
      FileUtils.rm_rf(upstream)
      FileUtils.rm_rf(at_last_update)
    end

    def cleanup
      FileUtils.rm_rf(working('git'))
    end

    def prepare_working_directory
      FileUtils.mkdir(working_root)
    end

    def checked_out_version
      git_command("rev-parse master")
    end

    def checkout_last_version
      git_command("checkout #{version}")
    end

    def git_command(command)
      run_or_fail("git --git-dir=#{working('git/.git')} --work-tree=#{working('git')} #{command}").strip
    end

    def up_to_date?
      version == latest_version
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

    def source_path
      File.join(source_root, filename)
    end
  end
end
