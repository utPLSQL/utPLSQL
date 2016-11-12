create or replace type ut_expectation_refcursor under ut_expectation
(
  overriding member procedure to_equal(self in ut_expectation_refcursor, a_expected sys_refcursor, a_nulls_are_equal boolean := null)
)
/
