create or replace type body ut_composite_object is
  member procedure calc_execution_result(self in out nocopy ut_composite_object) is
    v_result integer(1) := ut_utils.tr_success;
  begin
    for i in 1 .. self.items.count loop
      v_result := greatest(self.items(i).result, v_result);
      exit when v_result = ut_utils.tr_error;
    end loop;
    self.result := v_result;
  end;

end;
/
