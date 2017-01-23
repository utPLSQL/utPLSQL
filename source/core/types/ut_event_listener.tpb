create or replace type body ut_event_listener is

  constructor function ut_event_listener(self in out nocopy ut_event_listener, a_reporters ut_reporters) return self as result is
  begin
    reporters := a_reporters;
    return;
  end;

  overriding member procedure fire_before_event(self in out nocopy ut_event_listener, a_event_name varchar2, a_item ut_suite_item_base) is
  begin
    self.fire_event('before', a_event_name, a_item);
  end;

  overriding member procedure fire_after_event(self in out nocopy ut_event_listener, a_event_name varchar2, a_item ut_suite_item_base) is
  begin
    self.fire_event('after', a_event_name, a_item);
  end;

  overriding member procedure fire_event(self in out nocopy ut_event_listener, a_event_timing varchar2, a_event_name varchar2, a_item ut_suite_item_base) is
  begin
    for i in 1..self.reporters.count loop
      if a_event_timing = 'before' then
        if a_event_name = ut_utils.gc_run then
          self.reporters(i).before_calling_run(treat(a_item as ut_run));
        elsif a_event_name = ut_utils.gc_suite then
          self.reporters(i).before_calling_suite(treat(a_item as ut_logical_suite));
        elsif a_event_name = ut_utils.gc_before_all then
          self.reporters(i).before_calling_before_all(treat(a_item as ut_logical_suite));
        elsif a_event_name = ut_utils.gc_before_each then
          self.reporters(i).before_calling_before_each(treat(a_item as ut_logical_suite));
        elsif a_event_name = ut_utils.gc_test then
          self.reporters(i).before_calling_test(treat(a_item as ut_test));
        elsif a_event_name = ut_utils.gc_before_test then
          self.reporters(i).before_calling_before_test(treat(a_item as ut_test));
        elsif a_event_name = ut_utils.gc_test_execute then
          self.reporters(i).before_calling_test_execute(treat(a_item as ut_test));
        elsif a_event_name = ut_utils.gc_after_test then
          self.reporters(i).before_calling_after_test(treat(a_item as ut_test));
        elsif a_event_name = ut_utils.gc_after_each then
          self.reporters(i).before_calling_after_each(treat(a_item as ut_logical_suite));
        elsif a_event_name = ut_utils.gc_after_all then
          self.reporters(i).before_calling_after_all(treat(a_item as ut_logical_suite));
        else
          raise_application_error(ut_utils.gc_invalid_rep_event_name,'Inavlid reporting event name - '|| nvl(a_event_name,'NULL'));
        end if;
      elsif a_event_timing = 'after' then
        if a_event_name =  ut_utils.gc_run then
          self.reporters(i).after_calling_run(treat(a_item as ut_run));
        elsif a_event_name = ut_utils.gc_suite then
          self.reporters(i).after_calling_suite(treat(a_item as ut_logical_suite));
        elsif a_event_name = ut_utils.gc_before_all then
          self.reporters(i).after_calling_before_all(treat(a_item as ut_logical_suite));
        elsif a_event_name = ut_utils.gc_before_each then
          self.reporters(i).after_calling_before_each(treat(a_item as ut_logical_suite));
        elsif a_event_name = ut_utils.gc_test then
          self.reporters(i).after_calling_test(treat(a_item as ut_test));
        elsif a_event_name = ut_utils.gc_before_test then
          self.reporters(i).after_calling_before_test(treat(a_item as ut_test));
        elsif a_event_name = ut_utils.gc_test_execute then
          self.reporters(i).after_calling_test_execute(treat(a_item as ut_test));
        elsif a_event_name = ut_utils.gc_after_test then
          self.reporters(i).after_calling_after_test(treat(a_item as ut_test));
        elsif a_event_name = ut_utils.gc_after_each then
          self.reporters(i).after_calling_after_each(treat(a_item as ut_logical_suite));
        elsif a_event_name = ut_utils.gc_after_all then
          self.reporters(i).after_calling_after_all(treat(a_item as ut_logical_suite));
        else
          raise_application_error(ut_utils.gc_invalid_rep_event_name,'Inavlid reporting event name - '|| nvl(a_event_name,'NULL'));
        end if;
      else
        raise_application_error(ut_utils.gc_invalid_rep_event_time,'Inavlid reporting event time - '|| nvl(a_event_timing,'NULL'));
      end if;
    end loop;

  end;

end;
/
