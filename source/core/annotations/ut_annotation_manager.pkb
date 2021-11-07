create or replace package body ut_annotation_manager as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2019 utPLSQL Project

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

  function user_can_see_whole_schema( a_schema_name varchar2 ) return boolean is
  begin
    return sys_context('userenv','current_user') = a_schema_name
      or ut_metadata.user_has_execute_any_proc()
      or ut_metadata.is_object_visible('dba_objects');
  end;

  function get_non_existing_objects( a_object_owner varchar2, a_object_type varchar2 ) return ut_annotation_objs_cache_info is
    l_objects_view     varchar2(200) := ut_metadata.get_objects_view_name();
    l_object_to_delete ut_annotation_objs_cache_info := ut_annotation_objs_cache_info();
    l_cached_objects   ut_annotation_objs_cache_info;
  begin
    l_cached_objects := ut_annotation_cache_manager.get_cached_objects_list( a_object_owner, a_object_type );

    if l_cached_objects is not empty then
      execute immediate 'select /*+ no_parallel cardinality(i '||ut_utils.scale_cardinality(cardinality(l_cached_objects))||') */
                  value(i)
             from table( :l_data ) i
             where
               not exists (
                  select 1  from '||l_objects_view||q'[ o
                   where o.owner       = i.object_owner
                     and o.object_name = i.object_name
                     and o.object_type = i.object_type
                     and o.owner       = ']'||ut_utils.qualified_sql_name(a_object_owner)||q'['
                     and o.object_type = ']'||ut_utils.qualified_sql_name(a_object_type)||q'['
                  )]'
        bulk collect into l_object_to_delete
        using l_cached_objects;
    end if;
    return l_object_to_delete;
  end;

  function get_objects_to_refresh(
    a_object_owner   varchar2,
    a_object_type    varchar2,
    a_modified_after timestamp
  ) return ut_annotation_objs_cache_info is
    l_ut_owner       varchar2(250) := ut_utils.ut_owner;
    l_refresh_needed boolean;
    l_objects_view   varchar2(200) := ut_metadata.get_objects_view_name();
    l_cached_objects ut_annotation_objs_cache_info;
    l_result         ut_annotation_objs_cache_info;
  begin
    ut_event_manager.trigger_event( 'get_objects_to_refresh - start' );

    l_refresh_needed := ( ut_trigger_check.is_alive() = false ) or a_modified_after is null;
    l_cached_objects := ut_annotation_cache_manager.get_cached_objects_list( a_object_owner, a_object_type, a_modified_after );
    if l_refresh_needed then
      --limit the list to objects that exist and are visible to the invoking user
      --enrich the list by info about cache validity
      execute immediate
        'select /*+ no_parallel cardinality(i '||ut_utils.scale_cardinality(cardinality(l_cached_objects))||') */
                '||l_ut_owner||q'[.ut_annotation_obj_cache_info(
                  object_owner  => o.owner,
                  object_name   => o.object_name,
                  object_type   => o.object_type,
                  needs_refresh => 'Y',
                  parse_time    => c.parse_time
                )
           from ]'||l_objects_view||' o
           left join table( cast(:l_cached_objects as '||l_ut_owner||q'[.ut_annotation_objs_cache_info ) ) c
             on o.owner       = c.object_owner
            and o.object_name = c.object_name
            and o.object_type = c.object_type
          where o.owner       = ']'||ut_utils.qualified_sql_name(a_object_owner)||q'['
            and o.object_type = ']'||ut_utils.qualified_sql_name(a_object_type)||q'['
            and case when o.last_ddl_time < cast(c.parse_time as date) then 'N' else 'Y' end = 'Y'
            and ]'
          || case
             when a_modified_after is null
               then ':a_modified_after is null'
             else 'o.last_ddl_time >= cast(:a_modified_after as date)'
             end
        bulk collect into l_result using l_cached_objects, a_modified_after;
    else
      l_result := l_cached_objects;
    end if;
    ut_event_manager.trigger_event('get_objects_to_refresh - end (count='||l_result.count||')');
    return l_result;
  end;

  function get_sources_to_annotate(a_object_owner varchar2, a_object_type varchar2, a_objects_to_refresh ut_annotation_objs_cache_info) return sys_refcursor is
    l_result       sys_refcursor;
    l_sources_view varchar2(200) := ut_metadata.get_source_view_name();
    l_card         natural;
  begin
    l_card := ut_utils.scale_cardinality(cardinality(a_objects_to_refresh));
    open l_result for
      q'[select /*+ no_parallel */ x.name, x.text
          from (select /*+ cardinality( r ]'||l_card||q'[ )*/
                       s.name, s.text, s.line,
                       max(case when s.text like '%--%\%%' escape '\'
                                 and regexp_like(s.text,'^\s*--\s*%')
                           then 'Y' else 'N' end
                          )
                         over(partition by s.name) is_annotated
                  from table(:a_objects_to_refresh) r
                  join ]'||l_sources_view||q'[ s
                    on s.name  = r.object_name
                   and s.owner = r.object_owner
                   and s.type  = r.object_type
                 where s.owner = ']'||ut_utils.qualified_sql_name(a_object_owner)||q'['
                   and s.type  = ']'||ut_utils.qualified_sql_name(a_object_type)||q'['
               ) x
          where x.is_annotated = 'Y'
          order by x.name, x.line]'
      using a_objects_to_refresh;

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
  end;


  procedure validate_annotation_cache(
    a_object_owner   varchar2,
    a_object_type    varchar2,
    a_modified_after timestamp := null
  ) is
    l_objects_to_refresh ut_annotation_objs_cache_info;
    l_modified_after     timestamp := a_modified_after;
  begin
    if ut_annotation_cache_manager.get_cache_schema_info(a_object_owner, a_object_type).full_refresh_time is null then
      l_modified_after := null;
    end if;

    l_objects_to_refresh := get_objects_to_refresh(a_object_owner, a_object_type, l_modified_after);

    ut_event_manager.trigger_event('validate_annotation_cache - start (l_objects_to_refresh.count = '||l_objects_to_refresh.count||')');


    if user_can_see_whole_schema( a_object_owner ) then
      --Remove non existing objects from cache only when user can see whole schema
      ut_annotation_cache_manager.remove_from_cache( get_non_existing_objects( a_object_owner, a_object_type ) );
    end if;

    --if some source needs parsing and putting into cache
    if l_objects_to_refresh.count > 0 then
      --Delete annotations for objects that are to be refreshed
      ut_annotation_cache_manager.reset_objects_cache(l_objects_to_refresh);
      --Rebuild cache from objects source
      build_annot_cache_for_sources(
        a_object_owner, a_object_type,
        get_sources_to_annotate(a_object_owner, a_object_type, l_objects_to_refresh)
      );
    end if;

    if l_modified_after is null then
      if user_can_see_whole_schema( a_object_owner ) then
        ut_annotation_cache_manager.set_fully_refreshed( a_object_owner, a_object_type );
      else
        -- if user cannot see full schema - we dont mark it as fully refreshed
        -- it will get refreshed each time until someone with proper privs will refresh it
        null;
      end if;
    end if;
    ut_event_manager.trigger_event('validate_annotation_cache - end');
  end;

  ------------------------------------------------------------
  --public definitions
  ------------------------------------------------------------
  procedure rebuild_annotation_cache(a_object_owner varchar2, a_object_type varchar2) is
  begin
    validate_annotation_cache( a_object_owner, a_object_type );
  end;

  procedure trigger_obj_annotation_rebuild is
    l_sql_text         ora_name_list_t;
    l_parts            binary_integer;
    l_restricted_users ora_name_list_t;

    function get_source_from_sql_text(a_object_name varchar2, a_sql_text ora_name_list_t, a_parts binary_integer) return sys_refcursor is
      l_sql_clob    clob;
      l_sql_lines   ut_varchar2_rows := ut_varchar2_rows();
      l_result      sys_refcursor;
    begin
      if a_parts > 0 then
        for i in 1..a_parts loop
          ut_utils.append_to_clob(l_sql_clob, a_sql_text(i));
        end loop;
        l_sql_clob := ut_utils.replace_multiline_comments(l_sql_clob);
        -- replace comment lines that contain "-- create or replace"
        l_sql_clob := regexp_replace(l_sql_clob, '^.*[-]{2,}\s*create(\s+or\s+replace).*$', modifier => 'mi');
        -- remove the "create [or replace] [[non]editionable] " so that we have only "type|package" for parsing
        -- needed for dbms_preprocessor
        l_sql_clob := regexp_replace(l_sql_clob, '^(.*?\s*create(\s+or\s+replace)?(\s+(editionable|noneditionable))?\s+?)((package|type).*)', '\5', 1, 1, 'ni');
        -- remove "OWNER." from create or replace statement.
        -- Owner is not supported along with AUTHID - see issue https://github.com/utPLSQL/utPLSQL/issues/1088
        l_sql_clob := regexp_replace(l_sql_clob, '^(package|type)\s+("?[a-zA-Z][a-zA-Z0-9#_$]*"?\.)(.*)', '\1 \3', 1, 1, 'ni');
        l_sql_lines := ut_utils.convert_collection( ut_utils.clob_to_table(l_sql_clob) );
      end if;
      open l_result for
        select /*+ no_parallel */ a_object_name as name, column_value||chr(10) as text from table(l_sql_lines);
      return l_result;
    end;

    function get_source_for_object(a_object_owner varchar2, a_object_name varchar2, a_object_type varchar2) return sys_refcursor is
      l_result       sys_refcursor;
      l_sources_view varchar2(200) := ut_metadata.get_source_view_name();
    begin
      open l_result for
        q'[select /*+ no_parallel */ :a_object_name, s.text
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
        select /*+ no_parallel */ username bulk collect into l_restricted_users
          from all_users where oracle_maintained = 'Y';
      $end
      if ora_dict_obj_owner member of l_restricted_users then
        return;
      end if;

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
        ut_annotation_cache_manager.remove_from_cache(
          ut_annotation_objs_cache_info(
            ut_annotation_obj_cache_info(ora_dict_obj_owner, ora_dict_obj_name, ora_dict_obj_type, 'Y', null)
          )
        );
      end if;
    end if;
  end;

  function get_annotated_objects(a_object_owner varchar2, a_object_type varchar2, a_modified_after timestamp) return sys_refcursor is
    l_cursor                 sys_refcursor;
  begin
    ut_event_manager.trigger_event('get_annotated_objects - start: a_modified_after='||ut_utils.to_string(a_modified_after));
    validate_annotation_cache(a_object_owner, a_object_type, a_modified_after);

    --pipe annotations from cache
    l_cursor := ut_annotation_cache_manager.get_annotations_parsed_since(a_object_owner, a_object_type, a_modified_after);
    ut_event_manager.trigger_event('get_annotated_objects - end');
    return l_cursor;
  end;

  procedure purge_cache(a_object_owner varchar2, a_object_type varchar2) is
  begin
    ut_annotation_cache_manager.purge_cache(a_object_owner, a_object_type);
  end;

end;
/
