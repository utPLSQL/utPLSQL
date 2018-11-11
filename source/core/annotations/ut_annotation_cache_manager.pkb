create or replace package body ut_annotation_cache_manager as
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

  procedure update_cache(a_object ut_annotated_object) is
    l_cache_id       integer;
    l_current_schema varchar2(250) := ut_utils.ut_owner;
    pragma autonomous_transaction;
  begin
    update ut_annotation_cache_info i
       set i.parse_time = systimestamp
     where (i.object_owner, i.object_name, i.object_type)
        in ((a_object.object_owner, a_object.object_name, a_object.object_type))
      returning cache_id into l_cache_id;
    if sql%rowcount = 0 then
      insert into ut_annotation_cache_info
             (cache_id, object_owner, object_name, object_type, parse_time)
      values (ut_annotation_cache_seq.nextval, a_object.object_owner, a_object.object_name, a_object.object_type, systimestamp)
        returning cache_id into l_cache_id;
    end if;

    delete from ut_annotation_cache c
      where cache_id = l_cache_id;

    if a_object.annotations is not null and a_object.annotations.count > 0 then
      insert into ut_annotation_cache
             (cache_id, annotation_position, annotation_name, annotation_text, subobject_name)
      select l_cache_id, a.position, a.name, a.text, a.subobject_name
        from table(a_object.annotations) a;
    end if;
    commit;
  end;


  procedure cleanup_cache(a_objects ut_annotation_objs_cache_info) is
    pragma autonomous_transaction;
  begin

    delete from ut_annotation_cache c
     where c.cache_id
        in (select i.cache_id
              from ut_annotation_cache_info i
              join table (a_objects) o
                on o.object_name = i.object_name
               and o.object_type = i.object_type
               and o.object_owner = i.object_owner
           );

    merge into ut_annotation_cache_info i
      using (select o.object_name, o.object_type, o.object_owner
               from table(a_objects) o ) o
         on (o.object_name = i.object_name
             and o.object_type = i.object_type
             and o.object_owner = i.object_owner)
     when matched then update set parse_time = systimestamp
     when not matched then insert
           (cache_id, object_owner, object_name, object_type, parse_time)
     values (ut_annotation_cache_seq.nextval, o.object_owner, o.object_name, o.object_type, systimestamp);

    commit;
  end;

  procedure remove_from_cache(a_objects ut_annotation_objs_cache_info) is
    pragma autonomous_transaction;
  begin

    delete from ut_annotation_cache_info i
      where exists (
        select 1 from table (a_objects) o
        where o.object_name = i.object_name
        and o.object_type = i.object_type
        and o.object_owner = i.object_owner
      );

    commit;
  end;

  function get_annotations_for_objects(a_cached_objects ut_annotation_objs_cache_info, a_parse_time timestamp) return sys_refcursor is
    l_results     sys_refcursor;
  begin
    open l_results for q'[
      select ut_annotated_object(
               i.object_owner, i.object_name, i.object_type, i.parse_time,
               cast(
                 collect(
                   ut_annotation(
                     c.annotation_position, c.annotation_name, c.annotation_text, c.subobject_name
                   ) order by c.annotation_position
                 ) as ut_annotations
               )
             )
        from table(:a_cached_objects) o
        join ut_annotation_cache_info i
          on o.object_owner = i.object_owner and o.object_name = i.object_name and o.object_type = i.object_type
        join ut_annotation_cache c on i.cache_id = c.cache_id
       where ]'|| case when a_parse_time is null then ':a_parse_date is null' else 'i.parse_time > :a_parse_time' end ||q'[
       group by i.object_owner, i.object_name, i.object_type, i.parse_time]'
    using a_cached_objects, a_parse_time;
    return l_results;
  end;

  procedure purge_cache(a_object_owner varchar2, a_object_type varchar2) is
    l_filter       varchar2(32767);
    l_cache_filter varchar2(32767);
    pragma autonomous_transaction;
  begin
    if a_object_owner is null and a_object_type is null then
      l_cache_filter := ':a_object_owner is null and :a_object_type is null';
      l_filter := l_cache_filter;
    else
      l_filter :=
      case when a_object_owner is null then ':a_object_owner is null' else 'object_owner = :a_object_owner' end || '
        and '||case when a_object_type is null then ':a_object_type is null' else 'object_type = :a_object_type' end;
      l_cache_filter := ' c.cache_id
           in (select i.cache_id
                 from ut_annotation_cache_info i
                where '|| l_filter || '
              )';
    end if;
    execute immediate '
      delete from ut_annotation_cache c
       where '||l_cache_filter
    using a_object_owner, a_object_type;

    execute immediate '
      delete from ut_annotation_cache_info i
       where ' || l_filter
    using a_object_owner, a_object_type;
    commit;
  end;

end ut_annotation_cache_manager;
/
