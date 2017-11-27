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

  type t_source_lines is table of binary_integer;

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
  function get_cov_sources_sql(a_coverage_options ut_coverage_options) return varchar2 is
    l_result varchar2(32767);
    l_full_name varchar2(100);
    l_view_name      varchar2(200) := ut_metadata.get_dba_view('dba_source');
  begin
    if a_coverage_options.file_mappings is not null and a_coverage_options.file_mappings.count > 0 then
      l_full_name := 'f.file_name';
    else
      l_full_name := 'lower(s.owner||''.''||s.name)';
    end if;
    l_result := '
      select full_name, owner, name, line, to_be_skipped, text
        from (
          select '||l_full_name||q'[ as full_name,
                 s.owner,
                 s.name,
                 s.line -
                 coalesce(
                   case when type!='TRIGGER' then 0 end,
                   (select min(t.line) - 1
                      from ]'||l_view_name||q'[ t
                     where t.owner = s.owner and t.type = s.type and t.name = s.name
                       and regexp_like( t.text, '[A-Za-z0-9$#_]*(begin|declare|compound).*','i'))
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
            from ]'||l_view_name||q'[ s]';
    if a_coverage_options.file_mappings is not empty then
      l_result := l_result || '
            join table(:file_mappings) f
              on s.name  = f.object_name
             and s.type  = f.object_type
             and s.owner = f.object_owner
           where 1 = 1';
    elsif a_coverage_options.include_objects is not empty then
      l_result := l_result || '
           where (s.owner, s.name) in (select il.owner, il.name from table(:include_objects) il)';
    else
      l_result := l_result || '
           where s.owner in (select upper(t.column_value) from table(:l_schema_names) t)';
    end if;
    l_result := l_result || q'[
             and s.type not in ('PACKAGE', 'TYPE', 'JAVA SOURCE')
             --Exclude calls to utPLSQL framework, Unit Test packages and objects from a_exclude_list parameter of coverage reporter
             and (s.owner, s.name) not in (select el.owner, el.name from table(:l_skipped_objects) el)
             )
       where line > 0]';
    return l_result;
  end;

  function get_cov_sources_cursor(a_coverage_options ut_coverage_options) return sys_refcursor is
    l_cursor        sys_refcursor;
    l_skip_objects  ut_object_names;
    l_schema_names  ut_varchar2_rows;
    l_sql           varchar2(32767);
  begin
    l_schema_names := coalesce(a_coverage_options.schema_names, ut_varchar2_rows(sys_context('USERENV','CURRENT_SCHEMA')));
    if not ut_coverage_helper.is_develop_mode() then
      --skip all the utplsql framework objects and all the unit test packages that could potentially be reported by coverage.
      l_skip_objects := ut_utils.get_utplsql_objects_list() multiset union all coalesce(a_coverage_options.exclude_objects, ut_object_names());
    end if;
    l_sql := get_cov_sources_sql(a_coverage_options);
    if a_coverage_options.file_mappings is not empty then
      open l_cursor for l_sql using a_coverage_options.file_mappings, l_skip_objects;
    elsif a_coverage_options.include_objects is not empty then
      open l_cursor for l_sql using a_coverage_options.include_objects, l_skip_objects;
    else
      open l_cursor for l_sql using l_schema_names, l_skip_objects;
    end if;
    return l_cursor;
  end;

  procedure populate_tmp_table(a_coverage_options ut_coverage_options) is
    pragma autonomous_transaction;
    l_cov_sources_crsr sys_refcursor;
    l_cov_sources_data ut_coverage_helper.t_coverage_sources_tmp_rows;
  begin

    if not ut_coverage_helper.is_tmp_table_populated() or ut_coverage_helper.is_develop_mode() then
      ut_coverage_helper.cleanup_tmp_table();

      l_cov_sources_crsr := get_cov_sources_cursor(a_coverage_options);

      loop
        fetch l_cov_sources_crsr bulk collect into l_cov_sources_data limit 1000;

        ut_coverage_helper.insert_into_tmp_table(l_cov_sources_data);

        exit when l_cov_sources_crsr%notfound;
      end loop;

      close l_cov_sources_crsr;
    end if;
    commit;
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
    l_line_calls          ut_coverage_helper.t_unit_line_calls;
    l_result              t_coverage;
    l_new_unit            t_unit_coverage;
    line_no               binary_integer;
    l_source_objects_crsr ut_coverage_helper.t_tmp_table_objects_crsr;
    l_source_object       ut_coverage_helper.t_tmp_table_object;
  begin

    --prepare global temp table with sources
    populate_tmp_table(a_coverage_options);

    l_source_objects_crsr := ut_coverage_helper.get_tmp_table_objects_cursor();
    loop
      fetch l_source_objects_crsr into l_source_object;
      exit when l_source_objects_crsr%notfound;

      --get coverage data
      l_line_calls := ut_coverage_helper.get_raw_coverage_data( l_source_object.owner, l_source_object.name );

      --if there is coverage, we need to filter out the garbage (badly indicated data from dbms_profiler)
      if l_line_calls.count > 0 then
        --remove lines that should not be indicted as meaningful
        for i in 1 .. l_source_object.to_be_skipped_list.count loop
          if l_source_object.to_be_skipped_list(i) is not null then
            l_line_calls.delete(l_source_object.to_be_skipped_list(i));
          end if;
        end loop;
      end if;

      --if there are no file mappings or object was actually captured by profiler
      if a_coverage_options.file_mappings is null or l_line_calls.count > 0 then

        --populate total stats
        l_result.total_lines := l_result.total_lines + l_source_object.lines_count;

        --populate object level coverage stats
        if not l_result.objects.exists(l_source_object.full_name) then
          l_result.objects(l_source_object.full_name) := l_new_unit;
          l_result.objects(l_source_object.full_name).owner := l_source_object.owner;
          l_result.objects(l_source_object.full_name).name  := l_source_object.name;
          l_result.objects(l_source_object.full_name).total_lines := l_source_object.lines_count;
        end if;
        --map to results
        line_no := l_line_calls.first;
        if line_no is null then
          l_result.uncovered_lines := l_result.uncovered_lines + l_source_object.lines_count;
          l_result.objects(l_source_object.full_name).uncovered_lines := l_source_object.lines_count;
        else
          loop
            exit when line_no is null;

            if l_line_calls(line_no) > 0 then
              --total stats
              l_result.covered_lines := l_result.covered_lines + 1;
              l_result.executions := l_result.executions + l_line_calls(line_no);
              --object level stats
              l_result.objects(l_source_object.full_name).covered_lines := l_result.objects(l_source_object.full_name).covered_lines + 1;
              l_result.objects(l_source_object.full_name).executions := l_result.objects(l_source_object.full_name).executions + l_line_calls(line_no);
            elsif l_line_calls(line_no) = 0 then
              l_result.uncovered_lines := l_result.uncovered_lines + 1;
              l_result.objects(l_source_object.full_name).uncovered_lines := l_result.objects(l_source_object.full_name).uncovered_lines + 1;
            end if;
            l_result.objects(l_source_object.full_name).lines(line_no) := l_line_calls(line_no);

            line_no := l_line_calls.next(line_no);
          end loop;
        end if;
      end if;

    end loop;

    close l_source_objects_crsr;

    return l_result;
  end get_coverage_data;

end;
/
