create or replace package body core is

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

  procedure global_setup is
  begin
    dbms_output.enable(null);
    ut3.ut_coverage.set_develop_mode(true);
    --improve performance of test execution by disabling all compiler optimizations
    execute_autonomous('ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL=0');

    execute_autonomous(
      q'[create or replace package ut_transaction_control as
            function count_rows(a_val varchar2) return number;
            procedure setup;
            procedure test;
            procedure test_failure;
         end;]'
    );
    execute_autonomous(
      q'[create or replace package body ut_transaction_control
          as

            function count_rows(a_val varchar2) return number is
              l_cnt number;
            begin
              select count(*) into l_cnt from ut$test_table t where t.val = a_val;
              return l_cnt;
            end;
            procedure setup is begin
              insert into ut$test_table values ('s');
            end;
            procedure test is
            begin
              insert into ut$test_table values ('t');
            end;
            procedure test_failure is
            begin
              insert into ut$test_table values ('t');
              --raise no_data_found;
              raise_application_error(-20001,'Error');
            end;
         end;]'
    );
  end;

  procedure global_cleanup is
  begin
    execute_autonomous('drop package ut_transaction_control');
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

end;
/
