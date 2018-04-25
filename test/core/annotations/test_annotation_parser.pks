create or replace package test_annotation_parser is

  --%suite(ut_annotation_parser)
  --%suitepath(utplsql.core.annotations)

  --%test(Treats procedure level annotations as package level, if mixed with comments)
  procedure test_proc_comments;
  --%test(Includes floating annotations between procedures and package)
  procedure include_floating_annotations;
  --%test(Parses complex annotations on procedures and functions)
  procedure parse_complex_with_functions;
  --%test(Parses package annotations without any procedure annotations)
  procedure no_procedure_annotation;
  --%test(Parses package level annotations with Accessible by)
  procedure parse_accessible_by;
  --%test(Parses package level annotations with multiline declaration)
  procedure complex_package_declaration;
  --%test(Parses complex text in annotation)
  procedure complex_text;
  --%test(Ignores content of multi-line comments)
  procedure ignore_annotations_in_comments;

  --%test(Ignores wrapped package and does not raise exception)
  procedure ignore_wrapped_package;

  --%test(Parses package level annotations with annotation params containing brackets)
  procedure brackets_in_desc;

  --%test(Parses annotation text even with spaces before brackets)
  procedure test_space_before_annot_params;

  -- %test(Parses source-code with Windows-style newline)
  procedure test_windows_newline;

  -- %test(Parses annotations with very long object names)
  procedure test_annot_very_long_name;

end test_annotation_parser;
/
