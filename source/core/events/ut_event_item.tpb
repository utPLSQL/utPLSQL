create or replace type body ut_event_item is
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

  member function to_clob return clob is
    l_clob clob;
  begin
      select xmlserialize( content deletexml(xmltype(self),'/*/ITEMS') as clob indent size = 2 ) into l_clob from dual;
    return l_clob;
  end;
end;
/
