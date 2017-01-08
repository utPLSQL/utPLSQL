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
    l_method    varchar2(250) := a_event_timing||'_calling_'||a_event_name;
    l_call_stmt varchar2(32767 byte);
  begin
    l_call_stmt :=
      'declare' ||
      '  v_reporter ut_reporter_base := :a_reporter; ' ||
      'begin' ||
      '  v_reporter.'||l_method||'( treat( :a_item as '||a_item.self_type||')); ' ||
      '  :a_reporter := v_reporter; ' ||
      'end;';
    for i in 1..self.reporters.count loop
      execute immediate l_call_stmt using in out self.reporters(i), in treat(a_item as ut_suite_item);
    end loop;

  end;

end;
/
