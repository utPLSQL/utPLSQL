create or replace package body ut_annotation_manager as
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

  ------------------------------
  --private definitions

  function get_annotated_objects_cursor(a_object_owner varchar2, a_object_type varchar2, a_object_name varchar2) return sys_refcursor is
    l_result       sys_refcursor;
    l_ut_owner     varchar2(250) := ut_utils.ut_owner;
    l_objects_view varchar2(200) := ut_metadata.get_dba_view('dba_objects');
    l_cursor_text  long;
  begin
    l_cursor_text :=
      q'[select ]'||l_ut_owner||q'[.ut_annotation_cached_object(
                    object_owner => o.owner,
                    object_name => o.object_name,
                    object_type => o.object_type,
                    needs_refresh => case when o.last_ddl_time < i.parse_time then 'N' else 'Y' end,
                    cache_id => i.cache_id
                  )
           from ]'||l_objects_view||q'[ o
           left join ]'||l_ut_owner||q'[.ut_annotation_cache_info i
             on o.owner = i.object_owner and o.object_name = i.object_name and o.object_type = i.object_type
          where o.owner = :a_object_owner
            and o.object_type = :a_object_type
            and o.status = 'VALID'
            and :a_object_name ]'|| case when a_object_name is not null then '= o.object_name' else 'is null' end;
    open l_result for l_cursor_text  using a_object_owner, a_object_type, a_object_name;
    return l_result;
  end;

  function get_sources_for_annotations(a_object_owner varchar2, a_object_type varchar2, a_object_name varchar2) return sys_refcursor is
    l_result       sys_refcursor;
    l_sources_view varchar2(200) := ut_metadata.get_dba_view('dba_source');
  begin
    open l_result for
     q'[select s.name, s.text
          from ]'||l_sources_view||q'[ s
         where s.type = :a_object_type
           and s.owner = :a_object_owner
           and s.name
            in (select x.name
                  from ]'||l_sources_view||q'[ x
                 where x.type = :a_object_type
                   and x.owner = :a_object_owner
                   and x.text like '%--%\%%' escape '\'
                   and :a_object_name ]'|| case when a_object_name is not null then '= x.name' else 'is null' end || q'[
               )
          order by name, line]'
      using a_object_type, a_object_owner, a_object_type, a_object_owner, a_object_name;

    return l_result;
  end;

  function get_sources_for_annotations(a_object_owner varchar2, a_object_type varchar2, a_objects_to_refresh ut_annotation_cached_objects) return sys_refcursor is
    l_result       sys_refcursor;
    l_sources_view varchar2(200) := ut_metadata.get_dba_view('dba_source');
    l_card         natural;
  begin
    l_card := ut_utils.scale_cardinality(cardinality(a_objects_to_refresh));
    open l_result for
     q'[select /*+ cardinality( r ]'||l_card||q'[ )*/
               s.name, s.text
          from table(:a_objects_to_refresh) r
          join ]'||l_sources_view||q'[ s
            on s.name = r.object_name
         where s.type = :a_object_type
           and s.owner = :a_object_owner
           and s.name
            in (select /*+ cardinality( x ]'||l_card||q'[ )*/
                       x.name
                  from table(:a_objects_to_refresh) t
                  join ]'||l_sources_view||q'[ x
                    on x.name = t.object_name
                 where x.type = :a_object_type
                   and x.owner = :a_object_owner
                   and x.text like '%--%\%%' escape '\'
               )
          order by name, line]'
      using a_objects_to_refresh, a_object_type, a_object_owner, a_objects_to_refresh, a_object_type, a_object_owner;

    return l_result;
  end;

  ------------------------------------------------------------
  --public definitions
  ------------------------------------------------------------
  function get_annotated_objects(a_object_owner varchar2, a_object_type varchar2, a_object_name varchar2 := null) return ut_annotated_objects pipelined is
    l_info_rows           ut_annotation_cached_objects;
    l_in_cache            ut_annotation_cached_objects;
    l_to_parse            ut_annotation_cached_objects := ut_annotation_cached_objects();
    l_cursor              sys_refcursor;
    l_results             ut_annotated_objects;
    l_result              ut_annotated_object;
    c_object_fetch_limit  constant integer := 10;
    c_lines_fetch_limit   constant integer := 1000;
    l_lines               dbms_preprocessor.source_lines_t;
    l_names               dbms_preprocessor.source_lines_t;
    l_name                varchar2(250) := '''';
    l_object_lines        dbms_preprocessor.source_lines_t;
  begin
    --get information about cached objects
    l_cursor := get_annotated_objects_cursor(a_object_owner, a_object_type, a_object_name);
    fetch l_cursor bulk collect into l_info_rows;
    close l_cursor;

    --get list of objects in cache
    select value(x) bulk collect into l_in_cache from table(l_info_rows) x where x.needs_refresh = 'N';

    --if not all in cache, get list of objects to refresh
    if l_in_cache.count <= l_info_rows.count then
      select value(x) bulk collect into l_to_parse from table(l_info_rows) x where x.needs_refresh = 'Y';
    end if;

    --pipe annotations from cache
    if l_in_cache.count > 0 then
      l_cursor := ut_annotation_cache_manager.get_annotations_for_objects(l_in_cache);
      loop
        fetch l_cursor bulk collect into l_results limit c_object_fetch_limit;
        for i in 1 .. l_results.count loop
          pipe row (l_results(i));
        end loop;
        exit when l_cursor%notfound;
      end loop;
      close l_cursor;
    end if;

    --if some source needs parsing
    if l_to_parse.count > 0 then
      --do we need to parse all of sources
      if l_in_cache.count = 0 then
        l_cursor := get_sources_for_annotations(a_object_owner, a_object_type, a_object_name);
      else
        -- sources need to be filtered by objects to parse
        l_cursor := get_sources_for_annotations(a_object_owner, a_object_type, l_to_parse);
      end if;

      --remove cached annotations data for objects that will be refreshed
      ut_annotation_cache_manager.cleanup_cache(l_to_parse);

      loop
        fetch l_cursor bulk collect into l_names, l_lines limit c_lines_fetch_limit;

        for i in 1 .. l_names.count loop

          if l_names(i) != l_name then
            l_result := ut_annotated_object(
              a_object_owner, l_name, a_object_type,
              ut_annotation_parser.parse_object_annotations(l_object_lines)
            );
            ut_annotation_cache_manager.update_cache(l_result);
            if l_result.annotations.count > 0 then
              pipe row (l_result);
            end if;
            l_object_lines.delete;
          end if;

          l_name  := l_names(i);
          l_object_lines(l_object_lines.count+1) := l_lines(i);

        end loop;
        exit when l_cursor%notfound;

      end loop;

      if l_name is not null then
        l_result := ut_annotated_object(
          a_object_owner, l_name, a_object_type,
          ut_annotation_parser.parse_object_annotations(l_object_lines)
        );
        ut_annotation_cache_manager.update_cache(l_result);
        if l_result.annotations.count > 0 then
          pipe row (l_result);
        end if;
        l_object_lines.delete;
      end if;

      close l_cursor;
    end if;

  end;

end ut_annotation_manager;
/
