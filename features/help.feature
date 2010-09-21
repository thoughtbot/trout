Feature: get help on using trout

  Scenario Outline: Specify an unknown command
    When I run "trout <arguments>"
    Then the output should contain:
      """
      I don't know how to "<command>."
      Run "trout help" for usage information.
      """
    Examples:
      | arguments | command |
      | swim      | swim    |
      | help swim | swim    |

  Scenario Outline: Run an invalid command
    When I run "<invalid command>"
    Then the output should contain:
      """
      I don't understand the options you provided.
      Run "<help command>" for usage information.
      """
    Examples:
      | invalid command               | help command        |
      | trout checkout                | trout help checkout |
      | trout checkout file           | trout help checkout |
      | trout checkout file url extra | trout help checkout |
      | trout update                  | trout help update   |
      | trout update file extra       | trout help update   |

  Scenario Outline: Ask for help
    When I run "<help command>"
    Then the output should contain:
      """
      trout helps you sync individual files from other git repositories.
      """
    And the output should contain:
      """
      Commands:
      """
    And the output should not contain:
      """
      I don't know how
      """
    Examples:
      | help command |
      | trout        |
      | trout help   |
      | trout -h     |
      | trout --help |

  Scenario Outline: Ask for usage for a particular command
    When I run "trout help <command>"
    Then the output should contain:
      """
      Usage: trout <command> <usage>
      """
    Examples:
      | command  | usage            |
      | checkout | filename git_url |
      | update   | filename         |
