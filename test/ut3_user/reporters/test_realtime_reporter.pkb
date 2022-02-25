create or replace package body test_realtime_reporter as

  g_events ut3_tester_helper.test_event_list := ut3_tester_helper.test_event_list();

  procedure create_test_suites_and_run is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package check_realtime_reporting1 is
      --%suite(suite <A>)
      --%suitepath(realtime_reporting)

      --%context
      --%name(test_context)

      --%test(test 1 - OK) 
      procedure test_1_ok;
      
      --%test(test 2 - NOK)
      procedure test_2_nok;

      --%endcontext
    end;]';
    execute immediate q'[create or replace package body check_realtime_reporting1 is
      procedure test_1_ok is
      begin
        ut3_develop.ut.expect(1).to_equal(1);
      end;

      procedure test_2_nok is
      begin
        ut3_develop.ut.expect(1).to_equal(2);
      end;
    end;]';
    
    execute immediate q'[create or replace package check_realtime_reporting2 is
      --%suite
      --%suitepath(realtime_reporting)

      --%test 
      procedure test_3_ok;
      
      --%test
      procedure test_4_nok;

      --%test
      --%disabled
      procedure test_5;

      --%test
      --%disabled(Cannot run this item at this time runtime > 10 mins.)
      procedure test_6_disabled_reason;
    end;]';
    execute immediate q'[create or replace package body check_realtime_reporting2 is
      procedure test_3_ok is
      begin
        ut3_develop.ut.expect(2).to_equal(2);
      end;

      procedure test_4_nok is
      begin
        ut3_develop.ut.expect(2).to_equal(3);
        ut3_develop.ut.expect(2).to_equal(4);
      end;
      
      procedure test_5 is
      begin
        null;
      end;

      procedure test_6_disabled_reason is
      begin
        null;
      end;
    end;]';
 
    execute immediate q'[create or replace package check_realtime_reporting3 is
      --%suite
      --%suitepath(realtime_reporting)

      --%test 
      procedure test_6_with_runtime_error;
      
      --%test
      procedure test_7_with_serveroutput;

      --%afterall
      procedure print_and_raise;
    end;]';
    execute immediate q'[create or replace package body check_realtime_reporting3 is
      procedure test_6_with_runtime_error is
        l_actual integer;
      begin
        execute immediate 'select 6 from non_existing_table' into l_actual;
        ut3_develop.ut.expect(6).to_equal(l_actual);
      end;

      procedure test_7_with_serveroutput is
      begin
        dbms_output.put_line('before test 7');
        ut3_develop.ut.expect(7).to_equal(7);
        dbms_output.put_line('after test 7');
      end;

      procedure print_and_raise is
      begin
        dbms_output.put_line('Now, a no_data_found exception is raised');
        dbms_output.put_line('dbms_output and error stack is reported for this suite.');
        dbms_output.put_line('A runtime error in afterall is counted as a warning.');
        raise no_data_found;
      end;
    end;]';

    execute immediate q'[create or replace package check_realtime_reporting4 is
      --%suite
      --%suitepath(realtime_reporting)
      /* tag annotation without parameter will raise a warning */
      --%tags

      --%test 
      procedure test_8_with_warning;
    end;]';
    execute immediate q'[create or replace package body check_realtime_reporting4 is
      procedure test_8_with_warning is
      begin
        commit; -- this will raise a warning
        ut3_develop.ut.expect(8).to_equal(8);
      end;
    end;]';
    
    execute immediate q'[create or replace package check_realtime_reporting5 is
      --%suite
      --%suitepath(realtime_reporting_bufix)

      --%test(test XML with nested CDATA)
      procedure test_nested_cdata;
    end;]';
    
    execute immediate q'[create or replace package body check_realtime_reporting5 is
      procedure test_nested_cdata is
      begin
        dbms_output.put_line('nested cdata block: <![CDATA[...]]>, to be handled.');
        ut.expect(1).to_equal(1);
      end;
   end;]';

    <<run_report_and_cache_result>>
    declare 
      l_reporter ut3_develop.ut_realtime_reporter := ut3_develop.ut_realtime_reporter();
    begin
      -- produce
      ut3_develop.ut_runner.run(
         a_paths     => ut3_develop.ut_varchar2_list(':realtime_reporting'),
         a_reporters => ut3_develop.ut_reporters(l_reporter)
      );
      -- consume
      select ut3_tester_helper.test_event_object(item_type, xmltype(text))
        bulk collect into g_events
        from table(l_reporter.get_lines())
        where trim(text) is not null and item_type is not null;
    end run_report_and_cache_result;
  end create_test_suites_and_run;
  
  procedure xml_report_structure is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    open l_actual for
      select t.event_doc.extract('/event/@type').getstringval()                     as event_type, 
             t.event_doc.extract('/event/suite/@id|/event/test/@id').getstringval() as item_id
        from table(g_events) t;
    open l_expected for
      select 'pre-run'    as event_type, null                                                                     as item_id from dual union all
      select 'pre-suite'  as event_type, 'realtime_reporting'                                                     as item_id from dual union all
      select 'pre-suite'  as event_type, 'realtime_reporting.check_realtime_reporting4'                           as item_id from dual union all
      select 'pre-test'   as event_type, 'realtime_reporting.check_realtime_reporting4.test_8_with_warning'       as item_id from dual union all
      select 'post-test'  as event_type, 'realtime_reporting.check_realtime_reporting4.test_8_with_warning'       as item_id from dual union all
      select 'post-suite' as event_type, 'realtime_reporting.check_realtime_reporting4'                           as item_id from dual union all
      select 'pre-suite'  as event_type, 'realtime_reporting.check_realtime_reporting3'                           as item_id from dual union all
      select 'pre-test'   as event_type, 'realtime_reporting.check_realtime_reporting3.test_6_with_runtime_error' as item_id from dual union all
      select 'post-test'  as event_type, 'realtime_reporting.check_realtime_reporting3.test_6_with_runtime_error' as item_id from dual union all
      select 'pre-test'   as event_type, 'realtime_reporting.check_realtime_reporting3.test_7_with_serveroutput'  as item_id from dual union all
      select 'post-test'  as event_type, 'realtime_reporting.check_realtime_reporting3.test_7_with_serveroutput'  as item_id from dual union all
      select 'post-suite' as event_type, 'realtime_reporting.check_realtime_reporting3'                           as item_id from dual union all
      select 'pre-suite'  as event_type, 'realtime_reporting.check_realtime_reporting2'                           as item_id from dual union all
      select 'pre-test'   as event_type, 'realtime_reporting.check_realtime_reporting2.test_3_ok'                 as item_id from dual union all
      select 'post-test'  as event_type, 'realtime_reporting.check_realtime_reporting2.test_3_ok'                 as item_id from dual union all
      select 'pre-test'   as event_type, 'realtime_reporting.check_realtime_reporting2.test_4_nok'                as item_id from dual union all
      select 'post-test'  as event_type, 'realtime_reporting.check_realtime_reporting2.test_4_nok'                as item_id from dual union all
      select 'pre-test'   as event_type, 'realtime_reporting.check_realtime_reporting2.test_5'                    as item_id from dual union all
      select 'post-test'  as event_type, 'realtime_reporting.check_realtime_reporting2.test_5'                    as item_id from dual union all
      select 'pre-test'   as event_type, 'realtime_reporting.check_realtime_reporting2.test_6_disabled_reason'    as item_id from dual union all
      select 'post-test'  as event_type, 'realtime_reporting.check_realtime_reporting2.test_6_disabled_reason'    as item_id from dual union all
      select 'post-suite' as event_type, 'realtime_reporting.check_realtime_reporting2'                           as item_id from dual union all
      select 'pre-suite'  as event_type, 'realtime_reporting.check_realtime_reporting1'                           as item_id from dual union all
      select 'pre-suite'  as event_type, 'realtime_reporting.check_realtime_reporting1.test_context'              as item_id from dual union all
      select 'pre-test'   as event_type, 'realtime_reporting.check_realtime_reporting1.test_context.test_1_ok'    as item_id from dual union all
      select 'post-test'  as event_type, 'realtime_reporting.check_realtime_reporting1.test_context.test_1_ok'    as item_id from dual union all
      select 'pre-test'   as event_type, 'realtime_reporting.check_realtime_reporting1.test_context.test_2_nok'   as item_id from dual union all
      select 'post-test'  as event_type, 'realtime_reporting.check_realtime_reporting1.test_context.test_2_nok'   as item_id from dual union all
      select 'post-suite' as event_type, 'realtime_reporting.check_realtime_reporting1.test_context'              as item_id from dual union all
      select 'post-suite' as event_type, 'realtime_reporting.check_realtime_reporting1'                           as item_id from dual union all
      select 'post-suite' as event_type, 'realtime_reporting'                                                     as item_id from dual union all
      select 'post-run'   as event_type, null                                                                     as item_id from dual;
    ut.expect(l_actual).to_equal(l_expected);
  end xml_report_structure;

  procedure pre_run_composite_nodes is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    open l_actual for 
      select x.node_path
        from table(g_events) t,
             xmltable(
               q'[
                 for $i in //(event|items|suite|test)
                 return <result>{$i/string-join(ancestor-or-self::*/name(.), '/')}</result>
               ]'
               passing t.event_doc
               columns node_path varchar2(128) path '.'
             ) x
       where event_type = 'pre-run';
      open l_expected for
        select 'event'                                                as node_path from dual union all
        select 'event/items'                                          as node_path from dual union all
        select 'event/items/suite'                                    as node_path from dual union all
        select 'event/items/suite/items'                              as node_path from dual union all
        select 'event/items/suite/items/suite'                        as node_path from dual union all
        select 'event/items/suite/items/suite/items'                  as node_path from dual union all
        select 'event/items/suite/items/suite/items/test'             as node_path from dual union all
        select 'event/items/suite/items/suite'                        as node_path from dual union all
        select 'event/items/suite/items/suite/items'                  as node_path from dual union all
        select 'event/items/suite/items/suite/items/test'             as node_path from dual union all
        select 'event/items/suite/items/suite/items/test'             as node_path from dual union all
        select 'event/items/suite/items/suite'                        as node_path from dual union all
        select 'event/items/suite/items/suite/items'                  as node_path from dual union all
        select 'event/items/suite/items/suite/items/test'             as node_path from dual union all
        select 'event/items/suite/items/suite/items/test'             as node_path from dual union all
        select 'event/items/suite/items/suite/items/test'             as node_path from dual union all
        select 'event/items/suite/items/suite/items/test'             as node_path from dual union all
        select 'event/items/suite/items/suite'                        as node_path from dual union all
        select 'event/items/suite/items/suite/items'                  as node_path from dual union all
        select 'event/items/suite/items/suite/items/suite'            as node_path from dual union all
        select 'event/items/suite/items/suite/items/suite/items'      as node_path from dual union all
        select 'event/items/suite/items/suite/items/suite/items/test' as node_path from dual union all
        select 'event/items/suite/items/suite/items/suite/items/test' as node_path from dual;
      ut.expect(l_actual).to_equal(l_expected);
  end pre_run_composite_nodes;
  
  procedure total_number_of_tests is
    l_actual   integer;
    l_expected integer := 9;
  begin
    select t.event_doc.extract('/event/totalNumberOfTests/text()').getnumberval()
      into l_actual
      from table(g_events) t
     where t.event_type = 'pre-run';
    ut.expect(l_actual).to_equal(l_expected);
  end total_number_of_tests;
  
  procedure execution_time_of_run is
    l_actual number;
  begin
    select t.event_doc.extract('/event/run/executionTime/text()').getnumberval()
      into l_actual
      from table(g_events) t
     where t.event_type = 'post-run';
    ut.expect(l_actual).to_be_not_null;
  end execution_time_of_run;
  
  procedure escaped_characters is
    l_actual   varchar2(32767);
    l_expected varchar2(20) := 'suite &lt;A&gt;'; 
  begin
    select t.event_doc.extract(
             '//suite[@id="realtime_reporting.check_realtime_reporting1"]/description/text()'
           ).getstringval()
      into l_actual
      from table(g_events) t
     where t.event_type = 'pre-run';
    ut.expect(l_actual).to_equal(l_expected);
  end escaped_characters;
  
  procedure pre_test_nodes is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    open l_actual for
       select t.event_doc.extract('//test/testNumber/text()')
                .getnumberval() as test_number,
              t.event_doc.extract('//test/totalNumberOfTests/text()')
                .getnumberval() as total_number_of_tests
         from table(g_events) t
        where t.event_type = 'pre-test'
          and t.event_doc.extract('//test/@id').getstringval() is not null;
    open l_expected for
       select level as test_number, 
              9     as total_number_of_tests
         from dual
      connect by level <= 9;
    ut.expect(l_actual).to_equal(l_expected).unordered;
  end pre_test_nodes;
  
  procedure post_test_nodes is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    open l_actual for
       select t.event_doc.extract('//test/testNumber/text()')
                .getnumberval() as test_number,
              t.event_doc.extract('//test/totalNumberOfTests/text()')
                .getnumberval() as total_number_of_tests
         from table(g_events) t
        where t.event_type = 'post-test'
          and t.event_doc.extract('//test/@id').getstringval() is not null
          and t.event_doc.extract('//test/startTime/text()').getstringval() is not null
          and t.event_doc.extract('//test/endTime/text()').getstringval() is not null
          and t.event_doc.extract('//test/executionTime/text()').getnumberval() is not null
          and t.event_doc.extract('//test/counter/disabled/text()').getnumberval() is not null
          and t.event_doc.extract('//test/counter/success/text()').getnumberval() is not null
          and t.event_doc.extract('//test/counter/failure/text()').getnumberval() is not null
          and t.event_doc.extract('//test/counter/error/text()').getnumberval() is not null
          and t.event_doc.extract('//test/counter/warning/text()').getnumberval() is not null;
    open l_expected for
       select level as test_number, 
              9     as total_number_of_tests
         from dual
      connect by level <= 9;
    ut.expect(l_actual).to_equal(l_expected).unordered;
  end post_test_nodes;

  procedure single_failed_message is
    l_actual   varchar2(32767);
    l_expected varchar2(80) := '<![CDATA[Actual: 1 (number) was expected to equal: 2 (number)]]>';
  begin
    select t.event_doc.extract(
             '/event/test/failedExpectations/expectation[1]/message/text()'
           ).getstringval()
      into l_actual
      from table(g_events) t
     where t.event_doc.extract('/event[@type="post-test"]/test/@id').getstringval() 
           = 'realtime_reporting.check_realtime_reporting1.test_context.test_2_nok';
    ut.expect(l_actual).to_equal(l_expected);
  end single_failed_message;
  
  procedure multiple_failed_messages is
    l_actual   integer;
    l_expected integer := 2;
  begin
    select count(*)
      into l_actual
      from table(g_events) t, 
           xmltable(
             '/event/test/failedExpectations/expectation'
             passing t.event_doc
             columns message clob path 'message',
                     caller  clob path 'caller'
           ) x
     where t.event_doc.extract('/event[@type="post-test"]/test/@id').getstringval() 
            = 'realtime_reporting.check_realtime_reporting2.test_4_nok'
       and x.message is not null 
       and x.caller is not null;
    ut.expect(l_actual).to_equal(l_expected);
  end multiple_failed_messages;
  
  procedure serveroutput_of_test is
    l_actual   clob;
    l_expected_list ut3_develop.ut_varchar2_list;
    l_expected clob;
  begin
    select t.event_doc.extract('//event/test/serverOutput/text()').getstringval()
      into l_actual
      from table(g_events) t
     where t.event_doc.extract('/event[@type="post-test"]/test/@id').getstringval() 
           = 'realtime_reporting.check_realtime_reporting3.test_7_with_serveroutput';
    ut3_tester_helper.main_helper.append_to_list(l_expected_list, '<![CDATA[before test 7');
    ut3_tester_helper.main_helper.append_to_list(l_expected_list, 'after test 7');
    ut3_tester_helper.main_helper.append_to_list(l_expected_list, ']]>');
    l_expected := ut3_tester_helper.main_helper.table_to_clob(l_expected_list);
    ut.expect(l_actual).to_equal(l_expected);
  end serveroutput_of_test;
 
  procedure serveroutput_of_testsuite is
    l_actual   clob;
    l_expected_list ut3_develop.ut_varchar2_list;
    l_expected clob;
  begin
    select t.event_doc.extract('//event/suite/serverOutput/text()').getstringval()
      into l_actual
      from table(g_events) t
     where t.event_doc.extract('/event[@type="post-suite"]/suite/@id').getstringval() 
           = 'realtime_reporting.check_realtime_reporting3';
    ut3_tester_helper.main_helper.append_to_list(l_expected_list, '<![CDATA[Now, a no_data_found exception is raised');
    ut3_tester_helper.main_helper.append_to_list(l_expected_list, 'dbms_output and error stack is reported for this suite.');
    ut3_tester_helper.main_helper.append_to_list(l_expected_list, 'A runtime error in afterall is counted as a warning.');
    ut3_tester_helper.main_helper.append_to_list(l_expected_list, ']]>');
    l_expected := ut3_tester_helper.main_helper.table_to_clob(l_expected_list);
    ut.expect(l_actual).to_equal(l_expected);
  end serveroutput_of_testsuite;

  procedure error_stack_of_test is
    l_actual   clob;
    l_expected_list ut3_develop.ut_varchar2_list;
    l_expected clob;
  begin
    select t.event_doc.extract('//event/test/errorStack/text()').getstringval()
      into l_actual
      from table(g_events) t
     where t.event_doc.extract('/event[@type="post-test"]/test/@id').getstringval() 
           = 'realtime_reporting.check_realtime_reporting3.test_6_with_runtime_error';
    ut3_tester_helper.main_helper.append_to_list(l_expected_list, '<![CDATA[ORA-00942: table or view does not exist');
    ut3_tester_helper.main_helper.append_to_list(l_expected_list, 'ORA-06512: at "%.CHECK_REALTIME_REPORTING3", line 5');
    ut3_tester_helper.main_helper.append_to_list(l_expected_list, '%ORA-06512: at line 6]]>');
    l_expected := ut3_tester_helper.main_helper.table_to_clob(l_expected_list);
    ut.expect(l_actual).to_be_like(l_expected);
  end error_stack_of_test;

  procedure error_stack_of_testsuite is
    l_actual   clob;
    l_expected_list ut3_develop.ut_varchar2_list;
    l_expected clob;
  begin
    select t.event_doc.extract('//event/suite/errorStack/text()').getstringval()
      into l_actual
      from table(g_events) t
     where t.event_doc.extract('/event[@type="post-suite"]/suite/@id').getstringval() 
           = 'realtime_reporting.check_realtime_reporting3';
    ut3_tester_helper.main_helper.append_to_list(l_expected_list, '<![CDATA[ORA-01403: no data found');
    ut3_tester_helper.main_helper.append_to_list(l_expected_list, 'ORA-06512: at "%.CHECK_REALTIME_REPORTING3", line 21');
    ut3_tester_helper.main_helper.append_to_list(l_expected_list, '%ORA-06512: at line 6]]>');
    l_expected := ut3_tester_helper.main_helper.table_to_clob(l_expected_list);
    ut.expect(l_actual).to_be_like(l_expected);
  end error_stack_of_testsuite;

  procedure warnings_of_test is
    l_actual   clob;
    l_expected_list ut3_develop.ut_varchar2_list;
    l_expected clob;
  begin
    select t.event_doc.extract('//event/test/warnings/text()').getstringval()
      into l_actual
      from table(g_events) t
     where t.event_doc.extract('/event[@type="post-test"]/test/@id').getstringval() 
           = 'realtime_reporting.check_realtime_reporting4.test_8_with_warning';
    ut3_tester_helper.main_helper.append_to_list(l_expected_list, '<![CDATA[Unable to perform automatic rollback after test.%');
    ut3_tester_helper.main_helper.append_to_list(l_expected_list, 'Use the "--%rollback(manual)" annotation %]]>');
    l_expected := ut3_tester_helper.main_helper.table_to_clob(l_expected_list);
    ut.expect(l_actual).to_be_like(l_expected);    
  end warnings_of_test;

  procedure warnings_of_testsuite is
    l_actual   clob;
    l_expected_list ut3_develop.ut_varchar2_list;
    l_expected clob;
  begin
    select t.event_doc.extract('//event/suite/warnings/text()').getstringval()
      into l_actual
      from table(g_events) t
     where t.event_doc.extract('/event[@type="post-suite"]/suite/@id').getstringval() 
           = 'realtime_reporting.check_realtime_reporting4';
    ut3_tester_helper.main_helper.append_to_list(l_expected_list, '<![CDATA["--%tags" annotation requires a tag value populated.%');
    ut3_tester_helper.main_helper.append_to_list(l_expected_list, '%');
    ut3_tester_helper.main_helper.append_to_list(l_expected_list, 'Unable to perform automatic rollback after test suite.%');
    ut3_tester_helper.main_helper.append_to_list(l_expected_list, '%');
    ut3_tester_helper.main_helper.append_to_list(l_expected_list, 'Use the "--%rollback(manual)" annotation%.]]>');
    l_expected := ut3_tester_helper.main_helper.table_to_clob(l_expected_list);
    ut.expect(l_actual).to_be_like(l_expected);
  end warnings_of_testsuite;

  procedure get_description is
    l_reporter ut3_develop.ut_realtime_reporter;
    l_actual varchar2(4000);
    l_expected varchar2(80) := '%SQL Developer%';
  begin
    l_reporter := ut3_develop.ut_realtime_reporter();
    l_actual := l_reporter.get_description();
    ut.expect(l_actual).to_be_like(l_expected);
  end get_description;
  
  procedure nested_cdata_output is
    l_text     varchar2(4000);
    l_xml      xmltype;
    --
    function produce_and_consume return varchar2 is
      pragma autonomous_transaction;
      l_reporter ut3_develop.ut_realtime_reporter := ut3_develop.ut_realtime_reporter();
      l_text varchar2(4000);
    begin
      -- produce
      ut3_develop.ut_runner.run(
        a_paths     => ut3_develop.ut_varchar2_list(':realtime_reporting_bufix'),
        a_reporters => ut3_develop.ut_reporters(l_reporter)
      );
      -- consume
      select text
        into l_text
        from table(l_reporter.get_lines())
       where item_type = 'post-test';
      return l_text;
    end produce_and_consume; 
  begin
    l_text := produce_and_consume();
    ut.expect(l_text).to_be_not_null();
    -- this fails, if l_text is not a valid XML
    l_xml := xmltype(l_text);
    ut.expect(l_xml is not null).to_be_true();
  end;

  procedure disabled_reason is
    l_actual   varchar2(32767);
    l_expected varchar2(80) := dbms_xmlgen.convert('Cannot run this item at this time runtime > 10 mins.');
  begin
    select t.event_doc.extract(
             '//test/disabledReason/text()'
           ).getstringval()
      into l_actual
      from table(g_events) t
     where xmlexists(
       '/event[@type="pre-run"]/*//test[@id="realtime_reporting.check_realtime_reporting2.test_6_disabled_reason"]'
       passing t.event_doc
    );
    ut.expect(l_actual).to_equal(l_expected);
  end;

  procedure remove_test_suites is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package check_realtime_reporting1';
    execute immediate 'drop package check_realtime_reporting2';
    execute immediate 'drop package check_realtime_reporting3';
    execute immediate 'drop package check_realtime_reporting4';
    execute immediate 'drop package check_realtime_reporting5';
  end remove_test_suites;

end test_realtime_reporter;
/
