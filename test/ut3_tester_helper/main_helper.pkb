create or replace package body main_helper is

  function get_dbms_output_as_clob return clob is
    l_status number;
    l_line   varchar2(32767);
    l_result clob;
  begin

    dbms_output.get_line(line => l_line, status => l_status);
    if l_status != 1 then
      dbms_lob.createtemporary(l_result, true, dur => dbms_lob.session);
      end if;
    while l_status != 1 loop
      if l_line is not null then
        ut3.ut_utils.append_to_clob(l_result, l_line||chr(10));
        end if;
      dbms_output.get_line(line => l_line, status => l_status);
    end loop;
    return l_result;
  end;

  procedure execute_autonomous(a_sql varchar2) is
    pragma autonomous_transaction;
  begin
    if a_sql is not null then
      execute immediate a_sql;
    end if;
    commit;
  end;

  function run_test(a_path varchar2) return clob is
    l_lines    ut3.ut_varchar2_list;
  begin
    select * bulk collect into l_lines from table(ut3.ut.run(a_path));
    return ut3.ut_utils.table_to_clob(l_lines);
  end;

  function get_value(a_variable varchar2) return integer is
    l_glob_val integer;
  begin
    execute immediate 'begin :l_glob_val := '||a_variable||'; end;' using out l_glob_val;
    return l_glob_val;
  end;

  function get_failed_expectations return ut3.ut_varchar2_list is
    l_expectations_result ut3.ut_expectation_results := ut3.ut_expectation_processor.get_failed_expectations();
    l_result ut3.ut_varchar2_list := ut3.ut_varchar2_list();
  begin
    for i in 1..l_expectations_result.count loop
      l_result := l_result multiset union l_expectations_result(i).get_result_lines();
    end loop;
    return l_result;
  end;    

  function get_failed_expectations(a_pos in number) return varchar2 is
    l_result varchar2(32767) := ut3.ut_expectation_processor.get_failed_expectations()(a_pos).message;
  begin
    return l_result;
  end;  
  
  function failed_expectations_data return anydata is
  begin
    return anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations());
  end;
  
  function get_failed_expectations_n return number is
    l_num_failed number;
    l_results ut3.ut_expectation_results := ut3.ut_expectation_processor.get_failed_expectations();
  begin
    l_num_failed := l_results.count;
    return l_num_failed;
  end;
  
  procedure clear_expectations is
  begin
    ut3.ut_expectation_processor.clear_expectations();
  end;  
  
  function table_to_clob(a_results in ut3.ut_varchar2_list) return clob is
  begin
    return ut3.ut_utils.table_to_clob(a_results);
  end;
  
  function get_warnings return ut3.ut_varchar2_rows is
  begin
    return ut3.ut_expectation_processor.get_warnings();
  end;
  
  procedure reset_nulls_equal is
  begin
    ut3.ut_expectation_processor.nulls_Are_equal(ut3.ut_expectation_processor.gc_default_nulls_are_equal);
  end;
  
  procedure nulls_are_equal(a_nulls_equal boolean := true) is
  begin
    ut3.ut_expectation_processor.nulls_Are_equal(a_nulls_equal);
  end;
  
end;
/
