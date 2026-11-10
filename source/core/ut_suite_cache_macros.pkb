create or replace noneditionable package body ut_suite_cache_macros as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2026 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  function match_paths(a_items dbms_tf.table_t, a_paths dbms_tf.table_t) return varchar2 sql_macro is
  begin
    --names: "_" is not a wildcard, "*" is; suitepath patterns: "." and "$" are literal, "*" matches part of a path element
    return q'[
      select p.path_id, i.object_owner, i.path
        from a_items i
        join a_paths p
          on i.object_owner = upper(p.schema_name)
       where ( p.suite_path is null and p.object_name is null )
          or ( p.suite_path is null
               and i.object_name like replace(replace(upper(p.object_name), '_', '\_'), '*', '%') escape '\'
               and ( p.procedure_name is null or p.procedure_name = '*'
                     or i.name like replace(replace(upper(p.procedure_name), '_', '\_'), '*', '%') escape '\'
                   )
             )
          or ( instr(p.suite_path, '*') = 0
               and ( i.path = p.suite_path or substr(i.path, 1, length(p.suite_path) + 1) = p.suite_path || '.' )
             )
          or ( instr(p.suite_path, '*') > 0
               and regexp_like(
                     i.path,
                     '^' || replace(replace(replace(p.suite_path, '.', '\.'), '$', '\$'), '*', '[[:alnum:]$#_]*')
                   )
             )]';
  end;

end;
/
