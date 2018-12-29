create or replace package body test_realtime_reporter as

  g_actual_xml_report xmltype;

  procedure create_test_suites_and_run is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package check_realtime_reporting1 is
      --%suite(suite <A>)
      --%suitepath(realtime_reporting)

      --%context(test context)

      --%test(test 1 - OK) 
      procedure test_1_ok;
      
      --%test(test 2 - NOK)
      procedure test_2_nok;

      --%endcontext
    end;]';
    execute immediate q'[create or replace package body check_realtime_reporting1 is
      procedure test_1_ok is
      begin
        ut3.ut.expect(1).to_equal(1);
      end;

      procedure test_2_nok is
      begin
        ut3.ut.expect(1).to_equal(2);
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
    end;]';
    execute immediate q'[create or replace package body check_realtime_reporting2 is
      procedure test_3_ok is
      begin
        ut3.ut.expect(2).to_equal(2);
      end;

      procedure test_4_nok is
      begin
        ut3.ut.expect(2).to_equal(3);
        ut3.ut.expect(2).to_equal(4);
      end;
      
      procedure test_5 is
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
        ut3.ut.expect(6).to_equal(l_actual);
      end;

      procedure test_7_with_serveroutput is
      begin
        dbms_output.put_line('before test 7');
        ut3.ut.expect(7).to_equal(7);
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
    
    <<run_report_and_cache_result>>
    declare
      l_results ut3.ut_varchar2_list;
    begin
      select *
        bulk collect into l_results
        from table(ut3.ut.run('ut3_tester:realtime_reporting', ut3.ut_realtime_reporter()));
      g_actual_xml_report := xmltype(ut3.ut_utils.table_to_clob(l_results));
    end run_report_and_cache_result;
  end create_test_suites_and_run;
  
  procedure xml_report_structure is
    l_actual        clob;
    l_expected_list ut3.ut_varchar2_list;
    l_expected      clob;
  begin
    l_actual := g_actual_xml_report.getclobval();
    ut3.ut_utils.append_to_list(l_expected_list, '<?xml version="1.0"?>');
    ut3.ut_utils.append_to_list(l_expected_list, '%<report>');
    ut3.ut_utils.append_to_list(l_expected_list, '%  <preRun>');
    ut3.ut_utils.append_to_list(l_expected_list, '%    <suites>');
    ut3.ut_utils.append_to_list(l_expected_list, '%      <suite id="%">');
    ut3.ut_utils.append_to_list(l_expected_list, '%        %<test id="%">');
    ut3.ut_utils.append_to_list(l_expected_list, '%        %</test>');
    ut3.ut_utils.append_to_list(l_expected_list, '%      </suite>');
    ut3.ut_utils.append_to_list(l_expected_list, '%    </suites>');
    ut3.ut_utils.append_to_list(l_expected_list, '%    <totalNumberOfTests>%</totalNumberOfTests>');
    ut3.ut_utils.append_to_list(l_expected_list, '%  </preRun>');
    ut3.ut_utils.append_to_list(l_expected_list, '%  <runEvents>');
    ut3.ut_utils.append_to_list(l_expected_list, '%    <startSuiteEvent id="%">');
    ut3.ut_utils.append_to_list(l_expected_list, '%    </startTestEvent>');
    ut3.ut_utils.append_to_list(l_expected_list, '%    <startTestEvent id="%">');
    ut3.ut_utils.append_to_list(l_expected_list, '%    </startTestEvent>');
    ut3.ut_utils.append_to_list(l_expected_list, '%    <endTestEvent id="%">');
    ut3.ut_utils.append_to_list(l_expected_list, '%    </endTestEvent>');
    ut3.ut_utils.append_to_list(l_expected_list, '%    <endSuiteEvent id="%">');
    ut3.ut_utils.append_to_list(l_expected_list, '%    </endSuiteEvent>');
    ut3.ut_utils.append_to_list(l_expected_list, '%  </runEvents>');
    ut3.ut_utils.append_to_list(l_expected_list, '%</report>');
    l_expected := ut3.ut_utils.table_to_clob(l_expected_list, null);
    ut.expect(l_actual).to_be_like(l_expected);
  end xml_report_structure;
  
  procedure total_number_of_tests is
    l_actual   integer;
    l_expected integer := 7; 
  begin
    l_actual := g_actual_xml_report.extract('/report/preRun/totalNumberOfTests/text()').getnumberval();
    ut.expect(l_actual).to_equal(l_expected);
  end total_number_of_tests; 
  
  procedure escaped_characters is
    l_actual   varchar2(32767);
    l_expected varchar2(20) := 'suite &lt;A&gt;'; 
  begin
    l_actual := 
      g_actual_xml_report.extract(
        '//suite[@id="realtime_reporting.check_realtime_reporting1"]/description/text()'
      ).getstringval();
    ut.expect(l_actual).to_equal(l_expected);
  end escaped_characters;
  
  procedure number_of_starttestevent_nodes is
    l_actual   integer;
    l_expected integer := 7;
  begin
    select count(*)
      into l_actual
      from xmltable(
             '/report/runEvents/startTestEvent'
             passing g_actual_xml_report
             columns id                    varchar2(4000) path '@id',
                     test_number           integer        path 'testNumber',
                     total_number_of_tests integer        path 'totalNumberOfTests'
           )
     where id is not null
       and test_number is not null
       and total_number_of_tests is not null;
    ut.expect(l_actual).to_equal(l_expected);
  end number_of_starttestevent_nodes;
  
  procedure endtestevent_nodes is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    open l_actual for
      select test_number, total_number_of_tests
        from xmltable(
               '/report/runEvents/endTestEvent'
               passing g_actual_xml_report
               columns id                    varchar2(4000) path '@id',
                       test_number           integer        path 'testNumber',
                       total_number_of_tests integer        path 'totalNumberOfTests'
             )
       where id is not null
         and test_number is not null
         and total_number_of_tests is not null;
    open l_expected for
       select level as test_number, 
              7     as total_number_of_tests 
         from dual
      connect by level <= 7;
    ut.expect(l_actual).to_equal(l_expected).unordered;
  end endtestevent_nodes;

  procedure single_failed_message is
    l_actual   varchar2(32767);
    l_expected varchar2(80) := '<![CDATA[Actual: 1 (number) was expected to equal: 2 (number) ]]>';
  begin
    l_actual := 
      g_actual_xml_report.extract(
        '/report/runEvents/endTestEvent[@id="realtime_reporting.check_realtime_reporting1.test context.test_2_nok"]/failedExpectations/expectation[1]/message/text()'
      ).getstringval();
    ut.expect(l_actual).to_equal(l_expected);
  end single_failed_message;
  
  procedure multiple_failed_messages is
    l_actual   integer;
    l_expected integer := 2;
  begin
    select count(*)
      into l_actual
      from xmltable(
             '/report/runEvents/endTestEvent[@id="realtime_reporting.check_realtime_reporting2.test_4_nok"]/failedExpectations/expectation'
             passing g_actual_xml_report
             columns message clob path 'message',
                     caller  clob path 'caller'
           )
     where message is not null 
       and caller is not null;
    ut.expect(l_actual).to_equal(l_expected);
  end multiple_failed_messages;
  
  procedure serveroutput_of_test is
    l_actual   clob;
    l_expected_list ut3.ut_varchar2_list;
    l_expected clob;
  begin
    l_actual := 
      g_actual_xml_report.extract(
        '/report/runEvents/endTestEvent[@id="realtime_reporting.check_realtime_reporting3.test_7_with_serveroutput"]/serverOutput/text()'
      ).getclobval();
    ut3.ut_utils.append_to_list(l_expected_list, '<![CDATA[before test 7');
    ut3.ut_utils.append_to_list(l_expected_list, 'after test 7');
    ut3.ut_utils.append_to_list(l_expected_list, ']]>');
    l_expected := ut3.ut_utils.table_to_clob(l_expected_list);
    ut.expect(l_actual).to_equal(l_expected);
  end serveroutput_of_test;
 
  procedure serveroutput_of_testsuite is
    l_actual   clob;
    l_expected_list ut3.ut_varchar2_list;
    l_expected clob;
  begin
    l_actual := 
      g_actual_xml_report.extract(
        '/report/runEvents/endSuiteEvent[@id="realtime_reporting.check_realtime_reporting3"]/serverOutput/text()'
      ).getclobval();
    ut3.ut_utils.append_to_list(l_expected_list, '<![CDATA[Now, a no_data_found exception is raised');
    ut3.ut_utils.append_to_list(l_expected_list, 'dbms_output and error stack is reported for this suite.');
    ut3.ut_utils.append_to_list(l_expected_list, 'A runtime error in afterall is counted as a warning.');
    ut3.ut_utils.append_to_list(l_expected_list, ']]>');
    l_expected := ut3.ut_utils.table_to_clob(l_expected_list);
    ut.expect(l_actual).to_equal(l_expected);
  end serveroutput_of_testsuite;

  procedure error_stack_of_test is
    l_actual   clob;
    l_expected_list ut3.ut_varchar2_list;
    l_expected clob;
  begin
    l_actual := 
      g_actual_xml_report.extract(
        '/report/runEvents/endTestEvent[@id="realtime_reporting.check_realtime_reporting3.test_6_with_runtime_error"]/errorStack/text()'
      ).getclobval();
    ut3.ut_utils.append_to_list(l_expected_list, '<![CDATA[ORA-00942: table or view does not exist');
    ut3.ut_utils.append_to_list(l_expected_list, 'ORA-06512: at "%.CHECK_REALTIME_REPORTING3", line 5');
    ut3.ut_utils.append_to_list(l_expected_list, '%ORA-06512: at line 6]]>');
    l_expected := ut3.ut_utils.table_to_clob(l_expected_list);
    ut.expect(l_actual).to_be_like(l_expected);
  end error_stack_of_test;

  procedure error_stack_of_testsuite is
    l_actual   clob;
    l_expected_list ut3.ut_varchar2_list;
    l_expected clob;
  begin
    l_actual := 
      g_actual_xml_report.extract(
        '/report/runEvents/endSuiteEvent[@id="realtime_reporting.check_realtime_reporting3"]/errorStack/text()'
      ).getclobval();
    ut3.ut_utils.append_to_list(l_expected_list, '<![CDATA[ORA-01403: no data found');
    ut3.ut_utils.append_to_list(l_expected_list, 'ORA-06512: at "%.CHECK_REALTIME_REPORTING3", line 21');
    ut3.ut_utils.append_to_list(l_expected_list, '%ORA-06512: at line 6]]>');
    l_expected := ut3.ut_utils.table_to_clob(l_expected_list);
    ut.expect(l_actual).to_be_like(l_expected);
  end error_stack_of_testsuite;

  procedure get_description is
    l_reporter ut3.ut_realtime_reporter;
    l_actual varchar2(4000);
    l_expected varchar2(80) := '%SQL Developer%';
  begin
    l_reporter := ut3.ut_realtime_reporter();
    l_actual := l_reporter.get_description();
    ut.expect(l_actual).to_be_like(l_expected);
  end get_description;

  procedure remove_test_suites is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package check_realtime_reporting1';
    execute immediate 'drop package check_realtime_reporting2';
    execute immediate 'drop package check_realtime_reporting3';
  end remove_test_suites;

end test_realtime_reporter;
/
