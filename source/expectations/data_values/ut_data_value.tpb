create or replace type body ut_data_value as
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
  order member function compare(a_other ut_data_value) return integer is
  begin
    return compare_implementation(a_other);
  end;

  member function is_diffable return boolean is
  begin
    return false;
  end;

  member function diff( a_other ut_data_value ) return varchar2 is
  begin
    return null;
  end;

  member function is_multi_line return boolean is
  begin
    return false;
  end;

  final member function format_multi_line( a_string varchar2) return varchar2 is
  begin
    if is_multi_line() then
      return chr(10)||rtrim(a_string,chr(10))||chr(10);
    else
      return a_string;
    end if;
  end;

  final member function to_string_report(a_add_new_line_for_multi_line boolean := false, a_with_type_name boolean := true) return varchar2 is
    l_result varchar2(32767);
  begin
    l_result := ut_utils.indent_lines( self.to_string() );
    if a_with_type_name then
      l_result := l_result ||' ('||self.data_type||') ';
    end if;
    if self.is_multi_line and a_add_new_line_for_multi_line then
      l_result := l_result || chr(10);
    end if;
    return l_result;
  end;
end;
/
