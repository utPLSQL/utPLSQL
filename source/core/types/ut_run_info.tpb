create or replace type body ut_run_info as
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
  See the License for the specific language governing permissions andTEST_GET_REPORTERS_LIST
  limitations under the License.
  */
  constructor function ut_run_info(self in out nocopy ut_run_info) return self as result is
    l_ut_owner varchar2(250) := ut_utils.ut_owner;
  begin
    self.self_type := $$plsql_unit;
    execute immediate
      'select /*+ no_parallel */ '||l_ut_owner||'.ut.version() from dual'
        into self.ut_version;

    dbms_utility.db_version( self.db_version, self.db_compatibility );
    db_os_type := dbms_utility.port_string();

    execute immediate
      'select /*+ no_parallel */ '||l_ut_owner||'.ut_key_value_pair(x.product, x.version) from product_component_version x'
        bulk collect into self.db_component_version;

    execute immediate
      'select /*+ no_parallel */ '||l_ut_owner||'.ut_key_value_pair(x.parameter, x.value)
      from nls_session_parameters x'
        bulk collect into self.nls_session_params;

    execute immediate
      'select /*+ no_parallel */ '||l_ut_owner||'.ut_key_value_pair(x.parameter, x.value) from nls_instance_parameters x'
        bulk collect into self.nls_instance_params;

    execute immediate
      'select /*+ no_parallel */ '||l_ut_owner||'.ut_key_value_pair(x.parameter, x.value) from nls_database_parameters x'
        bulk collect into self.nls_db_params;
    return;
  end;
end;
/
