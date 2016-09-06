create or replace type ut_teamcity_reporter under ut_reporter
(
  constructor function ut_teamcity_reporter return self as result,

  overriding member procedure before_suite(self in out nocopy ut_teamcity_reporter, a_suite in ut_object),

  overriding member procedure after_suite(self in out nocopy ut_teamcity_reporter, a_suite in ut_object),

  overriding member procedure before_suite_item(self in out nocopy ut_teamcity_reporter, a_suite in ut_object, a_item_index pls_integer),

  overriding member procedure after_suite_item(self in out nocopy ut_teamcity_reporter, a_suite in ut_object, a_item_index pls_integer)
)
not final
/
