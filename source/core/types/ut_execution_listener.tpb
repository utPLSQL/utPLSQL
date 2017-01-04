create or replace type body ut_execution_listener is

  constructor function ut_execution_listener(self in out nocopy ut_execution_listener, a_reporters ut_reporters) return self as result is
  begin
    reporters := a_reporters;
    return;
  end;

  overriding member procedure fire_before_event(self in out nocopy ut_execution_listener, a_event_name varchar2, a_item ut_suite_item) is
    begin
      self.fire_event('before', a_event_name, a_item);
    end;

  overriding member procedure fire_after_event(self in out nocopy ut_execution_listener, a_event_name varchar2, a_item ut_suite_item) is
    begin
      self.fire_event('after', a_event_name, a_item);
    end;

  overriding member procedure fire_event(self in out nocopy ut_execution_listener, a_event_timing varchar2, a_event_name varchar2, a_item ut_suite_item) is
      l_method varchar2(250) := a_event_timing||'_calling_'||a_event_name;
    begin
      execute immediate
        'declare ' || chr(10) ||
        '  l_listener ut_execution_listener := :a_listener;'  || chr(10) ||
        'begin ' || chr(10) ||
        '  for i in 1 .. l_listener.reporters.count loop' || chr(10) ||
        '      l_listener.reporters(i).'||l_method||'( :a_item );' || chr(10) ||
        '  end loop;' || chr(10) ||
        '  :a_result := l_listener;' || chr(10) ||
        'end;'
      using in self, in a_item, out self;
    end;

end;
/
