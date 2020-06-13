create or replace package body test_html_proftab_reporter is

  procedure report_on_file is
    l_expected  varchar2(32767);
    l_actual    clob;
    l_charset   varchar2(100) := 'ISO-8859-1';
  begin
    --Arrange
    l_expected := '%<meta %charset='||l_charset||'" />%<h3>UT3_DEVELOP.DUMMY_COVERAGE</h3>%<b>3</b> relevant lines. <span class="green"><b>2</b> lines covered</span> and <span class="red"><b>1</b> lines missed%';
    --Act
    l_actual :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        q'[
            ut3_develop.ut.run(
              a_path => 'ut3_develop.test_dummy_coverage',
              a_reporter=> ut3_develop.ut_coverage_html_reporter(),
              a_source_files => ut3_develop.ut_varchar2_list( 'test/ut3_develop.dummy_coverage.pkb' ),
              a_test_files => ut3_develop.ut_varchar2_list( ),
              a_client_character_set => ']'||l_charset||q'['
            )
          ]'
        );
    --Assert
    ut.expect(l_actual).to_be_like(l_expected);
  end;

end test_html_proftab_reporter;
/
