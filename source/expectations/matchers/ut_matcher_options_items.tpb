create or replace type body ut_matcher_options_items is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2018 utPLSQL Project

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

  constructor function ut_matcher_options_items(self in out nocopy ut_matcher_options_items) return self as result is
  begin
    items := ut_varchar2_list();
    return;
  end;

  member procedure add_items(self in out nocopy ut_matcher_options_items, a_items varchar2) is
  begin
    items :=
      items
        multiset union all
      ut_utils.filter_list(
        ut_utils.trim_list_elements(
          ut_utils.string_to_table( replace( a_items , '|', ',' ), ',' )
          )
        , '.+'
        );
  end;

  member procedure add_items(self in out nocopy ut_matcher_options_items, a_items ut_varchar2_list) is
    l_idx binary_integer;
  begin
    if a_items is not null then
      l_idx := a_items.first;
      while l_idx is not null loop
        add_items( a_items(l_idx) );
        l_idx := a_items.next(l_idx);
      end loop;
    end if;
  end;

  member function to_xpath return varchar2 is
  begin
    return ut_utils.to_xpath(items);
  end;

end;
/