create or replace type ut_assertion_boolean under ut_assertion
(
  overriding member procedure to_equal(self in ut_assertion_boolean, a_expected boolean, a_nulls_are_equal boolean := null),
  member procedure to_be_true(self in ut_assertion_boolean)
)
/
