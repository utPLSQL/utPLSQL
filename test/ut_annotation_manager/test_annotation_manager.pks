create or replace package test_annotation_manager is

  --%suite(ut_annotation_manager)
  --%suitepath(utplsql.core.annoations)

  --%aftereach
  procedure cleanup_annotation_cache;

  procedure create_dummy_package;

  procedure drop_dummy_package;

  procedure create_dummy_test_package;

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

  --%test(Keeps annotations in cache after object was removed)
  --%beforetest(create_dummy_test_package)
  procedure keep_dropped_data_in_cache;

  --%test(Does not return data for dropped object)
  --%beforetest(create_dummy_test_package)
  procedure no_data_for_dropped_object;

end test_annotation_manager;
/
