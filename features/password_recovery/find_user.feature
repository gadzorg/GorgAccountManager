Feature: Password recovery - Find a user

  Scenario: Blaked is trying to recover its password
    Given Blaked has a Gram Account with email address equal to "blaked@gadz.org"
    When he connect to the password recovery system
    And he search "blaked@gadz.org" in password recovery
    Then he is redirected to choose his recovering method

  Scenario: Blaked try to recover its account with the wrong email address
    Given Blaked has a Gram Account with email address equal to "blaked@gadz.org"
    And There is no gram account with email address "blacked@gadz.org"
    When he connect to the password recovery system
    And he search "blacked@gadz.org" in password recovery
    Then he is asked to try again