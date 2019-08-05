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

    --%disabled(TODO)
    --%test(Objects are populated on scan after cache was purged)
    procedure trg_populate_cache_after_purge;

  --%endcontext

  --%context(Without DDL trigger)

    --%beforeall(disable_ddl_trigger)

    --%afterall(enable_ddl_trigger)

    --%beforeeach(create_dummy_package)
    --%aftereach(drop_dummy_package)

    --%test(Returns annotations when annotated package was created)
    --%aftertest(drop_dummy_test_package)
    procedure add_annotated_package;

    --%test(Doesn't return annotations when annotated package was removed)
    --%aftertest(drop_dummy_test_package)
    procedure remove_annotated_package;

    --%test(Doesn't return annotations when package doesn't contain annotations)
    --%aftertest(drop_dummy_package)
    procedure add_not_annotated_package;

    --%test(Doesn't return annotations when package without annotations was dropped)
    --%aftertest(drop_dummy_package)
    procedure remove_not_annotated_package;

    --%test(Doesn't return annotations when annotations removed from package)
    --%aftertest(drop_dummy_test_package)
    procedure remove_annotations_from_pkg;

    --%test(Returns annotations when annotations were added to package)
    --%aftertest(drop_dummy_test_package)
    procedure add_annotations_to_package;

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

    --%test(Objects are populated on scan after cache was purged)
    procedure populate_cache_after_purge;

  --%endcontext

end test_annotation_manager;
/
