PROMPT Returns false, when cached object was recompiled after caching
declare
  l_given  integer;
  l_actual integer;
  l_date   date;
  l_rec    all_objects%rowtype;
begin
  --Arrange
  ut_annotations_cache.update_cache(user, 'UT_EXAMPLE_TESTS',
    ut_annotations.parse_package_annotations( ut_metadata.get_package_spec_source(user, 'UT_EXAMPLE_TESTS') )
  );
  --wait for second to flip to next
  l_date := sysdate;
  while sysdate = l_date loop null; end loop;
  execute immediate 'alter package ut_example_tests compile';
  select * into l_rec from all_objects where owner = user and object_name = 'UT_EXAMPLE_TESTS' and object_type = 'PACKAGE';

  --Act and Assert
  if not ut_annotations_cache.is_cache_valid(l_rec) then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected is_cache_valid to be true and got false');
  end if;

end;
/
