create or replace package body ut_annotation_cache_manager as

  procedure update_cache(a_object ut_annotated_object, a_cache_id integer) is
    l_is_annotated   varchar2(1);
    v_cache_id       integer := a_cache_id;
    l_current_schema varchar2(250) := ut_utils.ut_owner;
    pragma autonomous_transaction;
  begin
    if a_object.annotations is not null and a_object.annotations.count > 0 then
      l_is_annotated := 'Y';
    else
      l_is_annotated := 'N';
    end if;

    if v_cache_id is not null then
      update ut_annotation_cache_info i
         set i.parse_time = sysdate,
             i.is_annotated = l_is_annotated
       where i.cache_id = v_cache_id;
    else
      insert into ut_annotation_cache_info
             (cache_id, object_owner, object_name, object_type, parse_time, is_annotated)
      values (ut_annotation_cache_seq.nextval, a_object.object_owner, a_object.object_name, a_object.object_type, sysdate, l_is_annotated)
        returning cache_id into v_cache_id;
    end if;

    delete from ut_annotation_cache c
      where cache_id = v_cache_id;

    if l_is_annotated = 'Y' then
--       begin
      insert into ut_annotation_cache
             (cache_id, annotation_position, annotation_name, annotation_text, subobject_name)
      select v_cache_id, a.position, a.name, a.text, a.subobject_name
        from table(a_object.annotations) a;
      --TODO - duplicate annotations found?? - should not happen, getting standalone annotations need to happen after procedure annotations were parsed
--       exception
--         when others then
--           dbms_output.put_line(xmltype(anydata.convertCollection(a_object.annotations)).getclobval);
--           raise;
--       end;
    end if;
    commit;
  end;

end;
/
