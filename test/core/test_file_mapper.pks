create or replace package test_file_mapper is

  --%suite(file_mapper)
  --%suitepath(utplsql.core)

  --%test(Maps file paths into database objects using default mappings)
  procedure default_mappings;

  --%test(Used specified object owner to perform mapping when files have no owner indication)
  procedure specific_owner;

end;
/
