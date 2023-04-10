create or replace type body ut_stack as
 /*
  utPLSQL - Version 3
  Copyright 2016 - 2021 utPLSQL Project

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
  
  constructor function ut_stack( self in out nocopy ut_stack) return self as result is
  begin
    self.tokens := ut_varchar2_list();
    self.top := 0;
    return;
  end ut_stack;
  
  member function peek(self in out nocopy ut_stack) return varchar2 is
    l_token varchar2(32767);
  begin
    if self.tokens.count =0 or self.tokens is null then
      l_token := null;
    else
      l_token := self.tokens(self.tokens.last);
    end if;
    return l_token;
  end;
  
  member procedure push(self in out nocopy ut_stack, a_token varchar2) is
  begin
    self.tokens.extend;
    self.tokens(self.tokens.last) := a_token;
    self.top := self.tokens.count;
  end push;
  
  member procedure pop(self in out nocopy ut_stack,a_cnt in integer default 1) is
  begin
    self.tokens.trim(a_cnt);
    self.top := self.tokens.count;
  end pop;
  
  member function pop(self in out nocopy ut_stack) return varchar2 is
    l_token varchar2(32767) := self.tokens(self.tokens.last);
  begin
    self.pop();
    return l_token;
  end;
end;  
/

