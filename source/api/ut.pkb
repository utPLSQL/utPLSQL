create or replace package body ut is

  function expect(a_actual in anydata, a_message varchar2 := null) return ut_expectation_anydata is
  begin
    return ut_expectation_anydata(ut_data_value_anydata(a_actual), a_message);
  end;

  function expect(a_actual in blob, a_message varchar2 := null) return ut_expectation_blob is
  begin
    return ut_expectation_blob(ut_data_value_blob(a_actual), a_message);
  end;

  function expect(a_actual in boolean, a_message varchar2 := null) return ut_expectation_boolean is
  begin
    return ut_expectation_boolean(ut_data_value_boolean(a_actual), a_message);
  end;

  function expect(a_actual in clob, a_message varchar2 := null) return ut_expectation_clob is
  begin
    return ut_expectation_clob(ut_data_value_clob(a_actual), a_message);
  end;

  function expect(a_actual in date, a_message varchar2 := null) return ut_expectation_date is
  begin
    return ut_expectation_date(ut_data_value_date(a_actual), a_message);
  end;

  function expect(a_actual in number, a_message varchar2 := null) return ut_expectation_number is
  begin
    return ut_expectation_number(ut_data_value_number(a_actual), a_message);
  end;

  function expect(a_actual in timestamp_unconstrained, a_message varchar2 := null) return ut_expectation_timestamp is
  begin
    return ut_expectation_timestamp(ut_data_value_timestamp(a_actual), a_message);
  end;

  function expect(a_actual in timestamp_ltz_unconstrained, a_message varchar2 := null) return ut_expectation_timestamp_ltz is
  begin
    return ut_expectation_timestamp_ltz(ut_data_value_timestamp_ltz(a_actual), a_message);
  end;

  function expect(a_actual in timestamp_tz_unconstrained, a_message varchar2 := null) return ut_expectation_timestamp_tz is
  begin
    return ut_expectation_timestamp_tz(ut_data_value_timestamp_tz(a_actual), a_message);
  end;

  function expect(a_actual in varchar2, a_message varchar2 := null) return ut_expectation_varchar2 is
  begin
    return ut_expectation_varchar2(ut_data_value_varchar2(a_actual), a_message);
  end;

  function expect(a_actual in sys_refcursor, a_message varchar2 := null) return ut_expectation_refcursor is
  begin
    return ut_expectation_refcursor(ut_data_value_refcursor(a_actual), a_message);
  end;

  function expect(a_actual in yminterval_unconstrained, a_message varchar2 := null) return ut_expectation_yminterval is
  begin
    return ut_expectation_yminterval(ut_data_value_yminterval(a_actual), a_message);
  end;

  function expect(a_actual in dsinterval_unconstrained, a_message varchar2 := null) return ut_expectation_dsinterval is
  begin
    return ut_expectation_dsinterval(ut_data_value_dsinterval(a_actual), a_message);
  end;

  procedure fail(a_message in varchar2) is
  begin
    ut_assert_processor.report_error(a_message);
  end;

  procedure run_autonomous(a_paths ut_varchar2_list, a_reporter ut_reporter_base, a_color_console integer) is
    pragma autonomous_transaction;
  begin
    ut_runner.run(a_paths, a_reporter, ut_utils.int_to_boolean(a_color_console));
    rollback;
  end;

  function run(a_paths ut_varchar2_list, a_reporter ut_reporter_base := ut_documentation_reporter(), a_color_console integer := 0) return ut_varchar2_list pipelined is
    l_reporter  ut_reporter_base := coalesce(a_reporter, ut_documentation_reporter());
    l_lines     sys_refcursor;
    l_line      varchar2(4000);
  begin
    run_autonomous(a_paths, l_reporter, a_color_console);
    l_lines := ut_output_buffer.get_lines_cursor(l_reporter.reporter_id);
    loop
      fetch l_lines into l_line;
      exit when l_lines%notfound;
      pipe row(l_line);
    end loop;
    close l_lines;
  end;

  function run(a_path varchar2 := null, a_reporter ut_reporter_base := ut_documentation_reporter(), a_color_console integer := 0) return ut_varchar2_list pipelined is
    l_reporter  ut_reporter_base := coalesce(a_reporter, ut_documentation_reporter());
    l_paths     ut_varchar2_list := ut_varchar2_list(coalesce(a_path, sys_context('userenv', 'current_schema')));
    l_lines     sys_refcursor;
    l_line      varchar2(4000);
  begin
    run_autonomous(l_paths, a_reporter, a_color_console );
    l_lines := ut_output_buffer.get_lines_cursor(l_reporter.reporter_id);
    loop
      fetch l_lines into l_line;
      exit when l_lines%notfound;
      pipe row(l_line);
    end loop;
    close l_lines;
  end;

  procedure run(a_paths ut_varchar2_list, a_reporter ut_reporter_base := ut_documentation_reporter(), a_color_console boolean := false) is
    l_reporter  ut_reporter_base := coalesce(a_reporter, ut_documentation_reporter());
  begin
    ut_runner.run(a_paths, l_reporter, a_color_console);
    ut_output_buffer.lines_to_dbms_output(l_reporter.reporter_id);
  end;

  procedure run(a_path varchar2 := null, a_reporter ut_reporter_base := ut_documentation_reporter(), a_color_console boolean := false) is
    l_paths  ut_varchar2_list := ut_varchar2_list(coalesce(a_path, sys_context('userenv', 'current_schema')));
  begin
    ut.run(l_paths, a_reporter, a_color_console);
  end;

end ut;
/
