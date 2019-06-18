create or replace type body ut_object_name as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2019 utPLSQL Project

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
  constructor function ut_object_name(self in out nocopy ut_object_name, owner varchar2, name varchar2) return self as result is
  begin
    self.owner := upper(owner);
    self.name := upper(name);
    return;
  end;

  constructor function ut_object_name(self in out nocopy ut_object_name, a_unit_name varchar2) return self as result is
  begin
    if instr(a_unit_name,'.') > 0 then
      self.owner := upper(regexp_substr(a_unit_name,'[^\.]+', 1, 1));
      self.name  := upper(regexp_substr(a_unit_name,'[^\.]+', 1, 2));
    else
      self.name  := upper(a_unit_name);
    end if;
    return;
  end;


  map member function identity return varchar2 is
  begin
    return owner||'.'||name;
  end;
end;
/
