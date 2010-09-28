Feature: sync a file nested within a directory the source repo

  Scenario: sync a nested file
    Given a directory named "upstream_repo"
    And a directory named "child_repo"
    And a file named "upstream_repo/sub/dir/file" with:
      """
      contents
      """
    When I cd to "upstream_repo"
    And I run "git init"
    And I run "git add sub"
    And I run "git commit -m 'Added file'"
    And I cd to "../child_repo"
    And I run "trout checkout --source-root sub/dir file ../upstream_repo"
    Then the output should contain:
      """
      Checked out file from ../upstream_repo.
      """
    And I run "cat file"
    Then the output should contain:
      """
      contents
      """
    When I cd to "../upstream_repo"
    And I write to "sub/dir/file" with:
      """
      new contents
      """
    When I run "git add sub"
    And I run "git commit -m 'updated file'"
    And I cd to "../child_repo"
    When I run "trout update file"
    Then the output should contain:
      """
      Merged changes to file.
      """
    When I run "cat file"
    Then the output should contain:
      """
      new contents
      """

