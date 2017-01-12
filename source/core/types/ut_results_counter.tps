create or replace type ut_results_counter as object(
  ignored_count integer,
  success_count integer,
  failure_count integer,
  errored_count integer,
  constructor function ut_results_counter(self in out nocopy ut_results_counter) return self as result,
  constructor function ut_results_counter(self in out nocopy ut_results_counter, a_status integer) return self as result,
  member procedure sum_counter_values(self in out nocopy ut_results_counter, a_item ut_results_counter),
  member function total_count return integer,
  member function result_status return integer
)
/
