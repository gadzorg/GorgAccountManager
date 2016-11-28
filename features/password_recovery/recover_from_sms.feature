Feature: Password recovery - Recover with SMS

  Background:
    Given Blaked has a Gram Account with email "blaked@gadz.org", password "toto01"
    And Blaked has a Soce Account with tel_mobile "33623456789"

  Scenario: Blaked sees his phone number
    Given he has initiated a recovery session
    When he visit step 1 of the recovery session
    Then he can choose to recover his password by SMS
    And he see his phone number


  Scenario: Blaked receives a SMS
    Given he has initiated a recovery session
    When he clicks "Envoie-moi un SMS" button
    Then an SMS is sent containing a confirmation code from "SOCE"

  Scenario: Blaked fills the confirmation code
    Given he received the recovery code "012345"
    And he is visiting SMS confirmation page
    When he fills "Saisis ce code" with "012345"
    And he clicks "Continuer" button
    Then he is redirected to his recovery link

  Scenario: Blaked fills the wrong the confirmation code
    Given he received the recovery code "012345"
    And he is visiting SMS confirmation page
    When he fills "Saisis ce code" with "987654"
    And he clicks "Continuer" button
    Then he is redirected to the SMS confirmation page
    And an error message containing "Code incorrect" appears
