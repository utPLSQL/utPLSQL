create or replace type ut_test_call_params force as object
(
  owner_name         varchar2(32 char),
  object_name        varchar2(32 char),
  procedure_name     varchar2(32 char),
		
  static procedure execute_call(a_owner varchar2, a_object varchar2, a_procedure_name varchar2),
  member function validate_params(a_proc_type varchar2) return boolean,
	member function form_name return varchar2,
	member procedure execute(self in ut_test_call_params)
) final
/
