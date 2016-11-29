Feature: Password recovery - Recover with email

  Background:
    Given Blaked has a Gram Account with email "blaked@gadz.org", password "toto01"


  Scenario: Blaked sees his emails address
    And he has initiated a recovery session
    When he visits step 1 of the recovery session
    Then the page has button "Envoie-moi un mail"
    And he see his email addresses

  @email
  Scenario: Blaked receives a mail
    And he has initiated a recovery session
    When he visits step 1 of the recovery session
    And he clicks "Envoie-moi un mail" button
    Then he receives an email entitled "Recupération de mot de passe" from "support@gadz.org"
    And this emails contains a link to recover its session

  Scenario: Blaked change his password with the recovery link
    And he has a recovery session recovering link
    And he is visiting his recovery session recovering link
    When he fills "Nouveau mot de passe" with "G0rguP0wer"
    And he fills "Confirme le mot de passe" with "G0rguP0wer"
    And he clicks "Change mon mot de passe" button
    Then the hashed password "6b60dbe969d518f99bfaea4d308fb77a6cb56de5" is sent on his GrAM Account
