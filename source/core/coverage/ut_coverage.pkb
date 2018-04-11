create or replace package body ut_coverage is
  /*
  utPLSQL - Version 3
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

  function get_cov_sources_sql(a_coverage_options ut_coverage_options, a_skipped_lines varchar2 default 'Y') return varchar2 is
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
                 s.text, ]';
     if a_skipped_lines = 'Y' then
      l_result := l_result ||
                 q'[case
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
                 end as to_be_skipped ]';
    else
      l_result := l_result || q'['N' as to_be_skipped ]';
    end if;
                 
    l_result := l_result ||' from '||l_view_name||q'[ s]';
            
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

  function get_cov_sources_cursor(a_coverage_options in ut_coverage_options,a_sql in varchar2) return sys_refcursor is
    l_cursor        sys_refcursor;
    l_skip_objects  ut_object_names;
    l_sql           varchar2(32767);
  begin
    if not ut_coverage_helper.is_develop_mode() then
      --skip all the utplsql framework objects and all the unit test packages that could potentially be reported by coverage.
      l_skip_objects := ut_utils.get_utplsql_objects_list() multiset union all coalesce(a_coverage_options.exclude_objects, ut_object_names());
    end if;
    l_sql := a_sql;
    if a_coverage_options.file_mappings is not empty then
      open l_cursor for l_sql using a_coverage_options.file_mappings, l_skip_objects;
    elsif a_coverage_options.include_objects is not empty then
      open l_cursor for l_sql using a_coverage_options.include_objects, l_skip_objects;
    else
      open l_cursor for l_sql using a_coverage_options.schema_names, l_skip_objects;
    end if;
    return l_cursor;
  end;

  procedure populate_tmp_table(a_coverage_options in ut_coverage_options,a_sql in varchar2) is
    pragma autonomous_transaction;
    l_cov_sources_crsr sys_refcursor;
    l_cov_sources_data ut_coverage_helper.t_coverage_sources_tmp_rows;
  begin

    if not ut_coverage_helper.is_tmp_table_populated() or ut_coverage_helper.is_develop_mode() then
      ut_coverage_helper.cleanup_tmp_table();

      l_cov_sources_crsr := get_cov_sources_cursor(a_coverage_options,a_sql);

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
  procedure coverage_start(a_coverage_options ut_coverage_options default null) is
    l_coverage_type varchar2(10) := coalesce(a_coverage_options.coverage_type, gc_proftab_coverage);
  begin
    ut_coverage_helper.coverage_start('utPLSQL Code coverage run '||ut_utils.to_string(systimestamp),l_coverage_type);
  end;

  procedure coverage_start_develop(a_coverage_options ut_coverage_options default null) is
    l_coverage_type varchar2(10) := coalesce(a_coverage_options.coverage_type, gc_proftab_coverage);
  begin
    ut_coverage_helper.coverage_start_develop(l_coverage_type);
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
  begin
    
    if a_coverage_options.coverage_type = gc_block_coverage then
      $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
      return ut_coverage_block.get_coverage_data_block(a_coverage_options => a_coverage_options);
      $else
       return null;
      $end     
    elsif a_coverage_options.coverage_type = gc_extended_coverage then
      --Collect data for block and proftab and pass to extended for modifications.
      return ut_coverage_extended.get_extended_coverage(a_coverage_options => a_coverage_options);
    else
      return ut_coverage_proftab.get_coverage_data_profiler(a_coverage_options => a_coverage_options);
    end if;
  end get_coverage_data;  
  
end;
/
