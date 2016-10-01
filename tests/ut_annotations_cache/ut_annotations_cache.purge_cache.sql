PROMPT Purges saved data for a given package
declare
  l_given  integer;
  l_actual integer;
begin
  --Arrange
  ut_annotations_cache.update_cache(user, 'UT_EXAMPLE_TESTS',
    ut_annotations.parse_package_annotations( ut_metadata.get_package_spec_source(user, 'UT_EXAMPLE_TESTS') )
  );
  ut_annotations_cache.update_cache(user, 'TEST_PKG1',
    ut_annotations.parse_package_annotations( ut_metadata.get_package_spec_source(user, 'TEST_PKG1') )
  );

  l_given := ut_annotations_cache.get_cache_data(user, 'UT_EXAMPLE_TESTS').procedure_annotations.count
    + ut_annotations_cache.get_cache_data(user, 'TEST_PKG1').procedure_annotations.count;

  if l_given = 0 then
    dbms_output.put_line('given procedure_annotations.count = '||l_given );
  else
  --Act
    ut_annotations_cache.purge_cache();
  --Assert
    l_actual := ut_annotations_cache.get_cache_data(user, 'UT_EXAMPLE_TESTS').procedure_annotations.count
      + ut_annotations_cache.get_cache_data(user, 'TEST_PKG1').procedure_annotations.count;
    if l_actual = 0 then
      :test_result := ut_utils.tr_success;
    else
      dbms_output.put_line('expected procedure_annotations.count = '||0 );
      dbms_output.put_line('actual procedure_annotations.count = '||l_actual );
    end if;
  end if;

end;
/
