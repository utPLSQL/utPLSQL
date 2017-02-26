create global temporary table plsql_profiler_runs$(
  /*
  utPLSQL - Version X.X.X.X
  Copyright 2016 - 2017 utPLSQL Project
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
  runid           number primary key,  -- unique run identifier,
                                       -- from plsql_profiler_runnumber
  related_run     number,              -- runid of related run (for client/
                                       --     server correlation)
  run_owner       varchar2(4000),        -- user who started run
  run_date        date,                -- start time of run
  run_comment     varchar2(2047),      -- user provided comment for this run
  run_total_time  number,              -- elapsed time for this run
  run_system_info varchar2(2047),      -- currently unused
  run_comment1    varchar2(2047),      -- additional comment
  spare1          varchar2(256)        -- unused
) on commit preserve rows;

comment on table plsql_profiler_runs$ is
        'Run-specific information for the PL/SQL profiler';

declare
  ex_nonedition_user exception;
  ex_view_doesnt_exist exception;
  pragma exception_init(ex_nonedition_user,-42314);
  pragma exception_init(ex_view_doesnt_exist,-942);
  v_view_source varchar2(32767);
begin
  begin
    execute immediate 'drop view plsql_profiler_runs';
  exception
    when ex_view_doesnt_exist then
      null;
  end;
  v_view_source := ' plsql_profiler_runs as
/*
utPLSQL - Version X.X.X.X
Copyright 2016 - 2017 utPLSQL Project
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
select runid
      ,related_run
      ,run_owner
      ,run_date
      ,run_comment
      ,run_total_time
      ,run_system_info
      ,run_comment1
      ,spare1
  from plsql_profiler_runs$';

  execute immediate 'create or replace editioning view '||v_view_source;
exception
  when ex_nonedition_user then
    execute immediate 'create or replace view '||v_view_source;
end;
/


create global temporary table plsql_profiler_units$(
  /*
  utPLSQL - Version X.X.X.X
  Copyright 2016 - 2017 utPLSQL Project
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
  runid              number,
  unit_number        number,           -- internally generated library unit #
  unit_type          varchar2(4000),   -- library unit type
  unit_owner         varchar2(4000),   -- library unit owner name
  unit_name          varchar2(4000),   -- library unit name
  -- timestamp on library unit, can be used to detect changes to
  -- unit between runs
  unit_timestamp     date,
  total_time         number DEFAULT 0 NOT NULL,
  spare1             number,           -- unused
  spare2             number,           -- unused
  --
  primary key (runid, unit_number)
) on commit preserve rows;

comment on table plsql_profiler_units$ is
        'Information about each library unit in a run';

declare
  ex_nonedition_user exception;
  ex_view_doesnt_exist exception;
  pragma exception_init(ex_nonedition_user,-42314);
  pragma exception_init(ex_view_doesnt_exist,-942);
  v_view_source varchar2(32767);
begin
  begin
    execute immediate 'drop view plsql_profiler_units';
  exception
    when ex_view_doesnt_exist then
      null;
  end;
  v_view_source := ' plsql_profiler_units as
/*
utPLSQL - Version X.X.X.X
Copyright 2016 - 2017 utPLSQL Project
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
select runid
      ,unit_number
      ,unit_type
      ,unit_owner
      ,unit_name
      ,unit_timestamp
      ,total_time
      ,spare1
      ,spare2
  from plsql_profiler_units$';

  execute immediate 'create or replace editioning view '||v_view_source;
exception
  when ex_nonedition_user then
    execute immediate 'create or replace view '||v_view_source;
end;
/

create global temporary table plsql_profiler_data$(
  /*
  utPLSQL - Version X.X.X.X
  Copyright 2016 - 2017 utPLSQL Project
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
  runid           number,           -- unique (generated) run identifier
  unit_number     number,           -- internally generated library unit #
  line#           number not null,  -- line number in unit
  total_occur     number,           -- number of times line was executed
  total_time      number,           -- total time spent executing line
  min_time        number,           -- minimum execution time for this line
  max_time        number,           -- maximum execution time for this line
  spare1          number,           -- unused
  spare2          number,           -- unused
  spare3          number,           -- unused
  spare4          number,           -- unused
  --
  primary key (runid, unit_number, line#)
) on commit preserve rows;

comment on table plsql_profiler_data$ is
        'Accumulated data from all profiler runs';

create sequence plsql_profiler_runnumber start with 1 nocache;

declare
  ex_nonedition_user exception;
  ex_view_doesnt_exist exception;
  pragma exception_init(ex_nonedition_user,-42314);
  pragma exception_init(ex_view_doesnt_exist,-942);
  v_view_source varchar2(32767);
begin
  begin
    execute immediate 'drop view plsql_profiler_data';
  exception
    when ex_view_doesnt_exist then
      null;
  end;
  v_view_source := ' plsql_profiler_data as
/*
utPLSQL - Version X.X.X.X
Copyright 2016 - 2017 utPLSQL Project
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
select runid
      ,unit_number
      ,line#
      ,total_occur
      ,total_time
      ,min_time
      ,max_time
      ,spare1
      ,spare2
      ,spare3
      ,spare4
  from plsql_profiler_data$';

  execute immediate 'create or replace editioning view '||v_view_source;
exception
  when ex_nonedition_user then
    execute immediate 'create or replace view '||v_view_source;
end;
/
