create or replace type ut_test_call_params force as object
(
    object_name        varchar2(32 char),
		test_procedure     varchar2(32 char),
		owner_name         varchar2(32 char),
		setup_procedure    varchar2(32 char),
		teardown_procedure varchar2(32 char),
		
		static procedure execute_call(a_owner varchar2, a_object varchar2, a_subprogram varchar2),
		--member function is_valid(self in ut_test_call_params) return boolean,
		member procedure validate_params(self in ut_test_call_params, a_result out boolean),
		member procedure setup(self in ut_test_call_params),
		member procedure run_test(self in ut_test_call_params),
		member procedure teardown(self in ut_test_call_params)
) final
/
