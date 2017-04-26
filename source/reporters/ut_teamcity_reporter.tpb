create or replace type body ut_teamcity_reporter is
  /*
  utPLSQL - Version X.X.X.X
  Copyright 2016 - 2017 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  constructor function ut_teamcity_reporter(self in out nocopy ut_teamcity_reporter) return self as result is
  begin
    self.init($$plsql_unit);
    return;
  end;

  overriding member procedure before_calling_suite(self in out nocopy ut_teamcity_reporter, a_suite in ut_logical_suite) is
  begin
    self.print_text(ut_teamcity_reporter_helper.test_suite_started(a_suite_name => nvl(replace(trim(a_suite.description)
                                                                                              ,'.')
                                                                                      ,a_suite.name)));
  end;

  overriding member procedure after_calling_suite(self in out nocopy ut_teamcity_reporter, a_suite in ut_logical_suite) is
  begin
    self.print_text(ut_teamcity_reporter_helper.test_suite_finished(a_suite_name => nvl(replace(trim(a_suite.description)
                                                                                               ,'.')
                                                                                       ,a_suite.name)));
  end;

  overriding member procedure before_calling_test(self in out nocopy ut_teamcity_reporter, a_test in ut_test) is
    l_test_full_name varchar2(4000);
  begin

    l_test_full_name := lower(a_test.item.owner_name) || '.' || lower(a_test.item.object_name) || '.' ||
                        lower(a_test.item.procedure_name);

    self.print_text(ut_teamcity_reporter_helper.test_started(a_test_name               => l_test_full_name
                                                            ,a_capture_standard_output => true));

  end;

  overriding member procedure after_calling_test(self in out nocopy ut_teamcity_reporter, a_test in ut_test) is
    l_expectation    ut_expectation_result;
    l_test_full_name varchar2(4000);
    l_std_err_msg    varchar2(32767);
  begin
    --    l_test_full_name := self.suite_names_stack(self.suite_names_stack.last) || ':' ||
    --                        nvl(replace(a_test.description, '.'), a_test.name);
    l_test_full_name := lower(a_test.item.owner_name) || '.' || lower(a_test.item.object_name) || '.' ||
                        lower(a_test.item.procedure_name);

    if a_test.result = ut_utils.tr_disabled then
      self.print_text(ut_teamcity_reporter_helper.test_disabled(l_test_full_name));
    else

      self.print_clob(a_test.get_serveroutputs());

      if a_test.result = ut_utils.tr_error then
        if a_test.before_each.error_backtrace is not null then
          l_std_err_msg := l_std_err_msg || 'Before each exception:' || chr(10) || a_test.before_each.error_backtrace || chr(10);
        end if;

        if a_test.before_test.error_backtrace is not null then
          l_std_err_msg := l_std_err_msg || 'Before test exception:' || chr(10) || a_test.before_test.error_backtrace || chr(10);
        end if;

        if a_test.item.error_backtrace is not null then
          l_std_err_msg := l_std_err_msg || 'Test exception:' || chr(10) || a_test.item.error_backtrace || chr(10);
        end if;

        if a_test.after_test.error_backtrace is not null then
          l_std_err_msg := l_std_err_msg || 'After test exception:' || chr(10) || a_test.after_test.error_backtrace || chr(10);
        end if;

        if a_test.after_each.error_backtrace is not null then
          l_std_err_msg := l_std_err_msg || 'After each exception:' || chr(10) || a_test.after_each.error_backtrace || chr(10);
        end if;

        self.print_text(ut_teamcity_reporter_helper.test_std_err(a_test_name => l_test_full_name
                                                                ,a_out       => trim(l_std_err_msg)));
        self.print_text(ut_teamcity_reporter_helper.test_failed(a_test_name => l_test_full_name
                                                               ,a_msg       => 'Error occured'
                                                               ,a_details   => trim(l_std_err_msg) || case when a_test.results is not null and a_test.results.count>0 then a_test.results(1)
                                                                              .message end));
      elsif a_test.results is not null and a_test.results.count > 0 then
        for i in 1 .. a_test.results.count loop

          l_expectation := a_test.results(i);

          if l_expectation.result > ut_utils.tr_success then
            self.print_text(ut_teamcity_reporter_helper.test_failed(a_test_name => l_test_full_name
                                                                   ,a_msg       => l_expectation.message
                                                                   ,a_expected  => case
                                                                                     when l_expectation.matcher_name in
                                                                                          ('equal', 'be false', 'be true') then
                                                                                      l_expectation.expected_value_string
                                                                                   end
                                                                   ,a_actual    => case
                                                                                     when l_expectation.matcher_name in
                                                                                          ('equal', 'be false', 'be true') then
                                                                                      l_expectation.actual_value_string
                                                                                   end));
            -- Teamcity supports only a single failure message
            exit;
          end if;

        end loop;
      elsif a_test.result = ut_utils.tr_failure then
        self.print_text(ut_teamcity_reporter_helper.test_failed(a_test_name => l_test_full_name
                                                               ,a_msg       => 'Test failed'));
      end if;

      self.print_text(ut_teamcity_reporter_helper.test_finished(l_test_full_name, trunc(a_test.execution_time * 1e3)));

    end if;

  end;

end;
/
