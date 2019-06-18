create or replace package body ut is

  /*
  utPLSQL - Version 3
  Copyright 2016 - 2019 utPLSQL Project

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
  gc_fail_on_errors constant boolean := false;

  g_result_line_no binary_integer;
  g_result_lines   ut_varchar2_list := ut_varchar2_list();

  function version return varchar2 is
  begin
    return ut_runner.version();
  end;

  function expect(a_actual in anydata, a_message varchar2 := null) return ut_expectation_compound is
  begin
    return ut_expectation_compound(ut_data_value_anydata(a_actual), a_message);
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

  function expect(a_actual in sys_refcursor, a_message varchar2 := null) return ut_expectation_compound is
  begin
    return ut_expectation_compound(ut_data_value_refcursor(a_actual), a_message);
  end;

  function expect(a_actual in yminterval_unconstrained, a_message varchar2 := null) return ut_expectation is
  begin
    return ut_expectation(ut_data_value_yminterval(a_actual), a_message);
  end;

  function expect(a_actual in dsinterval_unconstrained, a_message varchar2 := null) return ut_expectation is
  begin
    return ut_expectation(ut_data_value_dsinterval(a_actual), a_message);
  end;

  function expect(a_actual in json_element_t , a_message varchar2 := null) return ut_expectation_json is
  begin
    return ut_expectation_json(ut_data_value_json(a_actual), a_message);
  end;
  
  procedure fail(a_message in varchar2) is
  begin
    ut_expectation_processor.report_failure(a_message);
  end;

  procedure raise_if_packages_invalidated is
    e_package_invalidated exception;
    pragma exception_init (e_package_invalidated, -04068);
  begin
    if ut_expectation_processor.invalidation_exception_found() then
      ut_expectation_processor.reset_invalidation_exception();
      raise e_package_invalidated;
    end if;
  end;
  
  
  procedure run_autonomous(
    a_paths ut_varchar2_list,
    a_reporter in out nocopy ut_reporter_base,
    a_color_console integer,
    a_coverage_schemes ut_varchar2_list,
    a_source_file_mappings ut_file_mappings,
    a_test_file_mappings ut_file_mappings,
    a_include_objects ut_varchar2_list,
    a_exclude_objects ut_varchar2_list,
    a_client_character_set varchar2,
    a_random_test_order     integer,
    a_random_test_order_seed     positive,
    a_tags varchar2 := null
  ) is
    pragma autonomous_transaction;
  begin
    a_reporter := coalesce(a_reporter,ut_documentation_reporter());
    ut_runner.run(
      a_paths,
      ut_reporters(a_reporter),
      ut_utils.int_to_boolean(a_color_console),
      a_coverage_schemes,
      a_source_file_mappings,
      a_test_file_mappings,
      a_include_objects,
      a_exclude_objects,
      gc_fail_on_errors,
      a_client_character_set,
      false,
      ut_utils.int_to_boolean(a_random_test_order),
      a_random_test_order_seed,
      a_tags
    );
    rollback;
  end;

  procedure run_autonomous(
    a_paths ut_varchar2_list,
    a_reporter in out nocopy ut_reporter_base,
    a_color_console integer,
    a_coverage_schemes ut_varchar2_list,
    a_source_files ut_varchar2_list,
    a_test_files ut_varchar2_list,
    a_include_objects ut_varchar2_list,
    a_exclude_objects ut_varchar2_list,
    a_client_character_set varchar2,
    a_random_test_order    integer,
    a_random_test_order_seed    positive,
    a_tags varchar2 := null
  ) is
    pragma autonomous_transaction;
  begin
    a_reporter := coalesce(a_reporter,ut_documentation_reporter());
    ut_runner.run(
      a_paths,
      ut_reporters(a_reporter),
      ut_utils.int_to_boolean(a_color_console),
      a_coverage_schemes,
      ut_file_mapper.build_file_mappings(a_source_files),
      ut_file_mapper.build_file_mappings(a_test_files),
      a_include_objects,
      a_exclude_objects,
      gc_fail_on_errors,
      a_client_character_set,
      false,
      ut_utils.int_to_boolean(a_random_test_order),
      a_random_test_order_seed,
      a_tags
    );
    rollback;
  end;

  function get_report_outputs( a_cursor sys_refcursor ) return varchar2 is
    l_clob      clob;
    l_item_type varchar2(32767);
    l_result    varchar2(4000);
  begin
    if g_result_line_no is null then
      fetch a_cursor into l_clob, l_item_type;
      if a_cursor%notfound then
        close a_cursor;
        g_result_line_no := null;
        g_result_lines   := ut_varchar2_list();
        raise_if_packages_invalidated();
        raise no_data_found;
      end if;
      g_result_lines   := ut_utils.clob_to_table(l_clob, ut_utils.gc_max_storage_varchar2_len);
      g_result_line_no := g_result_lines.first;
    end if;
    
    if g_result_line_no is not null then
      l_result         := g_result_lines(g_result_line_no);
      g_result_line_no := g_result_lines.next(g_result_line_no);
    end if;
    return l_result;
  end;

  function run(
    a_reporter ut_reporter_base := null,
    a_color_console integer := 0,
    a_coverage_schemes ut_varchar2_list := null,
    a_source_file_mappings ut_file_mappings := null,
    a_test_file_mappings ut_file_mappings := null,
    a_include_objects ut_varchar2_list := null,
    a_exclude_objects ut_varchar2_list := null,
    a_client_character_set varchar2 := null,
    a_random_test_order     integer := 0,
    a_random_test_order_seed     positive := null,
    a_tags varchar2 := null
  ) return ut_varchar2_rows pipelined is
    l_reporter  ut_reporter_base := a_reporter;
    l_results   sys_refcursor;
  begin
    run_autonomous(
      ut_varchar2_list(),
      l_reporter,
      a_color_console,
      a_coverage_schemes,
      a_source_file_mappings,
      a_test_file_mappings,
      a_include_objects,
      a_exclude_objects,
      a_client_character_set,
      a_random_test_order,
      a_random_test_order_seed,
      a_tags
    );
    if l_reporter is of (ut_output_reporter_base) then
      l_results := treat(l_reporter as ut_output_reporter_base).get_lines_cursor();
      loop
        pipe row( get_report_outputs( l_results ) );
      end loop;
    end if;
    return;
  end;

  function run(
    a_reporter ut_reporter_base := null,
    a_color_console integer := 0,
    a_coverage_schemes ut_varchar2_list := null,
    a_source_files ut_varchar2_list,
    a_test_files ut_varchar2_list,
    a_include_objects ut_varchar2_list := null,
    a_exclude_objects ut_varchar2_list := null,
    a_client_character_set varchar2 := null,
    a_random_test_order     integer := 0,
    a_random_test_order_seed     positive := null,
    a_tags varchar2 := null
  ) return ut_varchar2_rows pipelined is
    l_reporter  ut_reporter_base := a_reporter;
    l_results   sys_refcursor;
  begin
    run_autonomous(
      ut_varchar2_list(),
      l_reporter,
      a_color_console,
      a_coverage_schemes,
      a_source_files,
      a_test_files,
      a_include_objects,
      a_exclude_objects,
      a_client_character_set,
      a_random_test_order,
      a_random_test_order_seed,
      a_tags
    );
    if l_reporter is of (ut_output_reporter_base) then
      l_results := treat(l_reporter as ut_output_reporter_base).get_lines_cursor();
      loop
        pipe row( get_report_outputs( l_results ) );
      end loop;
    end if;
    return;
  end;

  function run(
    a_paths ut_varchar2_list,
    a_reporter ut_reporter_base := null,
    a_color_console integer := 0,
    a_coverage_schemes ut_varchar2_list := null,
    a_source_file_mappings ut_file_mappings := null,
    a_test_file_mappings ut_file_mappings := null,
    a_include_objects ut_varchar2_list := null,
    a_exclude_objects ut_varchar2_list := null,
    a_client_character_set varchar2 := null,
    a_random_test_order     integer := 0,
    a_random_test_order_seed     positive := null,
    a_tags varchar2 := null
  ) return ut_varchar2_rows pipelined is
    l_reporter  ut_reporter_base := a_reporter;
    l_results   sys_refcursor;
  begin
    run_autonomous(
      a_paths,
      l_reporter,
      a_color_console,
      a_coverage_schemes,
      a_source_file_mappings,
      a_test_file_mappings,
      a_include_objects,
      a_exclude_objects,
      a_client_character_set,
      a_random_test_order,
      a_random_test_order_seed,
      a_tags
    );
    if l_reporter is of (ut_output_reporter_base) then
      l_results := treat(l_reporter as ut_output_reporter_base).get_lines_cursor();
      loop
        pipe row( get_report_outputs( l_results ) );
      end loop;
    end if;
    return;
  end;

  function run(
    a_paths ut_varchar2_list,
    a_reporter ut_reporter_base := null,
    a_color_console integer := 0,
    a_coverage_schemes ut_varchar2_list := null,
    a_source_files ut_varchar2_list,
    a_test_files ut_varchar2_list,
    a_include_objects ut_varchar2_list := null,
    a_exclude_objects ut_varchar2_list := null,
    a_client_character_set varchar2 := null,
    a_random_test_order     integer := 0,
    a_random_test_order_seed     positive := null,
    a_tags varchar2 := null
  ) return ut_varchar2_rows pipelined is
    l_reporter  ut_reporter_base := a_reporter;
    l_results   sys_refcursor;
  begin
    run_autonomous(
      a_paths,
      l_reporter,
      a_color_console,
      a_coverage_schemes,
      a_source_files,
      a_test_files,
      a_include_objects,
      a_exclude_objects,
      a_client_character_set,
      a_random_test_order,
      a_random_test_order_seed,
      a_tags
    );
    if l_reporter is of (ut_output_reporter_base) then
      l_results := treat(l_reporter as ut_output_reporter_base).get_lines_cursor();
      loop
        pipe row( get_report_outputs( l_results ) );
      end loop;
    end if;
    return;
  end;

  function run(
    a_path varchar2,
    a_reporter ut_reporter_base := null,
    a_color_console integer := 0,
    a_coverage_schemes ut_varchar2_list := null,
    a_source_file_mappings ut_file_mappings := null,
    a_test_file_mappings ut_file_mappings := null,
    a_include_objects ut_varchar2_list := null,
    a_exclude_objects ut_varchar2_list := null,
    a_client_character_set varchar2 := null,
    a_random_test_order     integer := 0,
    a_random_test_order_seed     positive := null,
    a_tags varchar2 := null
  ) return ut_varchar2_rows pipelined is
    l_reporter     ut_reporter_base := a_reporter;
    l_results      sys_refcursor;
  begin
    run_autonomous(
      ut_varchar2_list(a_path),
      l_reporter,
      a_color_console,
      a_coverage_schemes,
      a_source_file_mappings,
      a_test_file_mappings,
      a_include_objects,
      a_exclude_objects,
      a_client_character_set,
      a_random_test_order,
      a_random_test_order_seed,
      a_tags
    );
    if l_reporter is of (ut_output_reporter_base) then
      l_results := treat(l_reporter as ut_output_reporter_base).get_lines_cursor();
      loop
        pipe row( get_report_outputs( l_results ) );
      end loop;
    end if;
    return;
  end;

  function run(
    a_path varchar2,
    a_reporter ut_reporter_base := null,
    a_color_console integer := 0,
    a_coverage_schemes ut_varchar2_list := null,
    a_source_files ut_varchar2_list,
    a_test_files ut_varchar2_list,
    a_include_objects ut_varchar2_list := null,
    a_exclude_objects ut_varchar2_list := null,
    a_client_character_set varchar2 := null,
    a_random_test_order     integer := 0,
    a_random_test_order_seed     positive := null,
    a_tags varchar2 := null
  ) return ut_varchar2_rows pipelined is
    l_reporter  ut_reporter_base := a_reporter;
    l_results   sys_refcursor;
  begin
    run_autonomous(
      ut_varchar2_list(a_path),
      l_reporter,
      a_color_console,
      a_coverage_schemes,
      a_source_files,
      a_test_files,
      a_include_objects,
      a_exclude_objects,
      a_client_character_set,
      a_random_test_order,
      a_random_test_order_seed,
      a_tags
    );
    if l_reporter is of (ut_output_reporter_base) then
      l_results := treat(l_reporter as ut_output_reporter_base).get_lines_cursor();
      loop
        pipe row( get_report_outputs( l_results ) );
      end loop;
    end if;
    return;
  end;

  procedure run(
    a_paths ut_varchar2_list,
    a_reporter ut_reporter_base := null,
    a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null,
    a_source_file_mappings ut_file_mappings := null,
    a_test_file_mappings ut_file_mappings := null,
    a_include_objects ut_varchar2_list := null,
    a_exclude_objects ut_varchar2_list := null,
    a_client_character_set varchar2 := null,
    a_force_manual_rollback boolean := false,
    a_random_test_order     boolean := false,
    a_random_test_order_seed     positive := null,
    a_tags varchar2 := null
  ) is
    l_reporter  ut_reporter_base := a_reporter;
  begin
    if a_force_manual_rollback then
      l_reporter := coalesce(l_reporter,ut_documentation_reporter());
      ut_runner.run(
        a_paths,
        ut_reporters(l_reporter),
        a_color_console,
        a_coverage_schemes,
        a_source_file_mappings,
        a_test_file_mappings,
        a_include_objects,
        a_exclude_objects,
        gc_fail_on_errors,
        a_client_character_set,
        a_force_manual_rollback,
        a_random_test_order,
        a_random_test_order_seed,
        a_tags
      );
    else
      run_autonomous(
        a_paths,
        l_reporter,
        ut_utils.boolean_to_int(a_color_console),
        a_coverage_schemes,
        a_source_file_mappings,
        a_test_file_mappings,
        a_include_objects,
        a_exclude_objects,
        a_client_character_set,
        ut_utils.boolean_to_int(a_random_test_order),
        a_random_test_order_seed,
        a_tags
      );
    end if;
    if l_reporter is of (ut_output_reporter_base) then
        treat(l_reporter as ut_output_reporter_base).lines_to_dbms_output();
    end if;
    raise_if_packages_invalidated();
  end;

  procedure run(
    a_paths ut_varchar2_list,
    a_reporter ut_reporter_base := null,
    a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null,
    a_source_files ut_varchar2_list,
    a_test_files ut_varchar2_list,
    a_include_objects ut_varchar2_list := null,
    a_exclude_objects ut_varchar2_list := null,
    a_client_character_set varchar2 := null,
    a_force_manual_rollback boolean := false,
    a_random_test_order     boolean := false,
    a_random_test_order_seed     positive := null,
    a_tags varchar2 := null
  ) is
    l_reporter  ut_reporter_base := a_reporter;
  begin
    ut.run(
      a_paths,
      l_reporter,
      a_color_console,
      a_coverage_schemes,
      ut_file_mapper.build_file_mappings(a_source_files),
      ut_file_mapper.build_file_mappings(a_test_files),
      a_include_objects,
      a_exclude_objects,
      a_client_character_set,
      a_force_manual_rollback,
      a_random_test_order,
      a_random_test_order_seed,
      a_tags
    );
  end;

  procedure run(
    a_reporter ut_reporter_base := null,
    a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null,
    a_source_file_mappings ut_file_mappings := null,
    a_test_file_mappings ut_file_mappings := null,
    a_include_objects ut_varchar2_list := null,
    a_exclude_objects ut_varchar2_list := null,
    a_client_character_set varchar2 := null,
    a_force_manual_rollback boolean := false,
    a_random_test_order     boolean := false,
    a_random_test_order_seed     positive := null,
    a_tags varchar2 := null
  ) is
  begin
    ut.run(
      ut_varchar2_list(),
      a_reporter,
      a_color_console,
      a_coverage_schemes,
      a_source_file_mappings,
      a_test_file_mappings,
      a_include_objects,
      a_exclude_objects,
      a_client_character_set,
      a_force_manual_rollback,
      a_random_test_order,
      a_random_test_order_seed,
      a_tags
    );
  end;

  procedure run(
    a_reporter ut_reporter_base := null,
    a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null,
    a_source_files ut_varchar2_list,
    a_test_files ut_varchar2_list,
    a_include_objects ut_varchar2_list := null,
    a_exclude_objects ut_varchar2_list := null,
    a_client_character_set varchar2 := null,
    a_force_manual_rollback boolean := false,
    a_random_test_order     boolean := false,
    a_random_test_order_seed     positive := null,
    a_tags varchar2 := null
  ) is
  begin
    ut.run(
      ut_varchar2_list(),
      a_reporter,
      a_color_console,
      a_coverage_schemes,
      a_source_files,
      a_test_files,
      a_include_objects,
      a_exclude_objects,
      a_client_character_set,
      a_force_manual_rollback,
      a_random_test_order,
      a_random_test_order_seed,
      a_tags
    );
  end;

  procedure run(
    a_path varchar2,
    a_reporter ut_reporter_base := null,
    a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null,
    a_source_file_mappings ut_file_mappings := null,
    a_test_file_mappings ut_file_mappings := null,
    a_include_objects ut_varchar2_list := null,
    a_exclude_objects ut_varchar2_list := null,
    a_client_character_set varchar2 := null,
    a_force_manual_rollback boolean := false,
    a_random_test_order     boolean := false,
    a_random_test_order_seed     positive := null,
    a_tags varchar2 := null
  ) is
  begin
    ut.run(
      ut_varchar2_list(a_path),
      a_reporter,
      a_color_console,
      a_coverage_schemes,
      a_source_file_mappings,
      a_test_file_mappings,
      a_include_objects,
      a_exclude_objects,
      a_client_character_set,
      a_force_manual_rollback,
      a_random_test_order,
      a_random_test_order_seed,
      a_tags
    );
  end;

  procedure run(
    a_path varchar2,
    a_reporter ut_reporter_base := null,
    a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null,
    a_source_files ut_varchar2_list,
    a_test_files ut_varchar2_list,
    a_include_objects ut_varchar2_list := null,
    a_exclude_objects ut_varchar2_list := null,
    a_client_character_set varchar2 := null,
    a_force_manual_rollback boolean := false,
    a_random_test_order     boolean := false,
    a_random_test_order_seed     positive := null,
    a_tags varchar2 := null
  ) is
  begin
    ut.run(
      ut_varchar2_list(a_path),
      a_reporter,
      a_color_console,
      a_coverage_schemes,
      a_source_files,
      a_test_files,
      a_include_objects,
      a_exclude_objects,
      a_client_character_set,
      a_force_manual_rollback,
      a_random_test_order,
      a_random_test_order_seed,
      a_tags
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
