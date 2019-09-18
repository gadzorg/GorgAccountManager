Feature: display statistics

  Scenario: Charts are loaded
    Given a logged admin
    And within admin dropdown he clicks "Stats" button
    Then he sees "Type de recheches"
