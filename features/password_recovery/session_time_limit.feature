Feature: Password recovery - Recovery session time limit

  Scenario: Blaked connects to an expired recovery session
    Given Blaked has initiated a recovery session expiring 1 minute ago
    When he visits step 1 of the recovery session
    Then he is redirected to the password recovery entry-point
    #And a "notice" message containing "Session expirée" appears
