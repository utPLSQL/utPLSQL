create or replace package body test_sonar_test_reporter as

  procedure report_produces_expected_out is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
    l_expected  varchar2(32767):=q'[<?xml version="1.0"?>
<testExecutions version="1">
<file path="tests/helpers/test_reporters.pkb">
<testCase name="passing_test" duration="%" >%</testCase>
<testCase name="failing_test" duration="%" >%<failure message="some expectations have failed">%</failure>%</testCase>
<testCase name="erroring_test" duration="%" >%<error message="encountered errors">%</error>%</testCase>
<testCase name="disabled_test" duration="0" >%<skipped message="skipped"/>%</testCase>
</file>
</testExecutions>]';

  begin
    select *
    bulk collect into l_results
    from table(
      ut3.ut.run(
          'test_reporters',
          ut3.ut_sonar_test_reporter(),
          a_test_file_mappings => ut3.ut_file_mapper.build_file_mappings( sys_context('USERENV', 'CURRENT_USER'), ut3.ut_varchar2_list('tests/helpers/test_reporters.pkb'))
      )
    );
    l_actual :=ut3_tester_helper.main_helper.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);  
  end;
  
  procedure check_encoding_included is
  begin
    reporters.check_xml_encoding_included(ut3.ut_sonar_test_reporter(), 'UTF-8');
  end;

  procedure check_failure_escaped is
  begin
    reporters.check_xml_failure_escaped(ut3.ut_sonar_test_reporter());
  end;

end;
/
