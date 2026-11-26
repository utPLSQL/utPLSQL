create or replace noneditionable package body ut_test_case_json as
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

  procedure raise_invalid(a_message varchar2) is
  begin
    raise_application_error(ut_utils.gc_invalid_test_case_source, 'Invalid JSON test case: ' || a_message || '.');
  end;

  function get_json_error(a_json clob) return varchar2 is
    l_element json_element_t;
  begin
    -- an annotation is a single line, so only spaces and tabs can precede the JSON
    if nvl(substr(ltrim(a_json, ' ' || chr(9)), 1, 1) not in ('[', '{'), true) then
      return 'a JSON array or object is expected';
    end if;
    -- text that starts with [ or { is a JSON array or object when it can be parsed
    l_element := json_element_t.parse(a_json);
    return null;
  exception
    when others then
      return 'it is not valid JSON';
  end;

  procedure get_names_and_values(
    a_json clob, a_names out nocopy ut_varchar2_list, a_values out nocopy ut_varchar2_list, a_parameter_names ut_varchar2_list := null
  ) is
    l_element json_element_t := json_element_t.parse(a_json);
    l_array   json_array_t;
    l_object  json_object_t;
    l_keys    json_key_list;

    -- strings are shown without quotes; only the start of long values is shown
    function display_value(a_value json_element_t, a_string clob) return varchar2 is
    begin
      return dbms_lob.substr(
        case when a_value.is_string then a_string when a_value.is_null then to_clob('null') else a_value.to_clob end,
        ut_utils.gc_max_storage_varchar2_len
      );
    end;
  begin
    a_names := ut_varchar2_list();
    a_values := ut_varchar2_list();
    if l_element.is_array then
      l_array := treat(l_element as json_array_t);
      for i in 0 .. l_array.get_size - 1 loop
        a_names.extend;
        -- values passed by position get the name of their parameter, so the description can refer to them by name
        if i < cardinality(a_parameter_names) then
          a_names(a_names.last) := lower(a_parameter_names(i + 1));
        end if;
        a_values.extend;
        a_values(a_values.last) := display_value(l_array.get(i), case when l_array.get(i).is_string then l_array.get_clob(i) end);
      end loop;
    else
      l_object := treat(l_element as json_object_t);
      l_keys := l_object.get_keys;
      for i in 1 .. l_keys.count loop
        a_names.extend;
        a_names(a_names.last) := l_keys(i);
        a_values.extend;
        a_values(a_values.last) := display_value(
          l_object.get(l_keys(i)), case when l_object.get(l_keys(i)).is_string then l_object.get_clob(l_keys(i)) end
        );
      end loop;
    end if;
  end;

  function get_argument_names(a_json clob) return ut_varchar2_list is
    l_names  ut_varchar2_list;
    l_values ut_varchar2_list;
  begin
    get_names_and_values(a_json, l_names, l_values);
    return l_names;
  end;

  function get_test_case_description(
    a_description varchar2, a_json clob, a_parameter_names ut_varchar2_list := null
  ) return varchar2 is
    l_names  ut_varchar2_list;
    l_values ut_varchar2_list;
  begin
    get_names_and_values(a_json, l_names, l_values, a_parameter_names);
    return ut_utils.get_test_case_description(a_description, l_names, l_values);
  end;

  function get_call(a_owner varchar2, a_package varchar2, a_procedure varchar2, a_call_name varchar2, a_json clob) return varchar2 is
    type tt_names is table of varchar2(30 char) index by varchar2(400 char);
    l_all_parameters ut_metadata.tt_parameters :=
      ut_metadata.get_package_parameters(upper(a_owner), upper(a_package), upper(a_procedure));
    l_parameters     ut_metadata.tt_parameters := ut_metadata.tt_parameters();
    l_element        json_element_t := json_element_t.parse(a_json);
    l_array          json_array_t;
    l_keys           json_key_list;
    l_case_type      varchar2(30 char);
    l_count          binary_integer := 0;
    l_declarations   varchar2(32767);
    l_functions      varchar2(32767);
    l_assignments    varchar2(32767);
    l_arguments      varchar2(32767);
    l_given          ut_varchar2_list := ut_varchar2_list();
    l_index          pls_integer;
    -- each type is converted by one generated function
    l_converters     tt_names;
    c_error          constant varchar2(30 char) := to_char(ut_utils.gc_invalid_test_case_source);

    procedure raise_unsupported(a_parameter ut_metadata.t_parameter) is
    begin
      raise_invalid(
        'parameter ' || a_parameter.parameter_name || ' has a data type that can''t be passed from JSON: '
        || nvl(a_parameter.type_name || case when a_parameter.type_subname is not null then '.' || a_parameter.type_subname end, a_parameter.data_type)
      );
    end;

    -- the declaration of a variable of the parameter type, and how json_value returns it; null when it can't be passed from JSON
    procedure get_type(a_parameter ut_metadata.t_parameter, a_declaration out varchar2, a_returning out varchar2) is
      l_type varchar2(128 char) := a_parameter.data_type;
    begin
      case
        when l_type in ('NUMBER', 'FLOAT', 'BINARY_INTEGER') then
          a_declaration := 'number';
          a_returning := 'number';
        when l_type in ('BINARY_FLOAT', 'BINARY_DOUBLE') then
          a_declaration := lower(l_type);
          a_returning := 'number';
        when l_type in ('VARCHAR2', 'CHAR') then
          a_declaration := 'varchar2(32767)';
          a_returning := 'clob';
        when l_type in ('NVARCHAR2', 'NCHAR') then
          a_declaration := 'nvarchar2(32767)';
          a_returning := 'clob';
        when l_type in ('CLOB', 'NCLOB') then
          a_declaration := lower(l_type);
          a_returning := 'clob';
        when l_type in ('DATE', 'TIMESTAMP', 'TIMESTAMP WITH TIME ZONE', 'TIMESTAMP WITH LOCAL TIME ZONE') then
          -- read as text and converted with ut_utils.gc_test_case_timestamp_format, independent of the NLS settings
          a_declaration := replace(lower(l_type), 'timestamp', 'timestamp(9)');
          a_returning := 'varchar2(100)';
        when l_type = 'INTERVAL DAY TO SECOND' then
          a_declaration := 'interval day(9) to second(9)';
          a_returning := 'varchar2(100)';
        when l_type = 'INTERVAL YEAR TO MONTH' then
          a_declaration := 'interval year(9) to month';
          a_returning := 'varchar2(100)';
        when l_type = 'RAW' then
          a_declaration := 'raw(32767)';
          a_returning := 'varchar2(4000)';
        when l_type in ('BOOLEAN', 'PL/SQL BOOLEAN') then
          a_declaration := 'boolean';
        when l_type in ('OBJECT', 'TABLE', 'VARRAY') and a_parameter.type_subname is null and a_parameter.type_owner != 'PUBLIC' then
          a_declaration := '"' || a_parameter.type_owner || '"."' || a_parameter.type_name || '"';
          -- error on mismatch: a missing or misspelled attribute is an error instead of a null attribute
          a_returning := a_declaration || ' error on error error on mismatch';
        else
          null;
      end case;
    end;

    -- a call of the generated function that converts the JSON element a_value to the type of the parameter
    function convert(a_parameter ut_metadata.t_parameter, a_value varchar2) return varchar2 is
      l_key         varchar2(400 char) := a_parameter.data_type || '.' || a_parameter.type_owner || '.' || a_parameter.type_name;
      l_function    varchar2(30 char);
      l_declaration varchar2(400 char);
      l_returning   varchar2(400 char);
      l_value       varchar2(400 char);
    begin
      if not l_converters.exists(l_key) then
        get_type(a_parameter, l_declaration, l_returning);
        if l_declaration is null then
          raise_unsupported(a_parameter);
        end if;
        l_function := 'ut_convert_' || (l_converters.count + 1);
        l_converters(l_key) := l_function;
        if l_declaration = 'boolean' then
          -- SQL has no BOOLEAN before Oracle 23, so it is read with the PL/SQL JSON API
          l_functions := l_functions ||
            '  function ' || l_function || '(a_value json_element_t) return boolean is' || chr(10) ||
            '  begin' || chr(10) ||
            '    if a_value is null or a_value.is_null then' || chr(10) ||
            '      return null;' || chr(10) ||
            '    elsif a_value.is_true then' || chr(10) ||
            '      return true;' || chr(10) ||
            '    elsif a_value.is_false then' || chr(10) ||
            '      return false;' || chr(10) ||
            '    end if;' || chr(10) ||
            '    raise_application_error(' || c_error || ', ''Invalid JSON test case: true or false expected instead of '' || a_value.to_string || ''.'');' || chr(10) ||
            '  end;' || chr(10);
        else
          l_value := 'json_value(l_json, ''$[0]'' returning ' || l_returning || case when l_returning not like '% error on error%' then ' error on error' end || ')';
          l_value :=
            case
              when a_parameter.data_type in ('DATE', 'TIMESTAMP', 'TIMESTAMP WITH TIME ZONE', 'TIMESTAMP WITH LOCAL TIME ZONE') then
                'to_timestamp_tz(' || l_value || ', ''' || ut_utils.gc_test_case_timestamp_format || ''')'
              when a_parameter.data_type = 'INTERVAL DAY TO SECOND' then 'to_dsinterval(' || l_value || ')'
              when a_parameter.data_type = 'INTERVAL YEAR TO MONTH' then 'to_yminterval(' || l_value || ')'
              when a_parameter.data_type = 'RAW' then 'hextoraw(' || l_value || ')'
              else l_value
            end;
          l_functions := l_functions ||
            '  function ' || l_function || '(a_value json_element_t) return ' || regexp_replace(l_declaration, '\([0-9]+\)') || ' is' || chr(10) ||
            '    l_array  json_array_t := json_array_t();' || chr(10) ||
            '    l_json   clob;' || chr(10) ||
            '    l_result ' || l_declaration || ';' || chr(10) ||
            '  begin' || chr(10) ||
            '    if a_value is null or a_value.is_null then' || chr(10) ||
            '      return null;' || chr(10) ||
            '    end if;' || chr(10) ||
            -- json_value converts a scalar to an object or collection with all attributes null, so that is checked here
            case
              when a_parameter.data_type = 'OBJECT' then
                '    if not a_value.is_object then' || chr(10) ||
                '      raise_application_error(' || c_error || ', ''Invalid JSON test case: a JSON object expected instead of '' || a_value.to_string || ''.'');' || chr(10) ||
                '    end if;' || chr(10)
              when a_parameter.data_type in ('TABLE', 'VARRAY') then
                '    if not a_value.is_array then' || chr(10) ||
                '      raise_application_error(' || c_error || ', ''Invalid JSON test case: a JSON array expected instead of '' || a_value.to_string || ''.'');' || chr(10) ||
                '    end if;' || chr(10)
            end ||
            -- json_value reads from a JSON document, so the value is wrapped in an array
            '    l_array.append(a_value);' || chr(10) ||
            '    l_json := l_array.to_clob;' || chr(10) ||
            '    select ' || l_value || ' into l_result from dual;' || chr(10) ||
            '    return l_result;' || chr(10) ||
            '  end;' || chr(10);
        end if;
      end if;
      return l_converters(l_key) || '(' || a_value || ')';
    end;

    procedure add_argument(a_parameter ut_metadata.t_parameter, a_accessor varchar2) is
      l_variable    varchar2(30 char);
      l_declaration varchar2(400 char);
      l_returning   varchar2(400 char);
    begin
      l_count := l_count + 1;
      l_variable := 'l_ut_arg_' || l_count;
      get_type(a_parameter, l_declaration, l_returning);
      l_assignments := l_assignments || '  ' || l_variable || ' := ' || convert(a_parameter, 'l_ut_case.get(' || a_accessor || ')') || ';' || chr(10);
      l_declarations := l_declarations || '  ' || l_variable || ' ' || l_declaration || ';' || chr(10);
      l_arguments := l_arguments || case when l_arguments is not null then ', ' end || '"' || a_parameter.parameter_name || '" => ' || l_variable;
    end;

    -- a key that is no parameter is an error, not ignored, so that a misspelled key doesn't silently leave
    -- a parameter at its default (decided in #1326)
    function find_parameter(a_key varchar2) return ut_metadata.t_parameter is
      l_result ut_metadata.t_parameter;
    begin
      for i in 1 .. l_parameters.count loop
        if l_parameters(i).parameter_name = upper(a_key) then
          l_result := l_parameters(i);
        end if;
      end loop;
      if l_result.parameter_name is null then
        raise_invalid('the procedure has no parameter ' || a_key);
      end if;
      return l_result;
    end;
  begin
    for i in 1 .. l_all_parameters.count loop
      if l_all_parameters(i).overload != l_all_parameters(1).overload then
        raise_invalid('JSON test cases can''t be used with the overloaded procedure ' || upper(a_procedure));
      end if;
      if l_all_parameters(i).parameter_name is not null then
        l_parameters.extend;
        l_parameters(l_parameters.last) := l_all_parameters(i);
      end if;
    end loop;

    if l_element.is_array then
      l_case_type := 'json_array_t';
      l_array := treat(l_element as json_array_t);
      if l_array.get_size > l_parameters.count then
        raise_invalid(l_array.get_size || ' value(s) given, but the procedure has ' || l_parameters.count || ' parameter(s)');
      end if;
      for i in 0 .. l_array.get_size - 1 loop
        add_argument(l_parameters(i + 1), to_char(i));
        l_given.extend;
        l_given(l_given.last) := l_parameters(i + 1).parameter_name;
      end loop;
    else
      -- only JSON arrays and objects get here, see get_json_error and ut_test.get_source_test_cases
      l_case_type := 'json_object_t';
      l_keys := treat(l_element as json_object_t).get_keys;
      for i in 1 .. l_keys.count loop
        if upper(l_keys(i)) member of l_given then
          raise_invalid('parameter ' || upper(l_keys(i)) || ' is given twice');
        end if;
        l_given.extend;
        l_given(l_given.last) := upper(l_keys(i));
        -- the key matches a parameter name, so it can be used in a string literal as it is
        add_argument(find_parameter(l_keys(i)), '''' || l_keys(i) || '''');
      end loop;
    end if;
    l_index := l_parameters.first;
    while l_index is not null loop
      if l_parameters(l_index).defaulted = 'N' and not l_parameters(l_index).parameter_name member of l_given then
        raise_invalid('no value for parameter ' || l_parameters(l_index).parameter_name || ', which has no default value');
      end if;
      l_index := l_parameters.next(l_index);
    end loop;

    return
      'declare' || chr(10) ||
      '  l_ut_case ' || l_case_type || ' := ' || l_case_type || '.parse(:ut_json);' || chr(10) ||
      l_declarations ||
      l_functions ||
      'begin' || chr(10) ||
      l_assignments ||
      '  ' || a_call_name || case when l_arguments is not null then '(' || l_arguments || ')' end || ';' || chr(10) ||
      'end;';
  end;

end;
/
