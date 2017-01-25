create or replace type body ut_coverage_html_reporter is

  constructor function ut_coverage_html_reporter(self in out nocopy ut_coverage_html_reporter, a_output ut_output default ut_output_dbms_output()) return self as result is
  begin
    self.name               := $$plsql_unit;
    self.output             := a_output;
    return;
  end;

  overriding member procedure before_calling_run(self in out nocopy ut_coverage_html_reporter, a_run ut_run) as
  begin
    (self as ut_reporter_base).before_calling_run(a_run);
    coverage_id := ut_coverage.coverage_start();
  end;

  overriding member procedure after_calling_run(self in out nocopy ut_coverage_html_reporter, a_run in ut_run) as
    l_report_lines ut_varchar2_list;
  begin
    ut_coverage.coverage_stop();
    ut_coverage_report_html_helper.init(ut_coverage.get_coverage_data(1));
    l_report_lines := ut_utils.clob_to_table(ut_coverage_report_html_helper.get_index());

    for i in 1 .. l_report_lines.count loop
      self.print_text( l_report_lines(i) );
    end loop;

    (self as ut_reporter_base).after_calling_run(a_run);
  end;

end;
/
