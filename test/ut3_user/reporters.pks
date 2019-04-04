create or replace package reporters is

  --%suite
  --%suitepath(utplsql.test_user)

  --%beforeall
  procedure reporters_setup;

  --%afterall
  procedure reporters_cleanup;

  procedure check_xml_encoding_included(
    a_reporter             ut3.ut_output_reporter_base,
    a_client_character_set varchar2
  );

end reporters;
/
