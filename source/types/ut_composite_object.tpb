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

  -- Member procedures and functions
  member function item_index(a_object_name varchar2) return pls_integer is
    l_item_index pls_integer := self.items.first;
    c_lowered_obj_name constant varchar2(4000 char) := lower(trim(a_object_name));
    l_result pls_integer;
  begin
    while l_item_index is not null loop
      if self.items(l_item_index) is of(ut_test_object) and treat(self.items(l_item_index) as ut_test_object)
        .object_name = c_lowered_obj_name then
        l_result := l_item_index;
        exit;
      end if;
      l_item_index := self.items.next(l_item_index);
    end loop;
    return l_result;
  end item_index;

  member procedure add_item(self in out nocopy ut_composite_object, a_item ut_object) is
  begin
    self.items.extend;
    self.items(self.items.last) := a_item;
  end add_item;

end;
/
