create or replace package test_annotation_cache_manager is

  --%suite(ut_annotation_cache_manager)
  --%suitepath(utplsql.core.annoations)


  --%beforeeach
  procedure setup_cache;

  --%aftereach
  procedure cleanup_cache;

  --%test(Purges cache for a given schema and object type)
  procedure test_purge_schema_type;

end test_annotation_cache_manager;
/
