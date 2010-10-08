Feature:
  In order to find opportunities with multiple conditions
  API callers
  should be able to search for opportunities

  Scenario: API search for opportunities in available state
    Given an opportunity
    When I call meta_search with "state: available"
    Then I should see json "{name: L12345, state: available}"
