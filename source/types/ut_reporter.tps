create or replace type ut_reporter force as object
(
  name varchar2(250 char),

  member procedure begin_suite(self in out nocopy ut_reporter, a_suite in ut_object),
  member procedure begin_test(self in out nocopy ut_reporter, a_test in ut_object),
	member procedure on_assert(self in out nocopy ut_reporter, a_assert in ut_object),
  member procedure end_test(self in out nocopy ut_reporter, a_test in ut_object),
  member procedure end_suite(self in out nocopy ut_reporter, a_suite in ut_object)

)
not instantiable not final
/
