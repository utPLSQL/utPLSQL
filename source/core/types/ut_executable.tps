create or replace type ut_executable force as object
(
  owner_name         varchar2(32 char),
  object_name        varchar2(32 char),
  procedure_name     varchar2(32 char),
		
  static procedure execute_call(
    a_owner varchar2, a_object varchar2, a_procedure_name varchar2,
    a_error_stack out nocopy varchar2, a_error_backtrace out nocopy varchar2
  ),
  member function is_valid(a_proc_type varchar2) return boolean,
	member function form_name return varchar2,
	member procedure do_execute(self in ut_executable),
	member procedure do_execute(self in ut_executable, a_error_stack out nocopy varchar2, a_error_backtrace out nocopy varchar2)
) final
/
