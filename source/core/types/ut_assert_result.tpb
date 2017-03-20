create or replace type body ut_assert_result is
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

  constructor function ut_assert_result(self in out nocopy ut_assert_result, a_result integer, a_error_message varchar2)
    return self as result is
  begin
    self.result        := a_result;
    self.error_message := a_error_message;
    self.caller_info   := ut_assert_processor.who_called_expectation();
    return;
  end;

  constructor function ut_assert_result(self in out nocopy ut_assert_result, a_name varchar2, a_additional_info varchar2, a_error_message varchar2, a_result integer, a_expected_type varchar2, a_actual_type varchar2,
    a_expected_value_string varchar2, a_actual_value_string varchar2, a_message varchar2 default null)
    return self as result is
  begin
    self.matcher_name          := a_name;
    self.additional_info       := a_additional_info;
    self.result                := a_result;
    self.message               := a_message;
    self.error_message         := a_error_message;
    self.expected_type         := a_expected_type;
    self.actual_type           := a_actual_type;
    self.expected_value_string := a_expected_value_string;
    self.actual_value_string   := a_actual_value_string;
    if a_result = ut_utils.tr_failure then
      self.caller_info           := ut_assert_processor.who_called_expectation();
    end if;
    return;
  end;

  member function get_result_clob(self in ut_assert_result) return clob is
    l_result clob;
    l_actual_val_msg  varchar2(1000);
    l_actual_val      varchar2(32767);
    l_expected_msg    varchar2(1000);
    l_expected_val    varchar2(32767);

    procedure add_text_line(a_clob in out nocopy clob, a_prefix varchar2, a_text varchar2 := null) is
      l_text varchar2(32767);
    begin
      if a_text is not null then
        l_text := a_prefix || ut_utils.indent_lines( a_text, length(a_prefix) );
      else
        l_text := a_prefix;
      end if;
      if a_clob is not null and l_text is not null then
        l_text := chr(10) || l_text;
      end if;
      ut_utils.append_to_clob(a_clob, l_text);
    end;
  begin
    if self.result != ut_utils.tr_success or self.error_message is not null then
      if self.message is not null then
        add_text_line(l_result, '  expectation description: ', self.message);
      end if;

      if self.result != ut_utils.tr_success then
        if self.actual_value_string is not null or self.actual_type is not null then
          l_actual_val_msg := '  expected this: ';
          l_actual_val := self.actual_value_string || '(' || self.actual_type || ')';
        end if;

        l_expected_msg := '  ' || self.matcher_name || self.additional_info;
        if self.expected_value_string is not null or self.expected_type is not null then
          l_expected_msg := l_expected_msg || ': ';
          l_expected_val := self.expected_value_string||'('||self.expected_type||')';
          if length(l_expected_msg) > length(l_actual_val_msg) then
            l_actual_val_msg := rpad(l_actual_val_msg , length(l_expected_msg));
          else
            l_expected_msg := rpad(l_expected_msg , length(l_actual_val_msg));
          end if;
        end if;
        add_text_line(l_result, l_actual_val_msg, l_actual_val);
        add_text_line(l_result, l_expected_msg, l_expected_val);
      end if;

    end if;
    if self.error_message is not null then
      add_text_line(l_result, '  error: '||ut_utils.indent_lines( self.error_message, length('  error: ') ) );
    end if;

    return l_result;
  end;

  member function get_result_lines(self in ut_assert_result) return ut_varchar2_list is
  begin
    return ut_utils.clob_to_table(get_result_clob(), 4000 );
  end;
end;
/
