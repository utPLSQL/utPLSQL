create or replace package body test_coverage_standalone is

  function run_coverage_twice(a_overage_run_id raw, a_object_name varchar2) return clob is
    l_expected        clob;
    l_block_cov       clob;
    l_file_path       varchar2(250);
  begin
    l_file_path := 'ut3_develop.'||a_object_name;
    --Arrange
    if ut3_tester_helper.coverage_helper.block_coverage_available then
      l_block_cov := '<line number="4" hits="5" branch="true" condition-coverage="67% (2/3)"/>';
    else
      l_block_cov := '<line number="4" hits="5" branch="false"/>';
    end if;
    l_expected :=
      q'[<?xml version="1.0"?>
<!DOCTYPE coverage SYSTEM "http://cobertura.sourceforge.net/xml/coverage-04.dtd">
<coverage line-rate="0" branch-rate="0.0" lines-covered="2" lines-valid="2" branches-covered="0" branches-valid="0" complexity="0" version="1" timestamp="%">
<sources>
<source>]'||l_file_path||q'[</source>
</sources>
<packages>
<package name="]'||upper(a_object_name)||q'[" line-rate="0.0" branch-rate="0.0" complexity="0.0">
<class name="]'||upper(a_object_name)||q'[" filename="]'||l_file_path||q'[" line-rate="0.0" branch-rate="0.0" complexity="0.0">
<lines>
]'||l_block_cov||q'[
<line number="6" hits="1" branch="false"/>
</lines>
</class>
</package>
</packages>
</coverage>]';
    --Act
    ut3_tester_helper.coverage_helper.run_coverage_job(a_overage_run_id, 1);
    ut3_tester_helper.coverage_helper.run_coverage_job(a_overage_run_id, 3);
    return l_expected;
  end;

  procedure coverage_without_ut_run is
    l_coverage_run_id raw(32) := sys_guid();
    l_actual          ut3_develop.ut_varchar2_list;
    l_expected        clob;
    l_name            varchar2(250);
  begin
    l_name := ut3_tester_helper.coverage_helper.covered_package_name;

    --Arrange and Act
    l_expected := run_coverage_twice(l_coverage_run_id, l_name);

    select *
      bulk collect into l_actual
      from
        table (
          ut3_develop.ut_coverage_cobertura_reporter( ).get_report(
            ut3_develop.ut_coverage_options(
              coverage_run_id => l_coverage_run_id,
              include_objects => ut3_develop.ut_varchar2_rows(l_name),
              schema_names => ut3_develop.ut_varchar2_rows('UT3_DEVELOP')
              )
            )
          );

    --Assert
    ut.expect(ut3_tester_helper.main_helper.table_to_clob(l_actual)).to_be_like( l_expected );
  end;

  procedure coverage_cursor_without_ut_run is
    l_coverage_run_id raw(32) := sys_guid();
    l_coverage_cursor sys_refcursor;
    l_actual          ut3_develop.ut_varchar2_list;
    l_expected        clob;
    l_name            varchar2(250);
  begin
    l_name := ut3_tester_helper.coverage_helper.covered_package_name;

    --Arrange and Act
    l_expected := run_coverage_twice(l_coverage_run_id, l_name);

    l_coverage_cursor :=
      ut3_develop.ut_coverage_cobertura_reporter( ).get_report_cursor(
        ut3_develop.ut_coverage_options(
          coverage_run_id => l_coverage_run_id,
          include_objects => ut3_develop.ut_varchar2_rows(l_name),
          schema_names => ut3_develop.ut_varchar2_rows('UT3_DEVELOP')
          )
        );
    fetch l_coverage_cursor bulk collect into l_actual;
    close l_coverage_cursor;

    --Assert
    ut.expect(ut3_tester_helper.main_helper.table_to_clob(l_actual)).to_be_like( l_expected );
  end;

end;
/
