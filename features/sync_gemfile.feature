Feature: sync a Gemfile between two repositories

  Scenario: sync a Gemfile
    Given a directory named "upstream_repo"
    And a directory named "child_repo"
    And a file named "upstream_repo/Gemfile" with:
      """
      source "http://rubygems.org"
      gem "rails"
      gem "mysql"
      """
    When I cd to "upstream_repo"
    And I run "git init"
    And I run "git add Gemfile"
    And I run "git commit -m 'Added gemfile'"
    And I cd to "../child_repo"
    And I run "trout checkout Gemfile ../upstream_repo"
    Then the output should contain:
      """
      Checked out Gemfile from ../upstream_repo.
      """
    And I run "cat Gemfile"
    Then the output should contain:
      """
      source "http://rubygems.org"
      gem "rails"
      gem "mysql"
      """
    When I cd to "../upstream_repo"
    And I write to "Gemfile" with:
      """
      source "http://rubygems.org"
      gem "rails"
      gem "postgresql"
      """
    When I run "git add Gemfile"
    And I run "git commit -m 'Changed to postgres'"
    And I cd to "../child_repo"
    When I append to "Gemfile" with:
      """

      gem "redcloth"
      """
    When I run "trout update Gemfile"
    Then the output should contain:
      """
      Merged changes to Gemfile.
      """
    When I run "cat Gemfile"
    Then the output should contain:
      """
      source "http://rubygems.org"
      gem "rails"
      <<<<<<< Gemfile
      gem "mysql"
      gem "redcloth"
      =======
      gem "postgresql"
      >>>>>>> /tmp/upstream
      """
    When I write to "Gemfile" with:
      """
      source "http://rubygems.org"
      gem "rails"
      gem "mysql"
      gem "redcloth"
      """
    When I run "trout update Gemfile"
    Then the output should contain:
      """
      Gemfile already up to date.
      """
    And I run "cat Gemfile"
    Then the output should contain:
      """
      source "http://rubygems.org"
      gem "rails"
      gem "mysql"
      gem "redcloth"
      """

