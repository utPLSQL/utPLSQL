create or replace type ut_key_anyvalues under ut_event_item (
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
  pairs ut_key_anyval_pairs,
  constructor function ut_key_anyvalues(self in out nocopy ut_key_anyvalues) return self as result,
  member function put(a_item ut_key_anyval_pair) return ut_key_anyvalues,
  member function put(a_key varchar2, a_value anydata) return ut_key_anyvalues,
  member function put(a_key varchar2, a_value blob) return ut_key_anyvalues,
  member function put(a_key varchar2, a_value boolean) return ut_key_anyvalues,
  member function put(a_key varchar2, a_value clob) return ut_key_anyvalues,
  member function put(a_key varchar2, a_value date) return ut_key_anyvalues,
  member function put(a_key varchar2, a_value number) return ut_key_anyvalues,
  member function put(a_key varchar2, a_value timestamp_unconstrained) return ut_key_anyvalues,
  member function put(a_key varchar2, a_value timestamp_ltz_unconstrained) return ut_key_anyvalues,
  member function put(a_key varchar2, a_value timestamp_tz_unconstrained) return ut_key_anyvalues,
  member function put(a_key varchar2, a_value varchar2) return ut_key_anyvalues,
  member function put(a_key varchar2, a_value yminterval_unconstrained) return ut_key_anyvalues,
  member function put(a_key varchar2, a_value dsinterval_unconstrained) return ut_key_anyvalues
)
/
