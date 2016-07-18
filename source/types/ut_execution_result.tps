create or replace type ut_execution_result as object
(

  start_time     timestamp with time zone,
  end_time       timestamp with time zone,
  result         integer(1),

  constructor function ut_execution_result(a_start_time timestamp with time zone default current_timestamp) return self as result,
  member function result_to_char(self in ut_execution_result) return varchar2
)
not final
/
