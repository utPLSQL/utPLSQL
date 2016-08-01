create or replace type ut_composite_reporter under ut_suite_reporter
(
  reporters ut_reporters_list,

  constructor function ut_composite_reporter(the_reporters ut_reporters_list default ut_reporters_list())
    return self as result,
  member procedure add_reporter(self in out nocopy ut_composite_reporter, a_reporter ut_suite_reporter),
  member procedure remove_reporter(self in out nocopy ut_composite_reporter, an_index pls_integer),

  overriding member procedure begin_suite(self in out nocopy ut_composite_reporter, a_suite in ut_object),
  overriding member procedure begin_test(self in out nocopy ut_composite_reporter, a_test ut_object),
	overriding member procedure on_assert(self in out nocopy ut_composite_reporter, an_assert ut_object),
  overriding member procedure end_test(self in out nocopy ut_composite_reporter, a_test ut_object),
  overriding member procedure end_suite(self in out nocopy ut_composite_reporter, a_suite ut_object)

)
not final
/
