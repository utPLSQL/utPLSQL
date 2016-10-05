PROMPT Returns true, when cached object is up to date with cache
declare
  l_given     integer;
  l_actual    integer;
  l_timestamp timestamp;
  l_rec    all_objects%rowtype;
begin
  --Arrange
  execute immediate 'alter package ut_example_tests compile';
  select * into l_rec from all_objects where owner = user and object_name = 'UT_EXAMPLE_TESTS' and object_type = 'PACKAGE';
  l_timestamp := systimestamp;
  ut_annotations_cache.update_cache(user, 'UT_EXAMPLE_TESTS',
    ut_annotations.parse_package_annotations( ut_metadata.get_package_spec_source(user, 'UT_EXAMPLE_TESTS') )
  );

  --Act and Assert
  if ut_annotations_cache.is_cache_valid(l_rec) then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected is_cache_valid to be true and got false');
  end if;

end;
/
