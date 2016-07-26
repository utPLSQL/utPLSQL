create or replace type ut_suite_reporter force as object
(
  name varchar2(250 char),

  not instantiable member procedure begin_suite(self in out nocopy ut_suite_reporter, a_suite in ut_object),
  not instantiable member procedure begin_test(self in out nocopy ut_suite_reporter, a_test in ut_object),
	not instantiable member procedure on_assert(self in out nocopy ut_suite_reporter, an_assert in ut_object),
  not instantiable member procedure end_test(self in out nocopy ut_suite_reporter, a_test in ut_object),
  not instantiable member procedure end_suite(self in out nocopy ut_suite_reporter, a_suite in ut_object)

)
not instantiable not final
/
