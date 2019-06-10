create or replace package body ut_annotation_manager as
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

  ------------------------------
  --private definitions

  function get_missing_objects(a_object_owner varchar2, a_object_type varchar2) return ut_annotation_objs_cache_info is
    l_rows         sys_refcursor;
    l_ut_owner     varchar2(250) := ut_utils.ut_owner;
    l_objects_view varchar2(200) := ut_metadata.get_objects_view_name();
    l_cursor_text  varchar2(32767);
    l_result       ut_annotation_objs_cache_info;
  begin
    l_cursor_text :=
      q'[select ]'||l_ut_owner||q'[.ut_annotation_obj_cache_info(
                    object_owner => i.object_owner,
                    object_name => i.object_name,
                    object_type => i.object_type,
                    needs_refresh => null
                  )
           from ]'||l_ut_owner||q'[.ut_annotation_cache_info i
           where
             not exists (
                select 1  from ]'||l_objects_view||q'[ o
                 where o.owner = i.object_owner
                   and o.object_name = i.object_name
                   and o.object_type = i.object_type
                   and o.owner = :a_object_owner
                   and o.object_type = :a_object_type
                )
            and i.object_owner = :a_object_owner
            and i.object_type = :a_object_type]';
    open l_rows for l_cursor_text  using a_object_owner, a_object_type, a_object_owner, a_object_type;
    fetch l_rows bulk collect into l_result limit 1000000;
    close l_rows;
    return l_result;
  end;

  function get_annotation_objs_info(
    a_object_owner varchar2,
    a_object_type  varchar2,
    a_parse_date   timestamp := null,
    a_full_scan    boolean   := true
  ) return ut_annotation_objs_cache_info is
    l_rows          sys_refcursor;
    l_ut_owner      varchar2(250) := ut_utils.ut_owner;
    l_objects_view  varchar2(200) := ut_metadata.get_objects_view_name();
    l_cursor_text   varchar2(32767);
    l_result        ut_annotation_objs_cache_info;
    l_object_owner  varchar2(250);
    l_object_type   varchar2(250);
  begin
    ut_event_manager.trigger_event(
      'get_annotation_objs_info - start ( a_full_scan = ' || ut_utils.to_string(a_full_scan) || ' )'
    );
    if not a_full_scan then
      l_cursor_text :=
        q'[select ]'||l_ut_owner||q'[.ut_annotation_obj_cache_info(
                      object_owner  => i.object_owner,
                      object_name   => i.object_name,
                      object_type   => i.object_type,
                      needs_refresh => 'N'
                    )
             from ]'||l_ut_owner||q'[.ut_annotation_cache_info i
            where i.object_owner = :a_object_owner
              and i.object_type  = :a_object_type]';
      open l_rows for l_cursor_text  using a_object_owner, a_object_type;
    else
      if a_object_owner is not null then
        l_object_owner := sys.dbms_assert.qualified_sql_name(a_object_owner);
      end if;
      if a_object_type is not null then
        l_object_type := sys.dbms_assert.qualified_sql_name(a_object_type);
      end if;
      l_cursor_text :=
        q'[select ]'||l_ut_owner||q'[.ut_annotation_obj_cache_info(
                      object_owner  => o.owner,
                      object_name   => o.object_name,
                      object_type   => o.object_type,
                      needs_refresh => case when o.last_ddl_time < cast(i.parse_time as date) then 'N' else 'Y' end
                    )
             from ]'||l_objects_view||q'[ o
             left join ]'||l_ut_owner||q'[.ut_annotation_cache_info i
               on o.owner       = i.object_owner
              and o.object_name = i.object_name
              and o.object_type = i.object_type
            where o.owner       = ']'||l_object_owner||q'['
              and o.object_type = ']'||l_object_type||q'['
              and ]'
          || case
             when a_parse_date is null
               then ':a_parse_date is null'
             else 'o.last_ddl_time >= cast(:a_parse_date as date)'
             end;
      open l_rows for l_cursor_text  using a_parse_date;
    end if;
    fetch l_rows bulk collect into l_result limit 10000000;
    close l_rows;
    ut_event_manager.trigger_event('get_annotation_objs_info - end (count='||l_result.count||')');
    return l_result;
  end;

  function get_sources_to_annotate(a_object_owner varchar2, a_object_type varchar2) return sys_refcursor is
    l_result       sys_refcursor;
    l_sources_view varchar2(200) := ut_metadata.get_source_view_name();
  begin
    open l_result for
     q'[select s.name, s.text
          from (select s.name, s.text, s.line,
                       max(case when s.text like '%--%\%%' escape '\'
                                 and regexp_like(s.text,'--\s*%')
                           then 'Y' else 'N' end
                          )
                         over(partition by s.name) is_annotated
                  from ]'||l_sources_view||q'[ s
                 where s.type = :a_object_type
                   and s.owner = :a_object_owner
               ) s
         where s.is_annotated = 'Y'
         order by s.name, s.line]'
      using a_object_type, a_object_owner, a_object_type, a_object_owner;

    return l_result;
  end;

  function get_sources_to_annotate(a_object_owner varchar2, a_object_type varchar2, a_objects_to_refresh ut_annotation_objs_cache_info) return sys_refcursor is
    l_result       sys_refcursor;
    l_sources_view varchar2(200) := ut_metadata.get_source_view_name();
    l_card         natural;
  begin
    l_card := ut_utils.scale_cardinality(cardinality(a_objects_to_refresh));
    open l_result for
     q'[select s.name, s.text
          from (select /*+ cardinality( r ]'||l_card||q'[ )*/
                       s.name, s.text, s.line,
                       max(case when s.text like '%--%\%%' escape '\'
                                 and regexp_like(s.text,'--\s*%')
                           then 'Y' else 'N' end
                          )
                         over(partition by s.name) is_annotated
                  from table(:a_objects_to_refresh) r
                  join ]'||l_sources_view||q'[ s
                    on s.name = r.object_name
                   and s.owner = r.object_owner
                   and s.type = r.object_type
                 where s.type = :a_object_type
                   and s.owner = :a_object_owner
               ) s
         where s.is_annotated = 'Y'
          order by s.name, s.line]'
      using a_objects_to_refresh, a_object_type, a_object_owner;

    return l_result;
  end;

  procedure build_annot_cache_for_sources(
    a_object_owner     varchar2,
    a_object_type      varchar2,
    a_sources_cursor   sys_refcursor
  ) is
    l_annotations         ut_annotations;
    c_lines_fetch_limit   constant integer := 10000;
    l_lines               dbms_preprocessor.source_lines_t;
    l_names               dbms_preprocessor.source_lines_t;
    l_name                varchar2(250);
    l_object_lines        dbms_preprocessor.source_lines_t;
    l_parse_time          date := sysdate;
    pragma autonomous_transaction;
  begin
    loop
      fetch a_sources_cursor bulk collect into l_names, l_lines limit c_lines_fetch_limit;
      for i in 1 .. l_names.count loop
        if l_names(i) != l_name then
          l_annotations := ut_annotation_parser.parse_object_annotations(l_object_lines, a_object_type);
          ut_annotation_cache_manager.update_cache(
            ut_annotated_object(a_object_owner, l_name, a_object_type, l_parse_time, l_annotations)
          );
          l_object_lines.delete;
        end if;

        l_name  := l_names(i);
        l_object_lines(l_object_lines.count+1) := l_lines(i);
      end loop;
      exit when a_sources_cursor%notfound;

    end loop;
    if a_sources_cursor%rowcount > 0 then
      l_annotations := ut_annotation_parser.parse_object_annotations(l_object_lines, a_object_type);
      ut_annotation_cache_manager.update_cache(
        ut_annotated_object(a_object_owner, l_name, a_object_type, l_parse_time, l_annotations)
      );
      l_object_lines.delete;
    end if;
    close a_sources_cursor;
    commit;
  end;


  procedure refresh_annotation_cache(
    a_object_owner varchar2,
    a_object_type  varchar2,
    a_info_rows    ut_annotation_objs_cache_info
  ) is
    l_objects_to_parse       ut_annotation_objs_cache_info;
  begin
    select value(x)
      bulk collect into l_objects_to_parse
      from table(a_info_rows) x where x.needs_refresh = 'Y';

    ut_event_manager.trigger_event('rebuild_annotation_cache - start (l_objects_to_parse.count = '||l_objects_to_parse.count||')');
    ut_annotation_cache_manager.cleanup_cache(l_objects_to_parse);

    if sys_context('userenv','current_schema') = a_object_owner
      or ut_metadata.user_has_execute_any_proc()
      or ut_metadata.is_object_visible('dba_objects')
    then
      ut_annotation_cache_manager.remove_from_cache(
        get_missing_objects(a_object_owner, a_object_type)
      );
    end if;

    --if some source needs parsing and putting into cache
    if l_objects_to_parse.count > 0 then
      build_annot_cache_for_sources(
        a_object_owner, a_object_type,
        get_sources_to_annotate(a_object_owner, a_object_type, l_objects_to_parse)
      );
    end if;
    ut_event_manager.trigger_event('rebuild_annotation_cache - end');
  end;

  ------------------------------------------------------------
  --public definitions
  ------------------------------------------------------------
  procedure rebuild_annotation_cache(a_object_owner varchar2, a_object_type varchar2) is
    l_annotation_objs_info ut_annotation_objs_cache_info;
  begin
    l_annotation_objs_info := get_annotation_objs_info(a_object_owner, a_object_type, null, true);
    refresh_annotation_cache( a_object_owner, a_object_type, l_annotation_objs_info );
  end;

  procedure trigger_obj_annotation_rebuild is
    l_sql_text         ora_name_list_t;
    l_parts            binary_integer;
    l_object_to_parse  ut_annotation_obj_cache_info;
    l_restricted_users ora_name_list_t;

    function get_source_from_sql_text(a_object_name varchar2, a_sql_text ora_name_list_t, a_parts binary_integer) return sys_refcursor is
      l_sql_clob    clob;
      l_sql_lines   ut_varchar2_rows := ut_varchar2_rows();
      l_result      sys_refcursor;
      l_sql_text    ora_name_list_t := a_sql_text;
    begin
      if a_parts > 0 then
        l_sql_text(1) := regexp_replace(l_sql_text(1),'^\s*create(\s+or\s+replace){0,1}(\s+(editionable|noneditionable)){0,1}\s+{0,1}', modifier => 'i');
        for i in 1..a_parts loop
          ut_utils.append_to_clob(l_sql_clob, l_sql_text(i));
        end loop;
        l_sql_lines := ut_utils.convert_collection( ut_utils.clob_to_table(l_sql_clob) );
      end if;
      open l_result for
        select a_object_name as name, column_value||chr(10) as text from table(l_sql_lines);
      return l_result;
    end;

    function get_source_for_object(a_object_owner varchar2, a_object_name varchar2, a_object_type varchar2) return sys_refcursor is
      l_result       sys_refcursor;
      l_sources_view varchar2(200) := ut_metadata.get_source_view_name();
    begin
      open l_result for
        q'[select :a_object_name, s.text
             from ]'||l_sources_view||q'[ s
            where s.type  = :a_object_type
              and s.owner = :a_object_owner
              and s.name  = :a_object_name
          order by s.line]'
        using a_object_name, a_object_type, a_object_owner, a_object_name;
      return l_result;
    end;

  begin
    if ora_dict_obj_type in ('PACKAGE','PROCEDURE','FUNCTION','TYPE') then
      $if dbms_db_version.version < 12 $then
        l_restricted_users := ora_name_list_t(
          'ANONYMOUS','APPQOSSYS','AUDSYS','DBSFWUSER','DBSNMP','DIP','GGSYS','GSMADMIN_INTERNAL',
          'GSMCATUSER','GSMUSER','ORACLE_OCM','OUTLN','REMOTE_SCHEDULER_AGENT','SYS','SYS$UMF',
          'SYSBACKUP','SYSDG','SYSKM','SYSRAC','SYSTEM','WMSYS','XDB','XS$NULL');
      $else
        select username bulk collect into l_restricted_users
          from all_users where oracle_maintained = 'Y';
      $end
      if ora_dict_obj_owner member of l_restricted_users then
        return;
      end if;

      l_object_to_parse := ut_annotation_obj_cache_info(ora_dict_obj_owner, ora_dict_obj_name, ora_dict_obj_type, 'Y');

      if ora_sysevent = 'CREATE' then
        l_parts := ORA_SQL_TXT(l_sql_text);
        build_annot_cache_for_sources(
          ora_dict_obj_owner, ora_dict_obj_type,
          get_source_from_sql_text(ora_dict_obj_name, l_sql_text, l_parts)
        );
      elsif ora_sysevent = 'ALTER' then
        build_annot_cache_for_sources(
          ora_dict_obj_owner, ora_dict_obj_type,
          get_source_for_object(ora_dict_obj_owner, ora_dict_obj_name, ora_dict_obj_type)
          );
      elsif ora_sysevent = 'DROP' then
        ut_annotation_cache_manager.remove_from_cache(ut_annotation_objs_cache_info(l_object_to_parse));
      end if;
    end if;
  end;

  function get_annotated_objects(a_object_owner varchar2, a_object_type varchar2, a_parse_date timestamp := null) return ut_annotated_objects pipelined is
    l_annotation_objs_info   ut_annotation_objs_cache_info;
    l_cursor                 sys_refcursor;
    l_results                ut_annotated_objects;
    c_object_fetch_limit     constant integer := 10;
    l_full_scan_needed       boolean := not ut_trigger_check.is_alive();
  begin
    ut_event_manager.trigger_event('get_annotated_objects - start');
    l_annotation_objs_info := get_annotation_objs_info(a_object_owner, a_object_type, a_parse_date, l_full_scan_needed);
    refresh_annotation_cache(a_object_owner, a_object_type, l_annotation_objs_info);

    --pipe annotations from cache
    l_cursor := ut_annotation_cache_manager.get_annotations_for_objects(l_annotation_objs_info, a_parse_date);
    loop
      fetch l_cursor bulk collect into l_results limit c_object_fetch_limit;
      for i in 1 .. l_results.count loop
        pipe row (l_results(i));
      end loop;
      exit when l_cursor%notfound;
    end loop;
    close l_cursor;
    ut_event_manager.trigger_event('get_annotated_objects - end');
  end;

  procedure purge_cache(a_object_owner varchar2, a_object_type varchar2) is
  begin
    ut_annotation_cache_manager.purge_cache(a_object_owner, a_object_type);
  end;

  function hash_suite_path(a_path varchar2, a_random_seed positiven) return varchar2 is
    l_start_pos pls_integer := 1;
    l_end_pos   pls_integer := 1;
    l_result    varchar2(4000);
    l_item      varchar2(4000);
    l_at_end    boolean := false;
  begin
    if a_random_seed is null then
      l_result := a_path;
    end if;
    if a_path is not null then
      loop
        l_end_pos := instr(a_path,'.',l_start_pos);
        if l_end_pos = 0 then
          l_end_pos := length(a_path)+1;
          l_at_end  := true;
          end if;
        l_item := substr(a_path,l_start_pos,l_end_pos-l_start_pos);
        if l_item is not null then
          l_result  :=
            l_result ||
            dbms_crypto.hash(
              to_char( dbms_utility.get_hash_value( l_item, 1, a_random_seed ) ),
                  dbms_crypto.hash_sh1
                );
        end if;
        exit when l_at_end;
        l_result  := l_result || chr(0);
        l_start_pos := l_end_pos + 1;
      end loop;
    end if;
    return l_result;
  end;

end ut_annotation_manager;
/
