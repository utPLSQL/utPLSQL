create or replace package body ut_coverage is
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

  g_develop_mode    boolean not null := false;
  g_is_started      boolean not null := false;

  procedure set_develop_mode(a_develop_mode in boolean) is
  begin
    g_develop_mode := a_develop_mode;
  end;

  function is_develop_mode return boolean is
  begin
    return g_develop_mode;
  end;

  function get_cov_sources_sql(a_coverage_options ut_coverage_options, a_skip_objects ut_object_names) return varchar2 is
    l_result                varchar2(32767);
    l_full_name             varchar2(32767);
    l_join_mappings         varchar2(32767);
    l_filters               varchar2(32767);
    l_mappings_cardinality  integer := 0;
  begin
    l_result := q'[
    with
      sources as (
        select /*+ cardinality(f {mappings_cardinality}) */
               {l_full_name} as full_name, s.owner, s.name, s.type,
               s.line
               - case
                   when s.type = 'TRIGGER'
                     then
                       /* calculate offset of line number for trigger source in coverage reporting */
                       min(case when lower(s.text) like '%begin%' or lower(s.text) like '%declare%' or lower(s.text) like '%compound%' then s.line-1 end)
                         over (partition by s.owner, s.type, s.name)
                     else 0
               end as line,
               s.text
          from {sources_view} s {join_file_mappings}
         where s.type in ('PACKAGE BODY', 'TYPE BODY', 'PROCEDURE', 'FUNCTION', 'TRIGGER')
           {filters}
      ),
      coverage_sources as (
        select full_name, owner, name, type, line, text,
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
                      '^([\t ]*(((not)?\s*(overriding|final|instantiable)[\t ]*)*(static|constructor|member)?[\t ]*(procedure|function)|package([\t ]+body)|begin|end([\t ]+\S+)*[ \t]*;))', 'i'
                   )
                  then 'Y'
               end as to_be_skipped
          from sources s
      )
    select /*+ no_parallel */ full_name, owner, name, type, line, to_be_skipped, text
      from coverage_sources s
           -- Exclude calls to utPLSQL framework, Unit Test packages and objects from a_exclude_list parameter of coverage reporter
     where not exists (
              select /*+ cardinality(el {skipped_objects_cardinality})*/ 1
                from table(:l_skipped_objects) el
               where s.owner = el.owner and  s.name = el.name
           )
       and line > 0
    ]';

    if a_coverage_options.file_mappings is not empty then
      l_mappings_cardinality := ut_utils.scale_cardinality(cardinality(a_coverage_options.file_mappings));
      l_full_name := 'f.file_name';
      l_join_mappings := '
            join table(:file_mappings) f
              on s.name  = f.object_name
             and s.type  = f.object_type
             and s.owner = f.object_owner';
    else
      l_full_name := q'[lower(s.type||' '||s.owner||'.'||s.name)]';
      l_filters := case
        when a_coverage_options.include_objects is not empty then '
           and (s.owner, s.name) in (
                 select /*+ cardinality(il '||ut_utils.scale_cardinality(cardinality(a_coverage_options.include_objects))||') */
                        il.owner, il.name
                   from table(:include_objects) il
               )'
        else '
           and s.owner in (
                 select /*+ cardinality(t '||ut_utils.scale_cardinality(cardinality(a_coverage_options.schema_names))||') */
                        upper(t.column_value)
                   from table(:l_schema_names) t)'
        end;
    end if;

    l_result := replace(l_result, '{sources_view}',         ut_metadata.get_source_view_name());
    l_result := replace(l_result, '{l_full_name}',          l_full_name);
    l_result := replace(l_result, '{join_file_mappings}',   l_join_mappings);
    l_result := replace(l_result, '{filters}',              l_filters);
    l_result := replace(l_result, '{mappings_cardinality}', l_mappings_cardinality);
    l_result := replace(l_result, '{skipped_objects_cardinality}', ut_utils.scale_cardinality(cardinality(a_skip_objects)));

    return l_result;

  end;

  function get_cov_sources_cursor(a_coverage_options in ut_coverage_options) return sys_refcursor is
    l_cursor        sys_refcursor;
    l_skip_objects  ut_object_names;
    l_sql           varchar2(32767);
  begin
    if not is_develop_mode() then
      --skip all the utplsql framework objects and all the unit test packages that could potentially be reported by coverage.
      l_skip_objects := ut_utils.get_utplsql_objects_list() multiset union all coalesce(a_coverage_options.exclude_objects, ut_object_names());
    end if;

    l_sql := get_cov_sources_sql(a_coverage_options, l_skip_objects);

    ut_event_manager.trigger_event(ut_event_manager.gc_debug, ut_key_anyvalues().put('l_sql',l_sql) );

    if a_coverage_options.file_mappings is not empty then
      open l_cursor for l_sql using a_coverage_options.file_mappings, l_skip_objects;
    elsif a_coverage_options.include_objects is not empty then
      open l_cursor for l_sql using a_coverage_options.include_objects, l_skip_objects;
    else
      open l_cursor for l_sql using a_coverage_options.schema_names, l_skip_objects;
    end if;
    return l_cursor;
  end;

  procedure populate_tmp_table(a_coverage_options ut_coverage_options) is
    pragma autonomous_transaction;
    l_cov_sources_crsr sys_refcursor;
    l_cov_sources_data ut_coverage_helper.t_coverage_sources_tmp_rows;
  begin

    if not ut_coverage_helper.is_tmp_table_populated() or is_develop_mode() then
      ut_coverage_helper.cleanup_tmp_table();
      l_cov_sources_crsr := get_cov_sources_cursor(a_coverage_options);

      loop
        fetch l_cov_sources_crsr bulk collect into l_cov_sources_data limit 10000;

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
  procedure coverage_start(a_coverage_run_id t_coverage_run_id) is
    l_run_comment varchar2(200) := 'utPLSQL Code coverage run '||ut_utils.to_string(systimestamp);
    l_line_coverage_id  integer;
    l_block_coverage_id integer;
  begin
    if not is_develop_mode() and not g_is_started then
      l_line_coverage_id  := ut_coverage_helper_profiler.coverage_start( l_run_comment );
      l_block_coverage_id := ut_coverage_helper_block.coverage_start( l_run_comment );
      g_is_started := true;
      ut_coverage_helper.set_coverage_run_ids(a_coverage_run_id, l_line_coverage_id, l_block_coverage_id);
    end if;
  end;

  procedure coverage_pause is
  begin
    if not is_develop_mode() then
      ut_coverage_helper_profiler.coverage_pause();
    end if;
  end;

  procedure coverage_resume is
  begin
    ut_coverage_helper_profiler.coverage_resume();
  end;

  procedure coverage_stop is
  begin
    if not is_develop_mode() then
      g_is_started := false;
      ut_coverage_helper_block.coverage_stop();
      ut_coverage_helper_profiler.coverage_stop();
      g_is_started := false;
    end if;
  end;

  function get_coverage_data(a_coverage_options ut_coverage_options) return t_coverage is
    l_result_block           ut_coverage.t_coverage;
    l_result_profiler_enrich ut_coverage.t_coverage;
    l_object                 ut_coverage.t_object_name;
    l_line_no                binary_integer;
    l_coverage_options       ut_coverage_options := a_coverage_options;
  begin
    --prepare global temp table with sources
    ut_event_manager.trigger_event('about to populate coverage temp table');
    populate_tmp_table(l_coverage_options);
    ut_event_manager.trigger_event('coverage temp table populated');

    -- Get raw data for both reporters, order is important as tmp table will skip headers and dont populate
    -- tmp table for block again.
    l_result_profiler_enrich := ut_coverage_profiler.get_coverage_data( l_coverage_options );
    ut_event_manager.trigger_event('profiler coverage data retrieved');

    -- If block coverage available we will use it.
    $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
      l_result_block := ut_coverage_block.get_coverage_data( l_coverage_options );
      ut_event_manager.trigger_event('block coverage data retrieved');

      -- Enrich profiler results with some of the block results
      l_object := l_result_profiler_enrich.objects.first;
      while (l_object is not null) loop

        l_line_no := l_result_profiler_enrich.objects(l_object).lines.first;

        -- to avoid no data found check if we got object in profiler
        if l_result_block.objects.exists(l_object) then
          while (l_line_no is not null) loop
            -- To avoid no data check for object line
            if l_result_block.objects(l_object).lines.exists(l_line_no) then
             -- enrich line level stats
             l_result_profiler_enrich.objects(l_object).lines(l_line_no).partcove := l_result_block.objects(l_object).lines(l_line_no).partcove;
             l_result_profiler_enrich.objects(l_object).lines(l_line_no).covered_blocks := l_result_block.objects(l_object).lines(l_line_no).covered_blocks;
             l_result_profiler_enrich.objects(l_object).lines(l_line_no).no_blocks := l_result_block.objects(l_object).lines(l_line_no).no_blocks;
             -- enrich object level stats
             l_result_profiler_enrich.objects(l_object).partcovered_lines :=  nvl(l_result_profiler_enrich.objects(l_object).partcovered_lines,0) + l_result_block.objects(l_object).lines(l_line_no).partcove;
            end if;
            --At the end go to next line
            l_line_no := l_result_profiler_enrich.objects(l_object).lines.next(l_line_no);
          end loop;
          --total level stats enrich
          l_result_profiler_enrich.partcovered_lines := nvl(l_result_profiler_enrich.partcovered_lines,0) + l_result_profiler_enrich.objects(l_object).partcovered_lines;
          -- At the end go to next object
        end if;

        l_object := l_result_profiler_enrich.objects.next(l_object);
      end loop;
      ut_event_manager.trigger_event('coverage data combined');
    $end
        
    return l_result_profiler_enrich;
  end get_coverage_data;  
  
end;
/
