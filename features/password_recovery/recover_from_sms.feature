@ovh
Feature: Password recovery - Recover with SMS

  Background:
    Given Blaked has a Gram Account with email "blaked@gadz.org", password "toto01", uuid "559bb0aa-ddac-4607-ad41-7e520ee40819"
    And Blaked has a Soce Account with tel_mobile "+33623456789", uuid "559bb0aa-ddac-4607-ad41-7e520ee40819"

  Scenario: Blaked sees his phone number
    Given he has initiated a recovery session
    When he visits step 1 of the recovery session
    Then the page has button "Envoie-moi un sms"
    And he sees "+3362xxxxxx89"

  Scenario: Blaked receives a SMS
    Given he has initiated a recovery session
    And he visits step 1 of the recovery session
    When he clicks "Envoie-moi un sms" button
    Then an SMS is sent
    And this SMS is sent from "SOCE"
    And this SMS contains a confirmation code

  Scenario: Blaked fills the confirmation code
    Given he has initiated a recovery session
    And he received the recovery code "012345"
    And he visits SMS confirmation page
    When he fills "Saisis ce code" with "012345"
    And he clicks "Continuer" button
    Then he is redirected to his recovery link

  Scenario: Blaked fills the wrong the confirmation code
    Given he has initiated a recovery session
    And he received the recovery code "012345"
    And he visits SMS confirmation page
    When he fills "Saisis ce code" with "987654"
    And he clicks "Continuer" button
    Then he is redirected to the SMS confirmation page
    And a "alert" message containing "Code invalide" appears
