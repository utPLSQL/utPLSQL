create or replace package test_annotation_manager is

  --%suite(ut_annotation_manager)
  --%suitepath(utplsql.ut3_tester.core.annotations)

  --%aftereach
  procedure cleanup_annotation_cache;

  procedure disable_ddl_trigger;

  procedure enable_ddl_trigger;

  procedure create_dummy_package;

  procedure drop_dummy_package;

  procedure create_dummy_test_package;

  procedure create_parse_proc_as_ut3$user#;

  procedure drop_parse_proc_as_ut3$user#;

  procedure drop_dummy_test_package;

  --%context(With DDL trigger enabled)

    --%aftereach(drop_dummy_test_package,drop_dummy_package)

    --%test(Does not detect unit test packages created before enabling trigger)
    procedure trg_skip_existing_package;

    --%test(Adds existing package to cache when package recompiled)
    procedure trg_add_existing_on_compile;

    --%test(Adds existing package to cache when schema cache refreshed)
    procedure trg_add_existing_on_refresh;

    --%test(Doesn't add package to annotation cache info when it is not unit test package)
    procedure trg_not_add_new_package;

    --%test(Populates annotation cache when package created)
    procedure trg_add_new_test_package;

    --%test(Removes annotations from cache when object was removed and user can't see whole schema)
    --%beforetest(create_dummy_test_package)
    procedure trg_no_data_for_dropped_object;

    --%test(Updates annotation cache when package recompiled)
    procedure trg_update_modified_package;

  --%endcontext

  --%context(Without DDL trigger enabled)

    --%beforeall(disable_ddl_trigger)

    --%afterall(enable_ddl_trigger)

    --%beforeeach(create_dummy_package)
    --%aftereach(drop_dummy_package)

    --%test(Adds new package to annotation cache info when it is not unit test package)
    procedure add_new_package;

    --%test(Updates annotation cache info for modified package)
    procedure update_modified_package;

    --%test(Adds annotations to cache for unit test package)
    --%beforetest(create_dummy_test_package)
    --%aftertest(drop_dummy_test_package)
    procedure add_new_test_package;

    --%test(Updates annotations in cache for modified test package)
    procedure update_modified_test_package;

    --%test(Keeps annotations in cache when object was removed but user can't see whole schema)
    --%beforetest(create_dummy_test_package,create_parse_proc_as_ut3$user#)
    --%aftertest(drop_parse_proc_as_ut3$user#)
    procedure keep_dropped_data_in_cache;

    --%test(Does not return data for dropped object)
    procedure no_data_for_dropped_object;

    --%test(Remove object from cache when object dropped and user can see whole schema)
    procedure cleanup_dropped_data_in_cache;

  --%endcontext

end test_annotation_manager;
/
