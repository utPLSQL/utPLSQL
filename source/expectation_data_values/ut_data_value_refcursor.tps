create or replace type ut_data_value_refcursor under ut_data_value(
  /*
    class: ut_data_value_refcursor

    Holds information about ref cursor to be processed by assertion
  */


  /*
    var: value

    Holds a cursor number obtained by calling dbms_sql.to_cursor_number(sys_refcursor)
  */
  value number,

  /*
    function: ut_data_value_refcursor

    constructor function that builds a cursor from a sql_statement that was passed in
  */
  constructor function ut_data_value_refcursor(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor) return self as result,

  /*
    function: ut_data_value_refcursor

    constructor function that builds a cursor from a sql_statement that was passed in
  */
  constructor function ut_data_value_refcursor(self in out nocopy ut_data_value_refcursor, a_value varchar2) return self as result
)
/
