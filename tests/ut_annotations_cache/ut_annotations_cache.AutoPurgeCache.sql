PROMPT Automatically purges saved cache data when package called for the first time in session
declare
  l_given  ut_annotations.typ_annotated_package;
begin
  --Arrange
  ut_annotations_cache.update_cache(user, 'UT_EXAMPLE_TESTS',
    ut_annotations.parse_package_annotations( ut_metadata.get_package_spec_source(user, 'UT_EXAMPLE_TESTS') )
  );

  l_given := ut_annotations_cache.get_cache_data(user, 'UT_EXAMPLE_TESTS');
  if l_given.procedure_annotations.count = 0 then
    dbms_output.put_line('l_given.procedure_annotations.count = '||l_given.procedure_annotations.count );
  else
    --set the package cache to be stale
    update ut_annotation_package_info
       set parse_timestamp = sysdate - 6;
    commit;
    --reset cache session state to force auto-purge
  end if;
end;
/

alter package ut_annotations_cache compile body;

declare
  l_actual ut_annotations.typ_annotated_package;
begin
  --Act
  --Assert
  l_actual := ut_annotations_cache.get_cache_data(user, 'UT_EXAMPLE_TESTS');
  if l_actual.procedure_annotations.count = 0 then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected procedure_annotations.count = '||0 );
    dbms_output.put_line('actual procedure_annotations.count = '||l_actual.procedure_annotations.count );
  end if;
end;
/
