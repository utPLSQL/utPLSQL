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
    l_method varchar2(250) := a_event_timing||'_calling_'||a_event_name;
    l_reporter ut_reporter;
    l_call_stmt varchar2(32767);
  begin
    l_call_stmt := 'begin :a_reporter.'||l_method||'( :a_item ); end;';
    
    for i in 1..self.reporters.count loop
      l_reporter := self.reporters(i);
      execute immediate l_call_stmt using in out l_reporter, in a_item;
      self.reporters(i) := l_reporter;
    end loop;

  end;

end;
/
