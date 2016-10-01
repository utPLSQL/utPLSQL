create or replace package body ut_annotations_cache as

  ------------------------------
  --private definitions

  type annotation_cache_typ is record(
    procedure_name ut_annotation_procedure_cache.procedure_name%type,
    name           ut_annotation_procedure_cache.annotation_name%type,
    param_pos      ut_annotation_procedure_cache.annotation_param_pos%type,
    param_key      ut_annotation_procedure_cache.annotation_param_key%type,
    param_value    ut_annotation_procedure_cache.annotation_param_value%type
  );

  type tt_annotations_cache is table of annotation_cache_typ;

  function to_package_annotations(a_annotations tt_annotations_cache) return tt_annotations is
    l_result                 tt_annotations;
    l_annotation_params      tt_annotation_params;
    l_null_annotation_params tt_annotation_params;
  begin
    for i in 1 .. a_annotations.count loop
      if a_annotations(i).param_pos is not null then
         l_annotation_params(a_annotations(i).param_pos).key := a_annotations(i).param_key;
         l_annotation_params(a_annotations(i).param_pos).value := a_annotations(i).param_value;
      end if;
      if i = a_annotations.count or a_annotations(i).name != a_annotations(i+1).name then
        l_result(a_annotations(i).name) := l_annotation_params;
        l_annotation_params := l_null_annotation_params;
      end if;
    end loop;
    return l_result;
  end;

  function to_procedure_annotations(a_annotations tt_annotations_cache) return tt_procedure_annotations is
    l_result                 tt_procedure_annotations;
    l_annotations            tt_annotations;
    l_null_annotations       tt_annotations;
    l_annotation_params      tt_annotation_params;
    l_null_annotation_params tt_annotation_params;
  begin
    for i in 1 .. a_annotations.count loop
      if a_annotations(i).param_pos is not null then
         l_annotation_params(a_annotations(i).param_pos).key := a_annotations(i).param_key;
         l_annotation_params(a_annotations(i).param_pos).value := a_annotations(i).param_value;
      end if;
      if i = a_annotations.count or a_annotations(i).name != a_annotations(i+1).name then
        l_annotations(a_annotations(i).name) := l_annotation_params;
        l_annotation_params := l_null_annotation_params;
      end if;
      if i = a_annotations.count or a_annotations(i).procedure_name != a_annotations(i+1).procedure_name then
        l_result(a_annotations(i).procedure_name) := l_annotations;
        l_annotations := l_null_annotations;
      end if;
    end loop;
    return l_result;
  end;

  function to_annotation_tab(a_annotations tt_annotations, a_procedure_name varchar2 := null) return tt_annotations_cache is
    l_name t_annotation_name := a_annotations.first;
    l_result tt_annotations_cache := tt_annotations_cache();
  begin
    while l_name is not null loop
      l_result.extend;
      l_result(l_result.last).procedure_name := a_procedure_name;
      l_result(l_result.last).name := l_name;
      for j in 1 .. a_annotations(l_name).count loop
        l_result(l_result.last).param_pos := j;
        l_result(l_result.last).param_key := a_annotations(l_name)(j).key;
        l_result(l_result.last).param_value := a_annotations(l_name)(j).value;
      end loop;
      l_name := a_annotations.next(l_name);
    end loop;
    return l_result;
  end;

  function to_annotation_tab(a_procedure_annotations tt_procedure_annotations) return tt_annotations_cache is
    l_proc_name t_procedure_name  := a_procedure_annotations.first;
    l_result tt_annotations_cache := tt_annotations_cache();
  begin
    --convert procedure annotations into flat table
    while l_proc_name is not null loop
      l_result := l_result multiset union all to_annotation_tab(a_procedure_annotations(l_proc_name), l_proc_name);
      l_proc_name := a_procedure_annotations.next(l_proc_name);
    end loop;
    return l_result;
  end;

  procedure save_cache_data(a_owner_name varchar2, a_package_name varchar2, a_package_annotations tt_annotations_cache, a_procedure_annotations tt_annotations_cache) is
    pragma autonomous_transaction;
  begin
    if a_package_annotations.count > 0 or a_procedure_annotations.count > 0 then

       insert into ut_annotation_package_info dst
              (owner, package_name, parse_timestamp)
       values (a_owner_name, a_package_name, systimestamp);

       forall i in 1 .. a_package_annotations.count
         insert into ut_annotation_package_cache dst(
            owner, package_name, annotation_name,
            annotation_param_pos, annotation_param_key, annotation_param_value
         )
         values(
            a_owner_name, a_package_name, a_package_annotations(i).name,
            a_package_annotations(i).param_pos, a_package_annotations(i).param_key,
            a_package_annotations(i).param_value
         );


       forall i in 1 .. a_procedure_annotations.count
         insert into ut_annotation_procedure_cache dst(
            owner, package_name,
            procedure_name, annotation_name,
            annotation_param_pos, annotation_param_key,
            annotation_param_value
         )
         values(
            a_owner_name, a_package_name,
            a_procedure_annotations(i).procedure_name, a_procedure_annotations(i).name,
            a_procedure_annotations(i).param_pos, a_procedure_annotations(i).param_key,
            a_procedure_annotations(i).param_value
         );
    end if;

    commit;
  end;

  ------------------------------
  --public definitions

  procedure purge_cache(a_owner_name varchar2, a_package_name varchar2) is
    pragma autonomous_transaction;
  begin
    --flush annotations from tables (cascade delete by constraint)
    delete from ut_annotation_package_info dst
      where dst.owner = a_owner_name
        and dst.package_name = a_package_name;
    commit;
  end;

  procedure purge_cache(a_number_of_days number) is
    pragma autonomous_transaction;
  begin
    --flush annotations from tables (cascade delete by constraint)
    delete from ut_annotation_package_info dst
     where dst.parse_timestamp < (sysdate - a_number_of_days);
    commit;
  end;

  procedure purge_cache is
    pragma autonomous_transaction;
  begin
    --flush annotations from tables (cascade delete by constraint)
    delete from ut_annotation_package_info dst;
    commit;
  end;

  function get_cache_data(a_owner_name varchar2, a_package_name varchar2) return typ_annotated_package is
    l_result                typ_annotated_package;
    l_package_annotations   tt_annotations_cache;
    l_procedure_annotations tt_annotations_cache;
  begin
    --data needs to be sorted on retrieval to simplify conversion between array types
    select null, src.annotation_name, src.annotation_param_pos,
           src.annotation_param_key, src.annotation_param_value
      bulk collect into l_package_annotations
      from ut_annotation_package_cache src
     where src.owner = a_owner_name
        and src.package_name = a_package_name
     order by src.annotation_name, src.annotation_param_pos;

    --data needs to be sorted on retrieval to simplify conversion between array types
    select src.procedure_name, src.annotation_name, src.annotation_param_pos,
           src.annotation_param_key, src.annotation_param_value
      bulk collect into l_procedure_annotations
      from ut_annotation_procedure_cache src
     where src.owner = a_owner_name
        and src.package_name = a_package_name
     order by src.procedure_name, src.annotation_name, src.annotation_param_pos;

     l_result.package_annotations   := to_package_annotations(l_package_annotations);
     l_result.procedure_annotations := to_procedure_annotations(l_procedure_annotations);
    return l_result;
  end;

  procedure update_cache(a_owner_name varchar2, a_package_name varchar2, a_annotated_pkg typ_annotated_package) is
    l_package_annotations   tt_annotations_cache;
    l_procedure_annotations tt_annotations_cache;
  begin
    --convert package annotations into flat table
    l_package_annotations := to_annotation_tab(a_annotated_pkg.package_annotations);

    --convert procedure annotations into flat table
    l_procedure_annotations := to_annotation_tab(a_annotated_pkg.procedure_annotations);

    purge_cache(a_owner_name, a_package_name);

    save_cache_data(a_owner_name, a_package_name, l_package_annotations, l_procedure_annotations);

  end;

  function is_cache_valid(a_owner_name varchar2, a_package_name varchar2) return boolean is
    l_result integer;
  begin
    select count(1)
      into l_result
      from ut_annotation_package_info a
      join all_objects o
        on o.owner = a.owner
        and o.object_name = a.package_name
      where o.object_type = 'PACKAGE'
        and a.parse_timestamp > o.last_ddl_time
        and a.owner = a_owner_name
        and a.package_name = a_package_name
        and rownum = 1;
    return l_result > 0;
  end;

  function get_package_annotations(a_owner_name varchar2, a_package_name varchar2) return typ_annotated_package is
    l_result typ_annotated_package;
  begin
    if is_cache_valid(a_owner_name, a_package_name) then
      l_result := get_cache_data(a_owner_name, a_package_name);
    else
      l_result := ut_annotations.get_package_annotations(a_owner_name, a_package_name);
      update_cache(a_owner_name, a_package_name, l_result);
    end if;
    return l_result;
  end;

--run garbage collecting when package firts accessed
begin
  purge_cache(gc_purge_after_days);
end;
/
