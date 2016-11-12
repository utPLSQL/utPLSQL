create or replace type ut_composite_object force under ut_object
(
  items      ut_objects_list,
	
  member procedure calc_execution_result(self in out nocopy ut_composite_object),
  member function item_index(a_object_name varchar2) return pls_integer,
  member procedure add_item(self in out nocopy ut_composite_object, a_item ut_object)
) not final not instantiable
/
