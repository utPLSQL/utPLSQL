create or replace noneditionable type body ut_test as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2026 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  constructor function ut_test(
    self in out nocopy ut_test, a_object_owner varchar2 := null, a_object_name varchar2, a_name varchar2,
    a_line_no integer, a_expected_error_codes ut_varchar2_rows := null, a_tags ut_varchar2_rows := null
  ) return self as result is
  begin
    self.self_type := $$plsql_unit;
    self.init(a_object_owner, a_object_name, a_name, a_line_no);
    self.item := ut_executable_test(a_object_owner, a_object_name, a_name, ut_utils.gc_test_execute);
    self.before_each_list     := ut_executables();
    self.before_test_list     := ut_executables();
    self.after_test_list      := ut_executables();
    self.after_each_list      := ut_executables();
    self.all_expectations     := ut_expectation_results();
    self.failed_expectations  := ut_expectation_results();
    self.expected_error_codes := a_expected_error_codes;
    self.tags                 := coalesce(a_tags,ut_varchar2_rows());
    return;
  end;

  overriding member procedure mark_as_skipped(self in out nocopy ut_test, a_skip_reason in varchar2) is
  begin
    ut_event_manager.trigger_event(ut_event_manager.gc_before_test, self);
    self.start_time := current_timestamp;
    self.result := ut_utils.gc_disabled;
    self.disabled_reason := coalesce(a_skip_reason,self.disabled_reason);
    ut_utils.debug_log('ut_test.execute - disabled');
    self.results_count.set_counter_values(self.result);
    self.end_time := self.start_time;
    ut_event_manager.trigger_event(ut_event_manager.gc_after_test, self);
  end;

  overriding member function do_execute(self in out nocopy ut_test) return boolean is
    l_no_errors boolean;
    l_savepoint varchar2(30);
  begin

    ut_utils.debug_log('ut_test.execute');

    if self.get_disabled_flag() then
      mark_as_skipped(self.disabled_reason);
    else
      self.start_time := current_timestamp;
      ut_event_manager.trigger_event(ut_event_manager.gc_before_test, self);

      l_savepoint := self.create_savepoint_if_needed();

      --includes listener calls for before and after actions
      l_no_errors := true;
      for i in 1 .. self.before_each_list.count loop
        l_no_errors := self.before_each_list(i).do_execute(self);
        exit when not l_no_errors;
      end loop;

      if l_no_errors then
        for i in 1 .. self.before_test_list.count loop
          l_no_errors := self.before_test_list(i).do_execute(self);
          exit when not l_no_errors;
        end loop;

        if l_no_errors then
          -- execute the test
          self.item.do_execute(self, self.expected_error_codes);

        end if;
        -- perform cleanup regardless of the test or setup failure
        for i in 1 .. self.after_test_list.count loop
          self.after_test_list(i).do_execute(self);
        end loop;
      end if;

      for i in 1 .. self.after_each_list.count loop
        self.after_each_list(i).do_execute(self);
      end loop;
      self.rollback_to_savepoint(l_savepoint);

      self.calc_execution_result();
      self.end_time := current_timestamp;
      ut_event_manager.trigger_event(ut_event_manager.gc_after_test, self);
    end if;
    return l_no_errors;
  end;

  overriding member procedure calc_execution_result(self in out nocopy ut_test) is
    l_warnings ut_varchar2_rows;
  begin
    if self.get_error_stack_traces().count = 0 then
      self.result := ut_expectation_processor.get_status();
    else
      self.result := ut_utils.gc_error;
    end if;
    --expectation results need to be part of test results
    self.all_expectations    := ut_expectation_processor.get_all_expectations();
    self.failed_expectations := ut_expectation_processor.get_failed_expectations();
    l_warnings := coalesce( ut_expectation_processor.get_warnings(), ut_varchar2_rows() );
    self.warnings := self.warnings multiset union all l_warnings;
    self.results_count.increase_warning_count( cardinality(l_warnings) );
    self.results_count.set_counter_values(self.result);
    ut_expectation_processor.clear_expectations();
  end;

  overriding member procedure mark_as_errored(self in out nocopy ut_test, a_error_stack_trace varchar2) is
  begin
    ut_utils.debug_log('ut_test.fail');
    ut_event_manager.trigger_event(ut_event_manager.gc_before_test, self);
    self.start_time := current_timestamp;
    self.parent_error_stack_trace := a_error_stack_trace;
    self.calc_execution_result();
    self.end_time := self.start_time;
    ut_event_manager.trigger_event(ut_event_manager.gc_after_test, self);
  end;

  overriding member function get_error_stack_traces(self ut_test) return ut_varchar2_list is
    l_stack_traces ut_varchar2_list := ut_varchar2_list();
  begin
    ut_utils.append_to_list(l_stack_traces, self.parent_error_stack_trace);
    for i in 1 .. before_each_list.count loop
      ut_utils.append_to_list(l_stack_traces, self.before_each_list(i).get_error_stack_trace());
    end loop;
    for i in 1 .. before_test_list.count loop
      ut_utils.append_to_list(l_stack_traces, self.before_test_list(i).get_error_stack_trace());
    end loop;
    ut_utils.append_to_list(l_stack_traces, self.item.get_error_stack_trace());
    for i in 1 .. after_test_list.count loop
      ut_utils.append_to_list(l_stack_traces, self.after_test_list(i).get_error_stack_trace());
    end loop;
    for i in 1 .. after_each_list.count loop
      ut_utils.append_to_list(l_stack_traces, self.after_each_list(i).get_error_stack_trace());
    end loop;
    return l_stack_traces;
  end;
  overriding member function get_serveroutputs return clob is
    l_outputs clob;
  begin
    for i in 1 .. before_each_list.count loop
      ut_utils.append_to_clob(l_outputs, self.before_each_list(i).serveroutput);
    end loop;
    for i in 1 .. before_test_list.count loop
      ut_utils.append_to_clob(l_outputs, self.before_test_list(i).serveroutput);
    end loop;
    ut_utils.append_to_clob(l_outputs, self.item.serveroutput );
    for i in 1 .. after_test_list.count loop
      ut_utils.append_to_clob(l_outputs, self.after_test_list(i).serveroutput);
    end loop;
    for i in 1 .. after_each_list.count loop
      ut_utils.append_to_clob(l_outputs, self.after_each_list(i).serveroutput);
    end loop;
    return l_outputs;
  end;

  member function get_failed_expectation_lines return ut_varchar2_rows is
    l_results ut_varchar2_rows;
  begin
    for i in 1 .. failed_expectations.count loop
      ut_utils.append_to_list( l_results, ut_utils.convert_collection( failed_expectations(i).get_result_lines() ) );
      ut_utils.append_to_list( l_results, failed_expectations(i).caller_info );
    end loop;
    return l_results;
  end;

  overriding member function has_test_case_source(self in ut_test) return boolean is
  begin
    return self.item.call_source is not null and self.item.call_source_row is null;
  end;

  member function get_source_test_cases(self in ut_test) return ut_suite_items is
    l_parts         ut_varchar2_list := ut_utils.string_to_table(upper(self.item.call_source), '.');
    l_owner         varchar2(128 char);
    l_package       varchar2(128 char);
    l_function      varchar2(128 char);
    l_function_call varchar2(1000 char);
    l_return_type   ut_metadata.t_parameter;
    l_result        ut_suite_items := ut_suite_items();

    procedure raise_invalid(a_message varchar2) is
    begin
      raise_application_error(
        ut_utils.gc_invalid_test_case_source, 'The --%testcasesource function ' || self.item.call_source || ' ' || a_message || '.'
      );
    end;

    function add_test_case(a_row_no integer, a_description varchar2, a_call_arguments varchar2 := null) return varchar2 is
      l_test ut_test := self;
    begin
      l_test.name := self.name || '[' || a_row_no || ']';
      l_test.path := self.path || '[' || a_row_no || ']';
      l_test.description := a_description;
      l_test.item.call_source_row := a_row_no;
      l_test.item.call_arguments := a_call_arguments;
      l_result.extend;
      l_result(l_result.last) := l_test;
      return l_test.path;
    end;

    -- each element of the array is a test case; its JSON text is converted to the parameter types when the test case runs
    procedure add_json_test_cases is
      l_json       clob;
      l_element    json_element_t;
      l_array      json_array_t;
      l_parameters ut_metadata.tt_parameters :=
        ut_metadata.get_package_parameters(upper(self.item.owner_name), upper(self.item.object_name), upper(self.item.procedure_name));
      l_names      ut_varchar2_list := ut_varchar2_list();
    begin
      for i in 1 .. l_parameters.count loop
        if l_parameters(i).overload = l_parameters(1).overload and l_parameters(i).parameter_name is not null then
          l_names.extend;
          l_names(l_names.last) := l_parameters(i).parameter_name;
        end if;
      end loop;
      execute immediate
        'declare l_ut_cases json_array_t := ' || l_function_call || ';' ||
        ' begin if l_ut_cases is not null then :ut_json := l_ut_cases.to_clob(); else :ut_json := null; end if; end;'
        using out l_json;
      -- a function that returns null has no test cases
      if l_json is null then
        return;
      end if;
      l_array := json_array_t.parse(l_json);
      for i in 0 .. l_array.get_size - 1 loop
        l_element := l_array.get(i);
        if not (l_element.is_array or l_element.is_object) then
          raise_invalid('returned element ' || (i + 1) || ', which is neither a JSON array nor a JSON object');
        end if;
        l_json := l_element.to_clob;
        ut_test_case_values.set_json(
          add_test_case(i + 1, ut_test_case_json.get_test_case_description(self.description, l_json, l_names)), l_json
        );
      end loop;
    end;

    -- the rows of the cursor are fetched once; each test case gets the values of its row as ANYDATA
    procedure add_cursor_test_cases is
      type tt_positions is table of pls_integer index by pls_integer;
      l_parameters   ut_metadata.tt_parameters :=
        ut_metadata.get_package_parameters(upper(self.item.owner_name), upper(self.item.object_name), upper(self.item.procedure_name));
      l_params       ut_metadata.tt_parameters := ut_metadata.tt_parameters();
      l_cursor       integer;
      l_columns      dbms_sql.desc_tab3;
      l_count        integer;
      l_named        boolean;
      l_param_of     tt_positions; -- column -> the parameter it is passed to, 0 for none
      l_column_of    tt_positions; -- parameter -> the column passed to it
      l_index        pls_integer;
      l_arguments    varchar2(4000 char);
      l_argument     varchar2(4000 char);
      l_declarations varchar2(32767);
      l_defines      varchar2(32767);
      l_fetches      varchar2(32767);
      l_values_code  varchar2(32767);
      l_display_code varchar2(32767);
      l_values       ut_anydata_list;
      l_display      ut_varchar2_list;
      l_row_values   ut_anydata_list;
      l_row_display  ut_varchar2_list;
      l_names        ut_varchar2_list := ut_varchar2_list();

      -- columns are matched to parameters like JSON keys, not case-sensitive
      function find_parameter(a_column_name varchar2) return pls_integer is
        l_position pls_integer := l_params.first;
      begin
        while l_position is not null loop
          if upper(l_params(l_position).parameter_name) = upper(a_column_name) then
            return l_position;
          end if;
          l_position := l_params.next(l_position);
        end loop;
        return 0;
      end;

      function is_in_description(a_column_name varchar2, a_position integer) return boolean is
      begin
        return nvl(
          instr(self.description, '{' || a_column_name || '}') > 0
          or instr(self.description, '{' || lower(a_column_name) || '}') > 0
          or instr(self.description, '{' || a_position || '}') > 0,
          false
        );
      end;

      -- PL/SQL converts scalar values implicitly; object types, collections and BOOLEAN must match the parameter
      function fits(a_column dbms_sql.desc_rec3, a_parameter ut_metadata.t_parameter) return boolean is
      begin
        return nvl(
          case
            when a_column.col_type = 109 then
              a_parameter.type_owner = a_column.col_schema_name and a_parameter.type_name = a_column.col_type_name
              and a_parameter.type_subname is null
            when a_column.col_type = 252 then
              a_parameter.data_type in ('BOOLEAN', 'PL/SQL BOOLEAN')
            else
              a_parameter.type_name is null and a_parameter.data_type not in ('BOOLEAN', 'PL/SQL BOOLEAN')
          end,
          false
        );
      end;

      function parameter_type(a_parameter ut_metadata.t_parameter) return varchar2 is
      begin
        return nvl(
          -- no nvl2: before Oracle 21 it exists only in SQL, not in PL/SQL
          a_parameter.type_owner || case when a_parameter.type_owner is not null then '.' end || a_parameter.type_name
          || case when a_parameter.type_subname is not null then '.' || a_parameter.type_subname end,
          a_parameter.data_type
        );
      end;

      function is_collection(a_column dbms_sql.desc_rec3) return boolean is
        l_typecode all_types.typecode%type;
      begin
        select /*+ no_parallel */ typecode into l_typecode
          from all_types
         where owner = a_column.col_schema_name and type_name = a_column.col_type_name;
        return l_typecode = 'COLLECTION';
      end;

      function declaration(a_column dbms_sql.desc_rec3) return varchar2 is
        l_national boolean := a_column.col_charsetform = 2;
      begin
        return
          case a_column.col_type
            when 1   then case when l_national then 'nvarchar2(32767)' else 'varchar2(32767)' end
            when 96  then case when l_national then 'nvarchar2(32767)' else 'varchar2(32767)' end
            when 2   then 'number'
            when 100 then 'binary_float'
            when 101 then 'binary_double'
            when 12  then 'date'
            when 180 then 'timestamp(9)'
            when 181 then 'timestamp(9) with time zone'
            when 231 then 'timestamp(9) with local time zone'
            when 182 then 'interval year(9) to month'
            when 183 then 'interval day(9) to second(9)'
            when 112 then case when l_national then 'nclob' else 'clob' end
            when 113 then 'blob'
            when 23  then 'raw(32767)'
            when 109 then '"' || a_column.col_schema_name || '"."' || a_column.col_type_name || '"'
            when 252 then 'boolean'
          end;
      end;

      -- the value as ANYDATA; BOOLEAN has no ANYDATA representation, so it travels as 1 or 0
      function value_expression(a_column dbms_sql.desc_rec3, a_variable varchar2) return varchar2 is
        l_national boolean := a_column.col_charsetform = 2;
      begin
        return 'sys.anydata.' ||
          case a_column.col_type
            when 1   then case when l_national then 'convertnvarchar2' else 'convertvarchar2' end
            when 96  then case when l_national then 'convertnvarchar2' else 'convertvarchar2' end
            when 2   then 'convertnumber'
            when 100 then 'convertbfloat'
            when 101 then 'convertbdouble'
            when 12  then 'convertdate'
            when 180 then 'converttimestamp'
            when 181 then 'converttimestamptz'
            when 231 then 'converttimestampltz'
            when 182 then 'convertintervalym'
            when 183 then 'convertintervalds'
            when 112 then case when l_national then 'convertnclob' else 'convertclob' end
            when 113 then 'convertblob'
            when 23  then 'convertraw'
            when 109 then case when is_collection(a_column) then 'convertcollection' else 'convertobject' end
            when 252 then 'convertnumber'
          end ||
          case when a_column.col_type = 252
            then '(case when ' || a_variable || ' then 1 when not ' || a_variable || ' then 0 end)'
            else '(' || a_variable || ')'
          end;
      end;

      -- the argument passed to the test procedure; ut_executable declares l_ut_value_<n> for object types and collections
      function argument_expression(a_column dbms_sql.desc_rec3, a_position integer) return varchar2 is
        l_value    varchar2(200 char) := 'l_ut_values(' || a_position || ')';
        l_national boolean := a_column.col_charsetform = 2;
      begin
        return
          case a_column.col_type
            when 1   then l_value || case when l_national then '.accessnvarchar2()' else '.accessvarchar2()' end
            when 96  then l_value || case when l_national then '.accessnvarchar2()' else '.accessvarchar2()' end
            when 2   then l_value || '.accessnumber()'
            when 100 then l_value || '.accessbfloat()'
            when 101 then l_value || '.accessbdouble()'
            when 12  then l_value || '.accessdate()'
            when 180 then l_value || '.accesstimestamp()'
            when 181 then l_value || '.accesstimestamptz()'
            when 231 then l_value || '.accesstimestampltz()'
            when 182 then l_value || '.accessintervalym()'
            when 183 then l_value || '.accessintervalds()'
            when 112 then l_value || case when l_national then '.accessnclob()' else '.accessclob()' end
            when 113 then l_value || '.accessblob()'
            when 23  then l_value || '.accessraw()'
            when 109 then 'l_ut_value_' || a_position
            when 252 then 'case ' || l_value || '.accessnumber() when 1 then true when 0 then false end'
          end;
      end;

      -- values are shown like in a JSON or PL/SQL test case: dates and times in ISO format, numbers with a leading zero
      function display_expression(a_column dbms_sql.desc_rec3, a_variable varchar2) return varchar2 is
      begin
        return
          case
            when a_column.col_type = 12 then 'to_char(' || a_variable || ', ''yyyy-mm-dd"T"hh24:mi:ss'')'
            when a_column.col_type = 180 then 'to_char(' || a_variable || ', ''yyyy-mm-dd"T"hh24:mi:ss.ff6'')'
            when a_column.col_type = 181 then 'to_char(' || a_variable || ', ''yyyy-mm-dd"T"hh24:mi:ss.ff6tzh:tzm'')'
            when a_column.col_type = 231 then
              'to_char(cast(' || a_variable || ' as timestamp with time zone), ''yyyy-mm-dd"T"hh24:mi:ss.ff6tzh:tzm'')'
            when a_column.col_type in (2, 100, 101) then
              'regexp_replace(to_char(' || a_variable || ', ''TM9'', ''nls_numeric_characters=''''.,''''''), ''^(-?)\.'', ''\10.'')'
            when a_column.col_type in (1, 96, 182, 183) then 'to_char(' || a_variable || ')'
            when a_column.col_type = 112 then 'dbms_lob.substr(' || a_variable || ', 100)'
            when a_column.col_type = 23 then 'rawtohex(' || a_variable || ')'
            when a_column.col_type = 252 then 'case when ' || a_variable || ' then ''true'' when not ' || a_variable || ' then ''false'' end'
            else '''<' || nvl(a_column.col_type_name, 'value') || '>'''
          end;
      end;
    begin
      l_index := l_parameters.first;
      while l_index is not null loop
        if l_parameters(l_index).overload != l_parameters(l_parameters.first).overload then
          raise_invalid('can''t be used with the overloaded procedure ' || upper(self.item.procedure_name));
        end if;
        if l_parameters(l_index).parameter_name is not null then
          l_params.extend;
          l_params(l_params.last) := l_parameters(l_index);
        end if;
        l_index := l_parameters.next(l_index);
      end loop;
      execute immediate
        'declare l_ut_rc sys_refcursor; begin l_ut_rc := ' || l_function_call || '; :ut_cursor := dbms_sql.to_cursor_number(l_ut_rc); end;'
        using out l_cursor;
      begin
        dbms_sql.describe_columns3(l_cursor, l_count, l_columns);
        for i in 1 .. l_count loop
          if argument_expression(l_columns(i), i) is null
            or l_columns(i).col_type = 109 and l_columns(i).col_schema_name = 'SYS' then
            raise_invalid(
              'returned column ' || l_columns(i).col_name || ', which has a data type that can''t be passed to the test: '
              || nvl(l_columns(i).col_type_name, to_char(l_columns(i).col_type))
            );
          end if;
          l_param_of(i) := find_parameter(l_columns(i).col_name);
          if l_param_of(i) > 0 then
            if l_column_of.exists(l_param_of(i)) then
              raise_invalid(
                'returned columns ' || l_columns(l_column_of(l_param_of(i))).col_name || ' and ' || l_columns(i).col_name
                || ' for the same parameter ' || l_params(l_param_of(i)).parameter_name
              );
            end if;
            l_column_of(l_param_of(i)) := i;
          end if;
        end loop;
        -- columns named like parameters are passed by name; when none is, all columns are passed by position
        l_named := l_column_of.count > 0;
        if not l_named then
          if l_count != l_params.count then
            raise_invalid(
              'returned ' || l_count || ' column(s) and none is named like a parameter, but the test procedure has '
              || l_params.count || ' parameter(s); name the columns like the parameters or return one column per parameter'
            );
          end if;
          for i in 1 .. l_count loop
            l_param_of(i) := i;
            l_column_of(i) := i;
          end loop;
        end if;
        -- a column that is neither passed nor shown is an error, so that a misspelled column name
        -- doesn't silently leave its parameter at the default, like a misspelled JSON key
        for i in 1 .. l_count loop
          if l_param_of(i) = 0 and not is_in_description(l_columns(i).col_name, i) then
            raise_invalid(
              'returned column ' || l_columns(i).col_name || ', which is no parameter of the test procedure and isn''t used in the description'
            );
          elsif l_param_of(i) > 0 and not fits(l_columns(i), l_params(l_param_of(i))) then
            raise_invalid(
              'returned column ' || l_columns(i).col_name || ' of type ' || upper(regexp_replace(declaration(l_columns(i)), '\([0-9]+\)'))
              || ', which can''t be passed to parameter ' || l_params(l_param_of(i)).parameter_name
              || ' of type ' || parameter_type(l_params(l_param_of(i)))
            );
          end if;
        end loop;
        l_index := l_params.first;
        while l_index is not null loop
          if l_params(l_index).defaulted = 'N' and not l_column_of.exists(l_index) then
            raise_invalid('returned no column for parameter ' || l_params(l_index).parameter_name || ', which has no default value');
          end if;
          l_index := l_params.next(l_index);
        end loop;
        for i in 1 .. l_count loop
          if l_param_of(i) > 0 then
            l_argument := case when l_arguments is not null then ', ' end
              || case when l_named then '"' || l_params(l_param_of(i)).parameter_name || '" => ' end
              || argument_expression(l_columns(i), i);
            if nvl(lengthc(l_arguments), 0) + lengthc(l_argument) > ut_utils.gc_max_storage_varchar2_len then
              raise_invalid('returned more columns than can be passed to the test procedure');
            end if;
            l_arguments := l_arguments || l_argument;
          end if;
          l_declarations := l_declarations || '  l_ut_v' || i || ' ' || declaration(l_columns(i)) || ';' || chr(10);
          l_defines := l_defines || '  dbms_sql.' ||
            case
              when l_columns(i).col_type = 23 then 'define_column_raw(l_ut_c, ' || i || ', l_ut_v' || i || ', 32767);'
              when l_columns(i).col_type in (1, 96) then 'define_column(l_ut_c, ' || i || ', l_ut_v' || i || ', 32767);'
              else 'define_column(l_ut_c, ' || i || ', l_ut_v' || i || ');'
            end || chr(10);
          l_fetches := l_fetches || '    dbms_sql.column_value' || case when l_columns(i).col_type = 23 then '_raw' end
            || '(l_ut_c, ' || i || ', l_ut_v' || i || ');' || chr(10);
          l_values_code := l_values_code ||
            '    l_ut_values(l_ut_values.count - ' || (l_count - i) || ') := ' || value_expression(l_columns(i), 'l_ut_v' || i) || ';' || chr(10);
          l_display_code := l_display_code ||
            '    l_ut_display(l_ut_display.count - ' || (l_count - i) || ') := substr(' || display_expression(l_columns(i), 'l_ut_v' || i)
            || ', 1, ' || ut_utils.gc_max_storage_varchar2_len || ');' || chr(10);
          l_names.extend;
          l_names(i) := l_columns(i).col_name;
        end loop;

        execute immediate
          'declare' || chr(10) ||
          '  l_ut_c       integer := :ut_cursor;' || chr(10) ||
          '  l_ut_values  ' || ut_utils.ut_owner || '.ut_anydata_list := ' || ut_utils.ut_owner || '.ut_anydata_list();' || chr(10) ||
          '  l_ut_display ' || ut_utils.ut_owner || '.ut_varchar2_list := ' || ut_utils.ut_owner || '.ut_varchar2_list();' || chr(10) ||
          l_declarations ||
          'begin' || chr(10) ||
          l_defines ||
          '  while dbms_sql.fetch_rows(l_ut_c) > 0 loop' || chr(10) ||
          l_fetches ||
          '    l_ut_values.extend(' || l_count || ');' || chr(10) ||
          '    l_ut_display.extend(' || l_count || ');' || chr(10) ||
          l_values_code ||
          l_display_code ||
          '  end loop;' || chr(10) ||
          '  dbms_sql.close_cursor(l_ut_c);' || chr(10) ||
          '  :ut_values := l_ut_values;' || chr(10) ||
          '  :ut_display := l_ut_display;' || chr(10) ||
          'end;'
          using in l_cursor, out l_values, out l_display;
      exception
        when others then
          if dbms_sql.is_open(l_cursor) then
            dbms_sql.close_cursor(l_cursor);
          end if;
          raise;
      end;

      for l_row_no in 1 .. l_values.count / l_count loop
        l_row_values := ut_anydata_list();
        l_row_display := ut_varchar2_list();
        for i in 1 .. l_count loop
          l_row_values.extend;
          l_row_values(i) := l_values((l_row_no - 1) * l_count + i);
          l_row_display.extend;
          l_row_display(i) := nvl(l_display((l_row_no - 1) * l_count + i), 'null');
        end loop;
        ut_test_case_values.set_values(
          add_test_case(
            l_row_no,
            ut_utils.get_test_case_description(self.description, l_names, l_row_display),
            l_arguments
          ),
          l_row_values
        );
      end loop;
    end;
  begin
    case l_parts.count
      when 1 then
        l_owner := upper(self.item.owner_name);
        l_package := upper(self.item.object_name);
        l_function := l_parts(1);
      when 2 then
        l_owner := upper(self.item.owner_name);
        l_package := l_parts(1);
        l_function := l_parts(2);
      else
        l_owner := l_parts(1);
        l_package := l_parts(2);
        l_function := l_parts(3);
    end case;
    l_function_call :=
      dbms_assert.enquote_name(l_owner, false) || '.' || dbms_assert.enquote_name(l_package, false) || '.'
      || dbms_assert.enquote_name(l_function, false) || '()';
    l_return_type := ut_metadata.get_function_return_type(l_owner, l_package, l_function);
    case
      when l_return_type.data_type = 'REF CURSOR' then
        add_cursor_test_cases();
      -- json_array_t rather than text, so that what the function returns is a JSON array (decided in #1326)
      when l_return_type.data_type = 'OBJECT' and l_return_type.type_name = 'JSON_ARRAY_T' then
        add_json_test_cases();
      when l_return_type.data_type is null then
        raise_invalid('doesn''t exist or can''t be called without arguments');
      else
        raise_invalid(
          'must return json_array_t or sys_refcursor, not '
          || nvl(l_return_type.type_name, l_return_type.data_type)
        );
    end case;
    return l_result;
  end;
end;
/
