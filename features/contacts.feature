Feature:
  In order to find contacts with multiple conditions
  API callers
  should be able to search for contacts

  Scenario: API search for contacts by id, first_name, last_name, phone, fax or email
    Given an contact with params:
      | id         | 1             |
      | first_name | Bob           |
      | last_name  | Brown         |
      | phone      | 1234567       |
      | fax        | 7654321       |
      | email      | bob@brown.com |
    When I go with search params to the contacts meta_search page:
      | search[first_name_or_last_name_or_phone_or_fax_or_email_contains] | brown |
    Then I should see JSON:
      """
      [{"contact":{"id":1,"name":"Bob Brown"}}]
      """
    When I go with search params to the contacts meta_search page:
      | search[first_name_or_last_name_or_phone_or_fax_or_email_contains] | 54321 |
      | only                                                              | id, name, fax |
    Then I should see JSON:
      """
      [{"contact":{"id":1,"name":"Bob Brown","fax":"7654321"}}]
      """
