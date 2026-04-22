/*
  utPLSQL - Version 3
  Copyright 2016 - 2026 utPLSQL Project

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

define expected_grants = "&1"
declare
  c_expected_grants constant dbmsoutput_linesarray := dbmsoutput_linesarray( &expected_grants );

  l_expected_grants dbmsoutput_linesarray := c_expected_grants;
  l_missing_grants varchar2(4000);
begin
  if user != SYS_CONTEXT('userenv','current_schema') then
    for i in 1 .. l_expected_grants.count loop
      if l_expected_grants(i) != 'ADMINISTER DATABASE TRIGGER' then
        l_expected_grants(i) := replace(l_expected_grants(i),' ',' ANY ');
      end if;
    end loop;
  end if;

  with
    x as (
         select '' as remove from dual
         union all
         select ' ANY' as remove  from dual
    )
  select listagg(' -  '||privilege,CHR(10)) within group(order by privilege)
    into l_missing_grants
    from (
      select column_value as privilege
        from table(l_expected_grants)
      minus (
      select replace(p.privilege, x.remove) as privilege
        from role_sys_privs p
        join session_roles r using (role)
        cross join  x
      union all
      select replace(p.privilege, x.remove) as privilege
        from user_sys_privs p
        cross join  x
       )
    );
  if l_missing_grants is not null then
    raise_application_error(
        -20000
        , 'The following privileges are required for user "'||user||'" to install into schema "'||SYS_CONTEXT('userenv','current_schema')||'"'||CHR(10)
          ||l_missing_grants
          ||'Please read the installation documentation at http://utplsql.org/utPLSQL/'
    );
  end if;
end;
/
