create or replace type body ut_results_counter as
  constructor function ut_results_counter(self in out nocopy ut_results_counter) return self as result is
  begin
    self.ignored_count := 0;
    self.success_count := 0;
    self.failure_count := 0;
    self.errored_count := 0;
    return;
  end;

  constructor function ut_results_counter(self in out nocopy ut_results_counter, a_status integer) return self as result is
  begin
    self.ignored_count := case when a_status = ut_utils.tr_ignore then 1 else 0 end;
    self.success_count := case when a_status = ut_utils.tr_success then 1 else 0 end;
    self.failure_count := case when a_status = ut_utils.tr_failure then 1 else 0 end;
    self.errored_count := case when a_status = ut_utils.tr_error then 1 else 0 end;
    return;
  end;

  member procedure sum_counter_values(self in out nocopy ut_results_counter, a_item ut_results_counter) is
  begin
    self.ignored_count  := self.ignored_count + a_item.ignored_count;
    self.success_count  := self.success_count + a_item.success_count;
    self.failure_count  := self.failure_count + a_item.failure_count;
    self.errored_count  := self.errored_count + a_item.errored_count;
  end;

  member function total_count return integer is
  begin
    return self.ignored_count + self.success_count + self.failure_count + self.errored_count;
  end;

  member function result_status return integer is
  begin
    return
      case
      when self.errored_count > 0 then ut_utils.tr_error
      when self.failure_count > 0 then ut_utils.tr_failure
      when self.success_count > 0 then ut_utils.tr_success
      when self.ignored_count > 0 then ut_utils.tr_ignore
      else ut_utils.tr_error
    end;
  end;

end;
/
