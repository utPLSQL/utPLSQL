create or replace type body ut_composite_object is
  member procedure calc_execution_result(self in out nocopy ut_composite_object) is
    l_result integer(1) := ut_utils.tr_success;
  begin
    for i in 1 .. self.items.count loop
      l_result := greatest(self.items(i).result, l_result);
      exit when l_result = ut_utils.tr_error;
    end loop;
    self.result := l_result;
  end;

end;
/
