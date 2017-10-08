create or replace package ut_annotation_cache_manager authid definer as

  procedure update_cache(a_object ut_annotated_object, a_cache_id integer);

end;
/
