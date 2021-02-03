Feature: Password recovery - Find a user

  Scenario: Blaked is trying to recover its password
    Given Blaked has a Gram Account with email "blaked@gadz.org"
    When he connect to the password recovery entry-point
    And he fills "Entre ici ton identifiant OU n° de sociétaire" with "blaked@gadz.org"
    And he clicks "Suivant" button
    Then he is redirected to choose his recovering method

  Scenario: Blaked try to recover its account with the wrong email address
    Given Blaked has a Gram Account with email "blaked@gadz.org"
    And There is no gram account with email address "blacked@gadz.org"
    And There is no gorgmail account with email address "blacked@gadz.org"
    When he connect to the password recovery entry-point
    And he fills "Entre ici ton identifiant OU n° de sociétaire" with "blacked@gadz.org"
    And he clicks "Suivant" button
    Then he is redirected to recovery entry-point
    And he is asked to try again
    And he fills "Entre ici ton identifiant OU n° de sociétaire" with "blacked@gadz.org"
