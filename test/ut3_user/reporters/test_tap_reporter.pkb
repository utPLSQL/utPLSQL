create or replace package body test_tap_reporter as

  gc_boilerplate_suitepath_expression constant varchar2(300) := 'TAP version 14\s*1..1\s*# Subtest: org\s{5}1..1\s{5}# Subtest: utplsql\s{9}1..1\s{9}# Subtest: tests\s{13}1..1\s{13}# Subtest: helpers\s{17}1..1\s{17}# Subtest: A suite for testing different outcomes from reporters';

  procedure simple_succeeding_test as
    l_output_data       ut3_develop.ut_varchar2_list;
    l_expected          varchar2(32767);
  begin
    l_expected := gc_boilerplate_suitepath_expression || '\s{21}1..1\s{21}# <!beforeall!>\s{21}# Subtest: A description of some context\s{25}1..1\s{25}ok - passing_test\s{21}# <!afterall!>\sok - org\s*';

    select *
        bulk collect into l_output_data
    from table(ut3_develop.ut.run('test_reporters.passing_test',ut3_develop.ut_tap_reporter()));

    ut.expect(ut3_tester_helper.main_helper.table_to_clob(l_output_data)).to_match(l_expected);
  end simple_succeeding_test;

  procedure simple_failing_test as
    l_output_data       ut3_develop.ut_varchar2_list;
    l_expected          varchar2(32767);
  begin
    l_expected := gc_boilerplate_suitepath_expression || q'[\s{21}1..1\s{21}# <!beforeall!>\s{21}not ok - a test with failing assertion\s{23}---\s{23}message: '"Fails as values are different"'\s{23}severity: fail\s{23}...\s{21}# <!afterall!>\snot ok - org\s*]';

    select *
        bulk collect into l_output_data
    from table(ut3_develop.ut.run('test_reporters.failing_test',ut3_develop.ut_tap_reporter()));

    ut.expect(ut3_tester_helper.main_helper.table_to_clob(l_output_data)).to_match(l_expected);
  end simple_failing_test;


  procedure simple_erroring_test as
    l_output_data       ut3_develop.ut_varchar2_list;
    l_expected          varchar2(32767);
  begin
    l_expected := gc_boilerplate_suitepath_expression || q'[\s{21}1..1\s{21}# <!beforeall!>\s{21}not ok - a test raising unhandled exception\s{23}---\s{23}message: |\s{25ORA-06502: .*\s{25}ORA-06512: .*\s{25}ORA-06512: .*\s{25}ORA-06512: at line [[:digit:]]+\s{23}severity: error\s{23}...\s{21}# <!afterall!>\snot ok - org\s*]';

    select *
        bulk collect into l_output_data
    from table(ut3_develop.ut.run('test_reporters.erroring_test',ut3_develop.ut_tap_reporter()));

    ut.expect(ut3_tester_helper.main_helper.table_to_clob(l_output_data)).to_match(l_expected);
  end simple_erroring_test;


  procedure disabled_test as
    l_output_data       ut3_develop.ut_varchar2_list;
    l_expected          varchar2(32767);
  begin
    l_expected := gc_boilerplate_suitepath_expression || q'[\s{21}1..1\s{21}# <!beforeall!>\s{21}ok - a disabled test # SKIP: Disabled for testing purpose\s{21}# <!afterall!>\sok - org\s*]';

    select *
        bulk collect into l_output_data
    from table(ut3_develop.ut.run('test_reporters.disabled_test',ut3_develop.ut_tap_reporter()));

    ut.expect(ut3_tester_helper.main_helper.table_to_clob(l_output_data)).to_match(l_expected);
  end disabled_test;


  procedure disabled_test_no_description as
    l_output_data       ut3_develop.ut_varchar2_list;
    l_expected          varchar2(32767);
  begin
    l_expected := gc_boilerplate_suitepath_expression || q'[\s{21}1..1\s{21}# <!beforeall!>\s{21}ok - a disabled test with no reason # SKIP\s{21}# <!afterall!>\sok - org\s*]';

    select *
        bulk collect into l_output_data
    from table(ut3_develop.ut.run('test_reporters.disabled_test_no_reason',ut3_develop.ut_tap_reporter()));

    ut.expect(ut3_tester_helper.main_helper.table_to_clob(l_output_data)).to_match(l_expected);
  end disabled_test_no_description;

end test_tap_reporter;
/