create or replace type body ut_tap_reporter is


  constructor function ut_tap_reporter(self in out nocopy ut_tap_reporter) return self as result is
  begin
    self.init($$plsql_unit);
    self.lvl := 0;
    return;
  end ut_tap_reporter;

  member procedure print_comment(self in out nocopy ut_tap_reporter, a_comment clob) as
  begin
    self.print_clob(regexp_replace(self.escape_special_chars(a_comment), '^', '# ', 1, 0, 'm'));
  end print_comment;

  member function escape_special_chars(self in out nocopy ut_tap_reporter, a_string_to_escape clob) return clob as
  begin
    return regexp_replace(a_string_to_escape, '([\\#])', '\\\1');
  end escape_special_chars;

  overriding member procedure before_calling_suite(self in out nocopy ut_tap_reporter, a_suite ut_logical_suite) as
  begin
    self.print_text('# Subtest: ' || self.escape_special_chars(coalesce(a_suite.description, a_suite.name)));
    lvl := lvl + 2;
    self.print_text('1..' || a_suite.items.count);
  end before_calling_suite;


  overriding member procedure after_calling_test(self in out nocopy ut_tap_reporter, a_test ut_test) as
    l_message varchar2(4000);
    l_test_name varchar2(4000) := self.escape_special_chars(coalesce(a_test.description, a_test.name));

    procedure print_failed_expectation(a_test ut_test) is
      l_lines  ut_varchar2_list;
      l_failed boolean;
    begin
      if a_test.get_error_stack_traces().count = 0 then
        -- If no error occurred, print failed expectation
        l_lines := a_test.all_expectations(a_test.all_expectations.last).get_result_lines();
        l_failed := a_test.all_expectations(a_test.all_expectations.last).status >= ut_utils.gc_success;
        if l_failed then
          self.print_text('message: ''' || l_lines(1) || '''');
          self.print_text('severity: fail');
        end if;
      else
        -- Print multi-line YAML-String with implicit newline characters
        self.print_text('message: |');
        self.lvl := self.lvl + 1;
        self.print_text(ut_utils.table_to_clob(a_test.get_error_stack_traces()));
        self.lvl := self.lvl - 1;
        self.print_text('severity: error');
      end if;
    end print_failed_expectation;

  begin

    if a_test.result = ut_utils.gc_disabled then
      self.print_text('ok - ' || l_test_name || ' # SKIP'|| 
        case when a_test.disabled_reason is not null
          then ': '|| self.escape_special_chars(a_test.disabled_reason)
          else null
        end );
    elsif a_test.result = ut_utils.gc_success then
      self.print_text('ok - ' || l_test_name);
    elsif a_test.result > ut_utils.gc_success then
      if self.lvl = 0 then
        self.print_text(ut_ansiconsole_helper.red('not ok') || ' - ' || l_test_name);
      else
        self.print_text('not ok - ' || l_test_name);
      end if;
      self.lvl := self.lvl + 1;
      self.print_text('---');
      print_failed_expectation(a_test);
      self.print_text('...');
      self.lvl := self.lvl - 1;
    end if;

    self.print_comment(a_test.get_serveroutputs);
    
  end after_calling_test;

  overriding member procedure after_calling_before_all(self in out nocopy ut_tap_reporter, a_executable in ut_executable) is
  begin
    if a_executable.serveroutput is not null and a_executable.serveroutput != empty_clob() then
      self.print_comment(a_executable.serveroutput);
    end if;
  end after_calling_before_all;

  overriding member procedure after_calling_after_all(self in out nocopy ut_tap_reporter, a_executable in ut_executable) is
  begin
    if a_executable.serveroutput is not null and a_executable.serveroutput != empty_clob() then
      self.print_comment(a_executable.serveroutput);
    end if;
  end after_calling_after_all;

  overriding member procedure after_calling_suite(self in out nocopy ut_tap_reporter, a_suite ut_logical_suite) as
    l_suite_name varchar2(4000) := coalesce(a_suite.description, a_suite.name);
  begin
    lvl := lvl - 2;
    if lvl = 0 then
      if a_suite.result = ut_utils.gc_success or a_suite.result = ut_utils.gc_disabled then
        self.print_text('ok - ' || self.escape_special_chars(l_suite_name));
      elsif a_suite.result > ut_utils.gc_success then
        self.print_text(ut_ansiconsole_helper.red('not ok') || ' - ' || self.escape_special_chars(l_suite_name));
      end if;

      self.print_text(' ');
    end if;

  end after_calling_suite;

  overriding member procedure before_calling_run(self in out nocopy ut_tap_reporter, a_run in ut_run) as
  begin
    self.print_text('TAP version 14');
    self.print_text('1..' || a_run.items.count);
    self.print_text(' ');
  end before_calling_run;

  overriding member procedure after_calling_run(self in out nocopy ut_tap_reporter, a_run in ut_run) as
  begin
    self.lvl := 0;
  end;
end;
/