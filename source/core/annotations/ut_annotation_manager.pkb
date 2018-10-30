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

  function get_annotation_objs_info(a_object_owner varchar2, a_object_type varchar2, a_parse_date date := null) return ut_annotation_objs_cache_info is
    l_rows         sys_refcursor;
    l_ut_owner     varchar2(250) := ut_utils.ut_owner;
    l_objects_view varchar2(200) := ut_metadata.get_dba_view('dba_objects');
    l_cursor_text  varchar2(32767);
    l_result       ut_annotation_objs_cache_info;
  begin
    l_cursor_text :=
      q'[select ]'||l_ut_owner||q'[.ut_annotation_obj_cache_info(
                    object_owner => o.owner,
                    object_name => o.object_name,
                    object_type => o.object_type,
                    needs_refresh => case when o.last_ddl_time < i.parse_time then 'N' else 'Y' end
                  )
           from ]'||l_objects_view||q'[ o
           left join ]'||l_ut_owner||q'[.ut_annotation_cache_info i
             on o.owner = i.object_owner
            and o.object_name = i.object_name
            and o.object_type = i.object_type
          where o.owner = :a_object_owner
            and o.object_type = :a_object_type
            and ]'
      || case
           when a_parse_date is null
           then ':a_parse_date is null'
           else 'o.last_ddl_time > :a_parse_date'
         end;
    open l_rows for l_cursor_text  using a_object_owner, a_object_type, a_parse_date;
    fetch l_rows bulk collect into l_result limit 1000000;
    close l_rows;
    return l_result;
  end;

  function get_sources_to_annotate(a_object_owner varchar2, a_object_type varchar2) return sys_refcursor is
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
               )
          order by name, line]'
      using a_object_type, a_object_owner, a_object_type, a_object_owner;

    return l_result;
  end;

  function get_sources_to_annotate(a_object_owner varchar2, a_object_type varchar2, a_objects_to_refresh ut_annotation_objs_cache_info) return sys_refcursor is
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
            in (select /*+ cardinality( t ]'||l_card||q'[ )*/
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

  procedure build_annot_cache_for_sources(
    a_object_owner varchar2, a_object_type varchar2, a_sources_cursor sys_refcursor,
    a_schema_objects ut_annotation_objs_cache_info
  ) is
    l_annotations         ut_annotations;
    c_lines_fetch_limit   constant integer := 1000;
    l_lines               dbms_preprocessor.source_lines_t;
    l_names               dbms_preprocessor.source_lines_t;
    l_name                varchar2(250);
    l_object_lines        dbms_preprocessor.source_lines_t;
    l_parse_time          date := sysdate;
    pragma autonomous_transaction;
  begin
    ut_annotation_cache_manager.cleanup_cache(a_schema_objects);
    loop
      fetch a_sources_cursor bulk collect into l_names, l_lines limit c_lines_fetch_limit;
      for i in 1 .. l_names.count loop
        if l_names(i) != l_name then
          l_annotations := ut_annotation_parser.parse_object_annotations(l_object_lines);
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
      l_annotations := ut_annotation_parser.parse_object_annotations(l_object_lines);
      ut_annotation_cache_manager.update_cache(
        ut_annotated_object(a_object_owner, l_name, a_object_type, l_parse_time, l_annotations)
      );
      l_object_lines.delete;
    end if;
    close a_sources_cursor;
    commit;
  end;


  procedure rebuild_annotation_cache( a_object_owner varchar2, a_object_type varchar2, a_info_rows ut_annotation_objs_cache_info) is
    l_objects_in_cache_count integer;
    l_objects_to_parse       ut_annotation_objs_cache_info := ut_annotation_objs_cache_info();
  begin
    --get list of objects in cache
    select count(1) into l_objects_in_cache_count
      from table(a_info_rows) x where x.needs_refresh = 'N';

    --if cache is empty and there are objects to parse
    if l_objects_in_cache_count = 0 and a_info_rows.count > 0 then

      build_annot_cache_for_sources(
        a_object_owner, a_object_type,
        --all schema objects
        get_sources_to_annotate(a_object_owner, a_object_type),
        a_info_rows
      );

    --if not all in cache, get list of objects to rebuild cache for
    elsif l_objects_in_cache_count < a_info_rows.count then

      select value(x)bulk collect into l_objects_to_parse from table(a_info_rows) x where x.needs_refresh = 'Y';

      --if some source needs parsing and putting into cache
      if l_objects_to_parse.count > 0 then
        build_annot_cache_for_sources(
          a_object_owner, a_object_type,
          get_sources_to_annotate(a_object_owner, a_object_type, l_objects_to_parse),
          l_objects_to_parse
        );
      end if;

    end if;
  end;

  ------------------------------------------------------------
  --public definitions
  ------------------------------------------------------------
  procedure rebuild_annotation_cache(a_object_owner varchar2, a_object_type varchar2) is
  begin
    rebuild_annotation_cache(
      a_object_owner,
      a_object_type,
      get_annotation_objs_info(a_object_owner, a_object_type, null)
    );
  end;

  function get_annotated_objects(a_object_owner varchar2, a_object_type varchar2, a_parse_date date := null) return ut_annotated_objects pipelined is
    l_info_rows              ut_annotation_objs_cache_info;
    l_cursor                 sys_refcursor;
    l_results                ut_annotated_objects;
    c_object_fetch_limit  constant integer := 10;
  begin

    l_info_rows := get_annotation_objs_info(a_object_owner, a_object_type, a_parse_date);
    rebuild_annotation_cache(a_object_owner, a_object_type, l_info_rows);

    --pipe annotations from cache
    l_cursor := ut_annotation_cache_manager.get_annotations_for_objects(l_info_rows, a_parse_date);
    loop
      fetch l_cursor bulk collect into l_results limit c_object_fetch_limit;
      for i in 1 .. l_results.count loop
        pipe row (l_results(i));
      end loop;
      exit when l_cursor%notfound;
    end loop;
    close l_cursor;
  end;

  procedure purge_cache(a_object_owner varchar2, a_object_type varchar2) is
  begin
    ut_annotation_cache_manager.purge_cache(a_object_owner, a_object_type);
  end;

end ut_annotation_manager;
/
