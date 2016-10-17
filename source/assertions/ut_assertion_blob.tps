create or replace type ut_assertion_blob under ut_assertion
(
  overriding member procedure to_equal(self in ut_assertion_blob, a_expected blob, a_nulls_are_equal boolean := null)
)
/
