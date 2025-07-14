create or replace package body test_tap_reporter as

  procedure simple_succeeding_test as
    l_output_data       ut3_develop.ut_varchar2_list;
    l_expected          varchar2(32767);
  begin
    l_expected := 'TAP version 14\s*1..1\s*# Subtest: org\s{5}1..1\s{5}# Subtest: utplsql\s{9}1..1\s{9}# Subtest: tests\s{13}1..1\s{13}# Subtest: helpers\s{17}1..1\s{17}# Subtest: A suite for testing different outcomes from reporters\s*1..1\s*# <!beforeall!>\s*# Subtest: A description of some context\s*1..1\s*ok - passing_test\s*# <!afterall!>\s*ok - org\s*';

    select *
        bulk collect into l_output_data
    from table(ut3_develop.ut.run('test_reporters.passing_test',ut3_develop.ut_tap_reporter()));

    ut.expect(ut3_tester_helper.main_helper.table_to_clob(l_output_data)).to_match(l_expected);
  end simple_succeeding_test;

end test_tap_reporter;
/