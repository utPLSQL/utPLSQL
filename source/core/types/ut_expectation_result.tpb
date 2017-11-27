create or replace type body ut_expectation_result is
  /*
  utPLSQL - Version 3
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

  constructor function ut_expectation_result(self in out nocopy ut_expectation_result, a_status integer, a_description varchar2, a_message clob)
    return self as result is
  begin
    self.status          := a_status;
    self.description     := a_description;
    self.message := a_message;
    if self.status = ut_utils.tr_failure then
      self.caller_info   := ut_expectation_processor.who_called_expectation(dbms_utility.format_call_stack());
    end if;
    return;
  end;

  member function get_result_clob(self in ut_expectation_result) return clob is
    l_result clob;
  begin
    if self.description is not null then
      ut_utils.append_to_clob(l_result, '"'||self.description||'"');
      if self.message is not null then
        ut_utils.append_to_clob(l_result, chr(10));
      end if;
    end if;
    ut_utils.append_to_clob(l_result, self.message);
    return l_result;
  end;

  member function get_result_lines(self in ut_expectation_result) return ut_varchar2_list is
  begin
    return ut_utils.clob_to_table(get_result_clob(), 4000 );
  end;

  member function result return integer is
  begin
    return self.status;
  end;

end;
/
