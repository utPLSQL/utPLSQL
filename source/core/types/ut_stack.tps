create or replace type ut_stack as object (
  top integer,
  tokens ut_varchar2_list,
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2023 utPLSQL Project

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
  constructor function ut_stack( self in out nocopy ut_stack) return self as result,
  member function peek(self in out nocopy ut_stack) return varchar2,
  member procedure push(self in out nocopy ut_stack, a_token varchar2),
  member procedure pop(self in out nocopy ut_stack,a_cnt in integer default 1),
  member function pop(self in out nocopy ut_stack) return varchar2
)
/