create or replace type ut_composite_object force under ut_object
(
  items      ut_objects_list,
	
	member procedure calc_execution_result(self in out nocopy ut_composite_object)
) not final not instantiable
/
