Gem::Specification.new do |s|
    s.name        = %q{trout}
    s.version     = '0.1'
    s.summary     = %q{So your common files can swim upstream.}
    s.description = %q{Trout allows you to maintain a base version of special
      files (like Gemfile) in one repository, and then syncronize just that
      file with several other repositories. This means that you can update your
      Gemfile in the master repository, and then get the latest of all the
      common gems that you use in each project just by running "trout update
      Gemfile".}

    s.files        = Dir['[A-Z]*', 'lib/**/*.rb', 'features/**/*', 'bin/**/*']
    s.require_path = 'lib'
    s.test_files   = Dir['features/**/*']

    s.default_executable = 'trout'
    s.executables        = ['trout']

    s.has_rdoc = false

    s.authors = ["Joe Ferris"]
    s.email   = %q{jferris@thoughtbot.com}
    s.homepage = "http://github.com/jferris/trout"

    s.add_development_dependency('cucumber')
    s.add_development_dependency('aruba')

    s.platform = Gem::Platform::RUBY
    s.rubygems_version = %q{1.2.0}
end

