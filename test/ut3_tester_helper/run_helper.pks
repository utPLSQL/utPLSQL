create or replace package run_helper is

  procedure setup_cache_objects;
  procedure setup_cache;
  procedure cleanup_cache;
  procedure db_link_setup;
  procedure db_link_cleanup;
end;
/
