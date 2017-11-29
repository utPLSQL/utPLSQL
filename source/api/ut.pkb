create or replace package body ut is

  /*
  utPLSQL - Version 3
  Copyright 2016 - 2017 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  g_nls_date_format varchar2(4000);

  function version return varchar2 is
  begin
    return ut_runner.version();
  end;

  function expect(a_actual in anydata, a_message varchar2 := null) return ut_expectation is
  begin
    return ut_expectation(ut_data_value_anydata.get_instance(a_actual), a_message);
  end;

  function expect(a_actual in blob, a_message varchar2 := null) return ut_expectation is
  begin
    return ut_expectation(ut_data_value_blob(a_actual), a_message);
  end;

  function expect(a_actual in boolean, a_message varchar2 := null) return ut_expectation is
  begin
    return ut_expectation(ut_data_value_boolean(a_actual), a_message);
  end;

  function expect(a_actual in clob, a_message varchar2 := null) return ut_expectation is
  begin
    return ut_expectation(ut_data_value_clob(a_actual), a_message);
  end;

  function expect(a_actual in date, a_message varchar2 := null) return ut_expectation is
  begin
    return ut_expectation(ut_data_value_date(a_actual), a_message);
  end;

  function expect(a_actual in number, a_message varchar2 := null) return ut_expectation is
  begin
    return ut_expectation(ut_data_value_number(a_actual), a_message);
  end;

  function expect(a_actual in timestamp_unconstrained, a_message varchar2 := null) return ut_expectation is
  begin
    return ut_expectation(ut_data_value_timestamp(a_actual), a_message);
  end;

  function expect(a_actual in timestamp_ltz_unconstrained, a_message varchar2 := null) return ut_expectation is
  begin
    return ut_expectation(ut_data_value_timestamp_ltz(a_actual), a_message);
  end;

  function expect(a_actual in timestamp_tz_unconstrained, a_message varchar2 := null) return ut_expectation is
  begin
    return ut_expectation(ut_data_value_timestamp_tz(a_actual), a_message);
  end;

  function expect(a_actual in varchar2, a_message varchar2 := null) return ut_expectation is
  begin
    return ut_expectation(ut_data_value_varchar2(a_actual), a_message);
  end;

  function expect(a_actual in sys_refcursor, a_message varchar2 := null) return ut_expectation is
  begin
    return ut_expectation(ut_data_value_refcursor(a_actual), a_message);
  end;

  function expect(a_actual in yminterval_unconstrained, a_message varchar2 := null) return ut_expectation is
  begin
    return ut_expectation(ut_data_value_yminterval(a_actual), a_message);
  end;

  function expect(a_actual in dsinterval_unconstrained, a_message varchar2 := null) return ut_expectation is
  begin
    return ut_expectation(ut_data_value_dsinterval(a_actual), a_message);
  end;

  procedure fail(a_message in varchar2) is
  begin
    ut_expectation_processor.report_failure(a_message);
  end;

  procedure run_autonomous(
    a_paths ut_varchar2_list, a_reporter ut_reporter_base, a_color_console integer,
    a_coverage_schemes ut_varchar2_list := null, a_source_file_mappings ut_file_mappings, a_test_file_mappings ut_file_mappings,
    a_include_objects ut_varchar2_list, a_exclude_objects ut_varchar2_list
  ) is
    pragma autonomous_transaction;
  begin
    ut_runner.run(
      a_paths, ut_reporters(coalesce(a_reporter,ut_documentation_reporter())),
      ut_utils.int_to_boolean(a_color_console), a_coverage_schemes,
      a_source_file_mappings, a_test_file_mappings, a_include_objects, a_exclude_objects
    );
    rollback;
  end;

  procedure run_autonomous(
    a_paths ut_varchar2_list, a_reporter ut_reporter_base, a_color_console integer,
    a_coverage_schemes ut_varchar2_list := null, a_source_files ut_varchar2_list, a_test_files ut_varchar2_list,
    a_include_objects ut_varchar2_list, a_exclude_objects ut_varchar2_list
  ) is
    pragma autonomous_transaction;
  begin
    ut_runner.run(
      a_paths, ut_reporters(coalesce(a_reporter,ut_documentation_reporter())),
      ut_utils.int_to_boolean(a_color_console), a_coverage_schemes,
      ut_file_mapper.build_file_mappings(a_source_files),
      ut_file_mapper.build_file_mappings(a_test_files),
      a_include_objects, a_exclude_objects
    );
    rollback;
  end;

  function run(
    a_reporter ut_reporter_base := null, a_color_console integer := 0,
    a_coverage_schemes ut_varchar2_list := null, a_source_file_mappings ut_file_mappings := null, a_test_file_mappings ut_file_mappings := null,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null
  ) return ut_varchar2_rows pipelined is
    l_reporter  ut_reporter_base := coalesce(a_reporter, ut_documentation_reporter());
    l_paths     ut_varchar2_list := ut_varchar2_list(sys_context('userenv', 'current_schema'));
    l_lines     sys_refcursor;
    l_line      varchar2(4000);
  begin
    run_autonomous(
      l_paths, l_reporter, a_color_console,
      a_coverage_schemes, a_source_file_mappings, a_test_file_mappings, a_include_objects, a_exclude_objects
    );
    l_lines := ut_output_buffer.get_lines_cursor(l_reporter.reporter_id);
    loop
      fetch l_lines into l_line;
      exit when l_lines%notfound;
      pipe row(l_line);
    end loop;
    close l_lines;
  end;

  function run(
    a_reporter ut_reporter_base := null, a_color_console integer := 0,
    a_coverage_schemes ut_varchar2_list := null, a_source_files ut_varchar2_list, a_test_files ut_varchar2_list,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null
  ) return ut_varchar2_rows pipelined is
    l_reporter  ut_reporter_base := coalesce(a_reporter, ut_documentation_reporter());
    l_paths     ut_varchar2_list := ut_varchar2_list(sys_context('userenv', 'current_schema'));
    l_lines     sys_refcursor;
    l_line      varchar2(4000);
  begin
    run_autonomous(
      l_paths, l_reporter, a_color_console, a_coverage_schemes, a_source_files, a_test_files,
      a_include_objects, a_exclude_objects
    );
    l_lines := ut_output_buffer.get_lines_cursor(l_reporter.reporter_id);
    loop
      fetch l_lines into l_line;
      exit when l_lines%notfound;
      pipe row(l_line);
    end loop;
    close l_lines;
  end;

  function run(
    a_paths ut_varchar2_list, a_reporter ut_reporter_base := null, a_color_console integer := 0,
    a_coverage_schemes ut_varchar2_list := null, a_source_file_mappings ut_file_mappings := null, a_test_file_mappings ut_file_mappings := null,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null
  ) return ut_varchar2_rows pipelined is
    l_reporter  ut_reporter_base := coalesce(a_reporter, ut_documentation_reporter());
    l_lines     sys_refcursor;
    l_line      varchar2(4000);
  begin
    run_autonomous(
      a_paths, l_reporter, a_color_console, a_coverage_schemes, a_source_file_mappings, a_test_file_mappings,
      a_include_objects, a_exclude_objects
    );
    l_lines := ut_output_buffer.get_lines_cursor(l_reporter.reporter_id);
    loop
      fetch l_lines into l_line;
      exit when l_lines%notfound;
      pipe row(l_line);
    end loop;
    close l_lines;
  end;

  function run(
    a_paths ut_varchar2_list, a_reporter ut_reporter_base := null, a_color_console integer := 0,
    a_coverage_schemes ut_varchar2_list := null, a_source_files ut_varchar2_list, a_test_files ut_varchar2_list,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null
  ) return ut_varchar2_rows pipelined is
    l_reporter  ut_reporter_base := coalesce(a_reporter, ut_documentation_reporter());
    l_lines     sys_refcursor;
    l_line      varchar2(4000);
  begin
    run_autonomous(
      a_paths, l_reporter, a_color_console, a_coverage_schemes, a_source_files, a_test_files,
      a_include_objects, a_exclude_objects
    );
    l_lines := ut_output_buffer.get_lines_cursor(l_reporter.reporter_id);
    loop
      fetch l_lines into l_line;
      exit when l_lines%notfound;
      pipe row(l_line);
    end loop;
    close l_lines;
  end;

  function run(
    a_path varchar2, a_reporter ut_reporter_base := null, a_color_console integer := 0,
    a_coverage_schemes ut_varchar2_list := null, a_source_file_mappings ut_file_mappings := null, a_test_file_mappings ut_file_mappings := null,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null
  ) return ut_varchar2_rows pipelined is
    l_reporter  ut_reporter_base := coalesce(a_reporter, ut_documentation_reporter());
    l_paths     ut_varchar2_list := ut_varchar2_list(coalesce(a_path, sys_context('userenv', 'current_schema')));
    l_lines     sys_refcursor;
    l_line      varchar2(4000);
  begin
    run_autonomous(
      l_paths, l_reporter, a_color_console, a_coverage_schemes, a_source_file_mappings, a_test_file_mappings,
      a_include_objects, a_exclude_objects
    );
    l_lines := ut_output_buffer.get_lines_cursor(l_reporter.reporter_id);
    loop
      fetch l_lines into l_line;
      exit when l_lines%notfound;
      pipe row(l_line);
    end loop;
    close l_lines;
  end;

  function run(
    a_path varchar2, a_reporter ut_reporter_base := null, a_color_console integer := 0,
    a_coverage_schemes ut_varchar2_list := null, a_source_files ut_varchar2_list, a_test_files ut_varchar2_list,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null
  ) return ut_varchar2_rows pipelined is
    l_reporter  ut_reporter_base := coalesce(a_reporter, ut_documentation_reporter());
    l_paths     ut_varchar2_list := ut_varchar2_list(coalesce(a_path, sys_context('userenv', 'current_schema')));
    l_lines     sys_refcursor;
    l_line      varchar2(4000);
  begin
    run_autonomous(
      l_paths, l_reporter, a_color_console, a_coverage_schemes, a_source_files, a_test_files,
      a_include_objects, a_exclude_objects
    );
    l_lines := ut_output_buffer.get_lines_cursor(l_reporter.reporter_id);
    loop
      fetch l_lines into l_line;
      exit when l_lines%notfound;
      pipe row(l_line);
    end loop;
    close l_lines;
  end;

  procedure run(
    a_paths ut_varchar2_list, a_reporter ut_reporter_base := null, a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null, a_source_file_mappings ut_file_mappings := null, a_test_file_mappings ut_file_mappings := null,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null
  ) is
    l_reporter  ut_reporter_base := coalesce(a_reporter, ut_documentation_reporter());
  begin
    run_autonomous(
      a_paths, l_reporter, ut_utils.boolean_to_int(a_color_console), a_coverage_schemes, a_source_file_mappings, a_test_file_mappings,
      a_include_objects, a_exclude_objects
    );
    ut_output_buffer.lines_to_dbms_output(l_reporter.reporter_id);
  end;

  procedure run(
    a_paths ut_varchar2_list, a_reporter ut_reporter_base := null, a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null, a_source_files ut_varchar2_list, a_test_files ut_varchar2_list,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null
  ) is
    l_reporter  ut_reporter_base := coalesce(a_reporter, ut_documentation_reporter());
  begin
    run_autonomous(
      a_paths, l_reporter, ut_utils.boolean_to_int(a_color_console), a_coverage_schemes, a_source_files, a_test_files,
      a_include_objects, a_exclude_objects
    );
    ut_output_buffer.lines_to_dbms_output(l_reporter.reporter_id);
  end;

  procedure run(
    a_reporter ut_reporter_base := null, a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null, a_source_file_mappings ut_file_mappings := null, a_test_file_mappings ut_file_mappings := null,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null
  ) is
  begin
    ut.run(
      ut_varchar2_list(sys_context('userenv', 'current_schema')), a_reporter, a_color_console,
      a_coverage_schemes, a_source_file_mappings, a_test_file_mappings, a_include_objects, a_exclude_objects
    );
  end;

  procedure run(
    a_reporter ut_reporter_base := null, a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null, a_source_files ut_varchar2_list, a_test_files ut_varchar2_list,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null
  ) is
  begin
    ut.run(
      ut_varchar2_list(sys_context('userenv', 'current_schema')), a_reporter, a_color_console,
      a_coverage_schemes, a_source_files, a_test_files, a_include_objects, a_exclude_objects
    );
  end;

  procedure run(
    a_path varchar2, a_reporter ut_reporter_base := null, a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null, a_source_file_mappings ut_file_mappings := null, a_test_file_mappings ut_file_mappings := null,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null
  ) is
    l_paths  ut_varchar2_list := ut_varchar2_list(coalesce(a_path, sys_context('userenv', 'current_schema')));
  begin
    ut.run(
      l_paths, a_reporter, a_color_console, a_coverage_schemes, a_source_file_mappings, a_test_file_mappings,
      a_include_objects, a_exclude_objects
    );
  end;

  procedure run(
    a_path varchar2, a_reporter ut_reporter_base := null, a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null, a_source_files ut_varchar2_list, a_test_files ut_varchar2_list,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null
  ) is
    l_paths  ut_varchar2_list := ut_varchar2_list(coalesce(a_path, sys_context('userenv', 'current_schema')));
  begin
    ut.run(
      l_paths, a_reporter, a_color_console, a_coverage_schemes, a_source_files, a_test_files,
      a_include_objects, a_exclude_objects
    );
  end;

  procedure set_nls is
  begin
    if g_nls_date_format is null then
      select nsp.value
       into g_nls_date_format
       from nls_session_parameters nsp
      where parameter = 'NLS_DATE_FORMAT';
    end if;
    execute immediate 'alter session set nls_date_format = '''||ut_utils.gc_date_format||'''';
  end;

  procedure reset_nls is
  begin
    if g_nls_date_format is not null then
      execute immediate 'alter session set nls_date_format = '''||g_nls_date_format||'''';
    end if;
    g_nls_date_format := null;
  end;

end ut;
/
