create or replace package test_annotation_manager is

  --%suite(ut_annotation_manager)
  --%suitepath(utplsql.core.annotations)

  --%aftereach
  procedure cleanup_annotation_cache;

  procedure create_dummy_package;

  procedure drop_dummy_package;

  procedure create_dummy_test_package;

  procedure create_parse_proc_as_ut3$user#;

  procedure drop_parse_proc_as_ut3$user#;

  procedure drop_dummy_test_package;

  --%test(Adds new package to annotation cache info)
  --%beforetest(create_dummy_package)
  --%aftertest(drop_dummy_package)
  procedure add_new_package;

  --%test(Updates annotation cache info for modified package)
  --%beforetest(create_dummy_package)
  --%aftertest(drop_dummy_package)
  procedure update_modified_package;

  --%test(Adds annotations to cache for unit test package)
  --%beforetest(create_dummy_test_package)
  --%aftertest(drop_dummy_test_package)
  procedure add_new_test_package;

  --%test(Updates annotations in cache for modified test package)
  --%beforetest(create_dummy_test_package)
  --%aftertest(drop_dummy_test_package)
  procedure update_modified_test_package;

  --%test(Keeps annotations in cache when object was removed but user can't see whole schema)
  --%beforetest(create_dummy_test_package,create_parse_proc_as_ut3$user#)
  --%aftertest(drop_parse_proc_as_ut3$user#)
  procedure keep_dropped_data_in_cache;

  --%test(Does not return data for dropped object)
  --%beforetest(create_dummy_test_package)
  procedure no_data_for_dropped_object;

  --%test(Remove object from cache when object dropped and user can see whole schema)
  --%beforetest(create_dummy_test_package)
  procedure cleanup_dropped_data_in_cache;

end test_annotation_manager;
/
