create or replace package body ut_annotations_cache as

  pragma serially_reusable;
  ------------------------------
  --private definitions

  type annotation_cache_typ is record(
    procedure_name ut_annotation_package_cache.procedure_name%type,
    name           ut_annotation_package_cache.annotation_name%type,
    param_pos      ut_annotation_package_cache.annotation_param_pos%type,
    param_key      ut_annotation_package_cache.annotation_param_key%type,
    param_value    ut_annotation_package_cache.annotation_param_value%type
  );

  type tt_annotations_cache is table of annotation_cache_typ;

  type cache_info_rec is record(
    is_annotated ut_annotation_package_info.is_annotated%type,
    parse_timestamp ut_annotation_package_info.parse_timestamp%type
  );
  type tt_cache_info is table of cache_info_rec index by varchar2(257);

  g_cache_info tt_cache_info;

  function to_package_annotations(a_annotations_cache tt_annotations_cache) return typ_annotated_package is
    l_procedure_annotations  tt_procedure_annotations;
    l_annotations            tt_annotations;
    l_null_annotations       tt_annotations;
    l_annotation_params      tt_annotation_params;
    l_null_annotation_params tt_annotation_params;
    l_result                 typ_annotated_package;
  begin
    for i in 1 .. a_annotations_cache.count loop
      if a_annotations_cache(i).param_pos is not null then
         l_annotation_params(a_annotations_cache(i).param_pos).key := a_annotations_cache(i).param_key;
         l_annotation_params(a_annotations_cache(i).param_pos).value := a_annotations_cache(i).param_value;
      end if;
      if i = a_annotations_cache.count or a_annotations_cache(i).name != a_annotations_cache(i+1).name then
        l_annotations(a_annotations_cache(i).name) := l_annotation_params;
        l_annotation_params := l_null_annotation_params;
      end if;
      if i = a_annotations_cache.count or
        nvl(a_annotations_cache(i).procedure_name,'null') != nvl(a_annotations_cache(i+1).procedure_name,'null') then
        if a_annotations_cache(i).procedure_name is null then
          l_result.package_annotations := l_annotations;
        else
          l_result.procedure_annotations(a_annotations_cache(i).procedure_name) := l_annotations;
        end if;
        l_annotations := l_null_annotations;
      end if;
    end loop;
    return l_result;
  end;

  function to_annotation_cache(a_annotated_pkg typ_annotated_package) return tt_annotations_cache is
    l_proc_name t_procedure_name;
    l_result tt_annotations_cache;

    function to_annotation_cache_tab(a_annotations tt_annotations, a_procedure_name varchar2 := null) return tt_annotations_cache is
      l_name t_annotation_name := a_annotations.first;
      l_result tt_annotations_cache := tt_annotations_cache();
    begin
      while l_name is not null loop
        l_result.extend;
        l_result(l_result.last).procedure_name := a_procedure_name;
        l_result(l_result.last).name := l_name;
        for j in 1 .. a_annotations(l_name).count loop
          if j > 1 then
            l_result.extend;
            l_result(l_result.last).procedure_name := a_procedure_name;
            l_result(l_result.last).name := l_name;
          end if;
          l_result(l_result.last).param_pos := j;
          l_result(l_result.last).param_key := a_annotations(l_name)(j).key;
          l_result(l_result.last).param_value := a_annotations(l_name)(j).value;
        end loop;
        l_name := a_annotations.next(l_name);
      end loop;
      return l_result;
    end;
  begin
    l_result := to_annotation_cache_tab(a_annotated_pkg.package_annotations);
    --convert procedure annotations into flat table
    l_proc_name := a_annotated_pkg.procedure_annotations.first;
    while l_proc_name is not null loop
      l_result := l_result multiset union all to_annotation_cache_tab(a_annotated_pkg.procedure_annotations(l_proc_name), l_proc_name);
      l_proc_name := a_annotated_pkg.procedure_annotations.next(l_proc_name);
    end loop;
    return l_result;
  end;

  procedure refresh_cache_info is
    type cache_info_data_rec is record(name varchar2(257), is_annotated varchar2(1), parse_timestamp timestamp);
    type tt_cache_info_data is table of cache_info_data_rec;
    l_cache_info tt_cache_info_data;
  begin
    g_cache_info.delete();

    select owner||'.'||package_name, is_annotated, parse_timestamp
      bulk collect into l_cache_info
      from ut_annotation_package_info;
    for i in 1 .. l_cache_info.count loop
      g_cache_info(l_cache_info(i).name).is_annotated := l_cache_info(i).is_annotated;
      g_cache_info(l_cache_info(i).name).parse_timestamp := l_cache_info(i).parse_timestamp;
     end loop;
  end;

  procedure save_cache_data(a_owner_name varchar2, a_package_name varchar2, a_annotations_cache tt_annotations_cache) is
    pragma autonomous_transaction;
    l_is_annotated ut_annotation_package_info.is_annotated%type;
    l_timestamp timestamp :=  current_timestamp;
  begin
    l_is_annotated :=
      case when a_annotations_cache.count > 0 or a_annotations_cache.count > 0 then 'Y' else 'N' end;

    insert into ut_annotation_package_info dst
           (owner, package_name, parse_timestamp, is_annotated)
    values (a_owner_name, a_package_name, l_timestamp, l_is_annotated);
    g_cache_info(a_owner_name||'.'||a_package_name).is_annotated := l_is_annotated;
    g_cache_info(a_owner_name||'.'||a_package_name).parse_timestamp := l_timestamp;
    if l_is_annotated = 'Y' then

      forall i in 1 .. a_annotations_cache.count
        insert into ut_annotation_package_cache dst(
           owner, package_name, procedure_name,
           annotation_name, annotation_param_pos,
           annotation_param_key, annotation_param_value,
           not_null_procedure_name, not_null_annotation_param_pos
        )
        values(
           a_owner_name, a_package_name, a_annotations_cache(i).procedure_name,
           a_annotations_cache(i).name, a_annotations_cache(i).param_pos,
           a_annotations_cache(i).param_key, a_annotations_cache(i).param_value,
           nvl(a_annotations_cache(i).procedure_name, 'null'), nvl(a_annotations_cache(i).param_pos, 0)
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
    refresh_cache_info();
  end;

  procedure purge_cache(a_number_of_days number) is
    pragma autonomous_transaction;
  begin
    --flush annotations from tables (cascade delete by constraint)
    delete from ut_annotation_package_info dst
     where dst.parse_timestamp < (sysdate - a_number_of_days);
    commit;
    refresh_cache_info();
  end;

  procedure purge_cache is
    pragma autonomous_transaction;
  begin
    --flush annotations from tables (cascade delete by constraint)
    delete from ut_annotation_package_info dst;
    commit;
    refresh_cache_info();
  end;

  function get_cache_data(a_owner_name varchar2, a_package_name varchar2) return typ_annotated_package is
    l_package_annotations tt_annotations_cache;
    l_key varchar2(257) := a_owner_name||'.'||a_package_name;
  begin
    if g_cache_info.exists(l_key) and g_cache_info(l_key).is_annotated = 'Y' then
      --data needs to be sorted on retrieval to simplify conversion between array types
      select src.procedure_name, src.annotation_name, src.annotation_param_pos,
             src.annotation_param_key, src.annotation_param_value
        bulk collect into l_package_annotations
        from ut_annotation_package_cache src
       where src.owner = a_owner_name
          and src.package_name = a_package_name
       --filtering and sorting is done by PK of Index Organized table to improve read performance
       order by src.not_null_procedure_name, src.annotation_name, src.not_null_annotation_param_pos;

      return to_package_annotations(l_package_annotations);
    else
      return null;
    end if;
  end;

  procedure update_cache(a_owner_name varchar2, a_package_name varchar2, a_annotated_pkg typ_annotated_package) is
  begin
    purge_cache(a_owner_name, a_package_name);

    --convert package annotations into flat table and save it
    save_cache_data(a_owner_name, a_package_name, to_annotation_cache(a_annotated_pkg));

  end;

  function is_cache_valid(a_rec all_objects%rowtype) return boolean is
    l_result integer;
    l_key varchar2(257) := a_rec.owner||'.'||a_rec.object_name;
  begin
    return g_cache_info.exists(l_key) and g_cache_info(l_key).parse_timestamp > a_rec.last_ddl_time;
  end;

--run garbage collecting when package firts accessed
begin
  purge_cache(gc_purge_after_days);
end;
/
