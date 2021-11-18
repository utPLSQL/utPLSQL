create or replace type body ut_key_anyvalues as
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
  constructor function ut_key_anyvalues(self in out nocopy ut_key_anyvalues) return self as result is
  begin
    self.self_type := $$plsql_unit;
    self.pairs := ut_key_anyval_pairs();
    return;
  end;
  member function put(a_item ut_key_anyval_pair) return ut_key_anyvalues is
    l_result ut_key_anyvalues := self;
  begin
    l_result.pairs.extend();
    l_result.pairs(l_result.pairs.last) := a_item;
    return l_result;
  end;
  member function put(a_key varchar2, a_value anydata) return ut_key_anyvalues is
  begin
    return put(ut_key_anyval_pair(a_key, ut_data_value_anydata(a_value)));
  end;

  member function put(a_key varchar2, a_value blob) return ut_key_anyvalues is
  begin
    return put(ut_key_anyval_pair(a_key, ut_data_value_blob(a_value)));
  end;

  member function put(a_key varchar2, a_value boolean) return ut_key_anyvalues is
  begin
    return put(ut_key_anyval_pair(a_key, ut_data_value_boolean(a_value)));
  end;

  member function put(a_key varchar2, a_value clob) return ut_key_anyvalues is
  begin
    return put(ut_key_anyval_pair(a_key, ut_data_value_clob(a_value)));
  end;

  member function put(a_key varchar2, a_value date) return ut_key_anyvalues is
  begin
    return put(ut_key_anyval_pair(a_key, ut_data_value_date(a_value)));
  end;

  member function put(a_key varchar2, a_value number) return ut_key_anyvalues is
  begin
    return put(ut_key_anyval_pair(a_key, ut_data_value_number(a_value)));
  end;
  member function put(a_key varchar2, a_value timestamp_unconstrained) return ut_key_anyvalues is
  begin
    return put(ut_key_anyval_pair(a_key, ut_data_value_timestamp(a_value)));
  end;

  member function put(a_key varchar2, a_value timestamp_ltz_unconstrained) return ut_key_anyvalues is
  begin
    return put(ut_key_anyval_pair(a_key, ut_data_value_timestamp_ltz(a_value)));
  end;

  member function put(a_key varchar2, a_value timestamp_tz_unconstrained) return ut_key_anyvalues is
  begin
    return put(ut_key_anyval_pair(a_key, ut_data_value_timestamp_tz(a_value)));
  end;

  member function put(a_key varchar2, a_value varchar2) return ut_key_anyvalues is
  begin
    return put(ut_key_anyval_pair(a_key, ut_data_value_varchar2(a_value)));
  end;

  member function put(a_key varchar2, a_value yminterval_unconstrained) return ut_key_anyvalues is
  begin
    return put(ut_key_anyval_pair(a_key, ut_data_value_yminterval(a_value)));
  end;

  member function put(a_key varchar2, a_value dsinterval_unconstrained) return ut_key_anyvalues is
  begin
    return put(ut_key_anyval_pair(a_key, ut_data_value_dsinterval(a_value)));
  end;
end;
/
