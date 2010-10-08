Feature:
  In order to find opportunities with multiple conditions
  API callers
  should be able to search for opportunities

  Scenario: API search for opportunities in available state
    Given an opportunity with params:
      | name  | L12345    |
      | stage | available |
    When I go with search params to the opportunities meta_search page:
      | stage_equals  | available |
      | name_contains | 123       |
    Then I should see JSON:
      """
      [{"opportunity":{"name":"# L12345"}}]
      """
