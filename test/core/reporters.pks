create or replace package reporters is

  procedure reporters_setup;

  procedure reporters_cleanup;

  procedure check_xml_encoding_included(
    a_suite                varchar2,
    a_reporter             ut3.ut_output_reporter_base,
    a_client_character_set varchar2
  );

end reporters;
/
