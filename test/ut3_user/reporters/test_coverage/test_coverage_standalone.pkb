create or replace package body test_coverage_standalone is

  procedure coverage_without_ut_run is
    l_coverage_run_id raw(32) := sys_guid();
    l_actual          ut3_develop.ut_varchar2_list;
    l_expected        clob;
  begin
    --Arrange
    l_expected := '%<source>ut3_tester_helper.coverage_pkg</source>' ||
    '%<package name="COVERAGE_PKG" ' ||
    '%<class name="COVERAGE_PKG" filename="ut3_tester_helper.coverage_pkg"' ||
    '%<lines>' ||
    '%<line number="5" hits="4" branch="true" condition-coverage="67% (2/3)"/>' ||
    '%<line number="7" hits="1" branch="false"/>%';
      --Act
    ut3_tester_helper.coverage_helper.run_coverage_job(l_coverage_run_id, 1);
    ut3_tester_helper.coverage_helper.run_coverage_job(l_coverage_run_id, 3);

    --Assert
    select *
      bulk collect into l_actual
      from
        table (
          ut3_develop.ut_coverage_cobertura_reporter( ).get_report(
            ut3_develop.ut_coverage_options(
              coverage_run_id => l_coverage_run_id,
              include_objects => ut3_develop.ut_varchar2_rows('COVERAGE_PKG'),
              schema_names => ut3_develop.ut_varchar2_rows('UT3_TESTER_HELPER')
              )
            )
          );
    ut.expect(ut3_tester_helper.main_helper.table_to_clob(l_actual)).to_be_like( l_expected );
  end;

end;
/
