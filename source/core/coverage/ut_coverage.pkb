create or replace package body ut_coverage is
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

  -- The source query has two important transformations done in it.
  -- the flag: to_be_skipped ='Y' is set for a line of code that is badly reported by DBMS_PROFILER as executed 0 times.
  -- This includes lines that are:
  --   - PACKAGE, PROCEDURE, FUNCTION definition line,
  --   - BEGIN, END  of a block
  -- Another transformation is adjustment of line number for TRIGGER body.
  -- DBMS_PROFILER is reporting line numbers for triggers not as defined in DBA_SOURCE, its usign line numbers as defined in DBA_TRIGGERS
  -- the DBA_TRIGGERS does not contain the trigger specification lines, only lines that define the trigger body.
  -- the query adjusts the line numbers for triggers by finding first occurrence of begin|declare|compound in the trigger body line.
  -- The subquery is optimized by:
  -- - COALESCE function -> it will execute only for TRIGGERS
  -- - scalar subquery cache -> it will only execute once for one trigger source code.
  function populate_sources_tmp_table(a_coverage_options ut_coverage_options) return varchar2 is
    l_result varchar2(32767);
    l_full_name varchar2(100);
  begin
    if a_coverage_options.file_mappings is not null then
      l_full_name := 'f.file_name';
    else
      l_full_name := 'lower(s.owner||''.''||s.name)';
    end if;
    l_result := '
      insert /*+ append */ into ut_coverage_sources_tmp(full_name,owner,name,line,text, to_be_skipped)
      select *
        from (
          select '||l_full_name||q'[,
                 s.owner,
                 s.name,
                 s.line -
                 coalesce(
                   case when type!='TRIGGER' then 0 end,
                   (select min(t.line) - 1
                      from all_source t
                     where t.owner = s.owner and t.type = s.type and t.name = s.name
                       and regexp_like( t.text, '\w*(begin|declare|compound).*','i'))
                 ) as line,
                 s.text,
                 case
                   when
                     -- to avoid execution of regexp_like on every line
                     -- first do a rough check for existence of search pattern keyword
                     (lower(s.text) like '%procedure%'
                      or lower(s.text) like '%function%'
                      or lower(s.text) like '%begin%'
                      or lower(s.text) like '%end%'
                      or lower(s.text) like '%package%'
                     ) and
                     regexp_like(
                        s.text,
                        '^\s*(((not)?\s*(overriding|final|instantiable)\s*)*(static|constructor|member)?\s*(procedure|function)|package(\s+body)|begin|end(\s+\S+)?\s*;)', 'i'
                     )
                    then 'Y'
                 end as to_be_skipped
            from all_source s]';
    if a_coverage_options.file_mappings is not null then
      l_result := l_result || '
            join table(:file_mappings) f
              on s.name  = f.object_name
             and s.type  = f.object_type
             and s.owner = f.object_owner
           where 1 = 1';
    else
      l_result := l_result || '
           where s.owner in (select upper(t.column_value) from table(:l_schema_names) t)';
    end if;
    l_result := l_result || q'[
             and s.type not in ('PACKAGE', 'TYPE', 'JAVA SOURCE')
             --Exclude calls to utPLSQL framework, Unit Test packages and objects from a_exclude_list parameter of coverage reporter
             and (s.owner, s.name) not in (select el.owner, el.name from table(:l_skipped_objects) el)]';
    if a_coverage_options.include_objects is null then
      l_result := l_result || '
             and :include_objects is null';
    else
      l_result := l_result || '
             and (s.owner, s.name) in (select il.owner, il.name from table(:include_objects) il)';
    end if;
      l_result := l_result || '
             )
       where line > 0';
    return l_result;
  end;

  /**
  * Public functions
  */
  procedure coverage_start is
  begin
    ut_coverage_helper.coverage_start('utPLSQL Code coverage run '||ut_utils.to_string(systimestamp));
  end;

  procedure coverage_start_develop is
  begin
    ut_coverage_helper.coverage_start_develop();
  end;

  procedure coverage_pause is
  begin
    ut_coverage_helper.coverage_pause();
  end;

  procedure coverage_resume is
  begin
    ut_coverage_helper.coverage_resume();
  end;

  procedure coverage_stop is
  begin
    ut_coverage_helper.coverage_stop();
  end;

  procedure coverage_stop_develop is
  begin
    ut_coverage_helper.coverage_stop_develop();
  end;

  function get_coverage_data(a_coverage_options ut_coverage_options) return t_coverage is

    pragma autonomous_transaction;

    type t_coverage_row is record(
      name          varchar2(500),
      line_number   integer,
      total_occur   number(38,0)
    );
    type tt_coverage_rows is table of t_coverage_row;
    l_line_calls       ut_coverage_helper.unit_line_calls;
    l_result           t_coverage;
    l_new_unit         t_unit_coverage;
    l_skipped_objects  ut_object_names := ut_object_names();

    type t_source_lines is table of binary_integer;
    l_source_lines     t_source_lines;
    line_no            binary_integer;
    l_schema_names     ut_varchar2_list;
    l_query            varchar2(32767);
  begin
    l_schema_names := coalesce(a_coverage_options.schema_names, ut_varchar2_list(sys_context('USERENV','CURRENT_SCHEMA')));

    if not ut_coverage_helper.is_develop_mode() then
      --skip all the utplsql framework objects and all the unit test packages that could potentially be reported by coverage.
      l_skipped_objects := ut_utils.get_utplsql_objects_list() multiset union all coalesce(a_coverage_options.exclude_objects, ut_object_names());
    end if;

    --prepare global temp table with sources
    delete from ut_coverage_sources_tmp;
    if a_coverage_options.file_mappings is not null then
      execute immediate populate_sources_tmp_table(a_coverage_options) using a_coverage_options.file_mappings, l_skipped_objects, a_coverage_options.include_objects;
    else
      execute immediate populate_sources_tmp_table(a_coverage_options) using l_schema_names, l_skipped_objects, a_coverage_options.include_objects;
    end if;
    commit;

    for src_object in (
      select o.owner, o.name, o.full_name, max(o.line) lines_count,
             cast(
               collect(decode(to_be_skipped, 'Y', to_char(line))) as ut_varchar2_list
             ) to_be_skipped_list
        from ut_coverage_sources_tmp o
       group by o.owner, o.name, o.full_name
    ) loop

      --get coverage data
      l_line_calls := ut_coverage_helper.get_raw_coverage_data( src_object.owner, src_object.name );

      --if there is coverage, we need to filter out the garbage (badly indicated data from dbms_profiler)
      if l_line_calls.count > 0 then
        --remove lines that should not be indicted as meaningful
        for i in 1 .. src_object.to_be_skipped_list.count loop
          if src_object.to_be_skipped_list(i) is not null then
            l_line_calls.delete(src_object.to_be_skipped_list(i));
          end if;
        end loop;
      end if;

      if not l_result.objects.exists(src_object.full_name) then
        l_result.objects(src_object.full_name) := l_new_unit;
        l_result.objects(src_object.full_name).owner := src_object.owner;
        l_result.objects(src_object.full_name).name  := src_object.name;
      end if;
      l_result.total_lines := l_result.total_lines + src_object.lines_count;
      l_result.objects(src_object.full_name).total_lines := src_object.lines_count;
      --map to results
      line_no := l_line_calls.first;
      if line_no is null then
        l_result.uncovered_lines := l_result.uncovered_lines + src_object.lines_count;
        l_result.objects(src_object.full_name).uncovered_lines := src_object.lines_count;
      else
        loop
          exit when line_no is null;

          if l_line_calls(line_no) > 0 then
            l_result.covered_lines := l_result.covered_lines + 1;
            l_result.executions := l_result.executions + l_line_calls(line_no);
            l_result.objects(src_object.full_name).covered_lines := l_result.objects(src_object.full_name).covered_lines + 1;
            l_result.objects(src_object.full_name).executions := l_result.objects(src_object.full_name).executions + l_line_calls(line_no);
          elsif l_line_calls(line_no) = 0 then
            l_result.uncovered_lines := l_result.uncovered_lines + 1;
            l_result.objects(src_object.full_name).uncovered_lines := l_result.objects(src_object.full_name).uncovered_lines + 1;
          end if;
          l_result.objects(src_object.full_name).lines(line_no) := l_line_calls(line_no);

          line_no := l_line_calls.next(line_no);
        end loop;
      end if;


    end loop;

    commit;
    return l_result;
  end get_coverage_data;

end;
/
