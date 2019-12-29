create or replace package test_suite_builder is
  --%suite(suite_builder)
  --%suitepath(utplsql.ut3_tester.core)

  --%context(--%suite annotation)
    --%name(suite)

      --%test(Sets suite name from package name and leaves description empty)
      procedure no_suite_description;

      --%test(Sets suite description using first --%suite annotation)
      procedure suite_description_from_suite;

      --%test(Gives warning if more than one --%suite annotation used)
      procedure suite_annot_duplicated;

  --%endcontext

  --%context(--%displayname annotation)

      --%test(Overrides suite description using first --%displayname annotation)
      procedure suite_descr_from_displayname;

      --%test(Gives warning if more than one --%displayname annotation used)
      procedure displayname_annot_duplicated;

      --%test(Gives warning if --%displayname annotation has no value)
      procedure displayname_annot_empty;

  --%endcontext

  --%context(--%test annotation)

      --%test(Creates a test item for procedure annotated with --%test annotation)
      procedure test_annotation;

      --%test(Gives warning if more than one --%test annotation used)
      procedure test_annot_duplicated;

      --%test(Is added to suite according to annotation order in package spec)
      procedure test_annotation_ordering;

  --%endcontext

  --%context(--%suitepath annotation)

      --%test(Sets suite path using first --%suitepath annotation)
      procedure suitepath_from_non_empty_path;

      --%test(Gives warning if more than one --%suitepath annotation used)
      procedure suitepath_annot_duplicated;

      --%test(Gives warning if --%suitepath annotation has no value)
      procedure suitepath_annot_empty;

      --%test(Gives warning if --%suitepath annotation has invalid value)
      procedure suitepath_annot_invalid_path;

  --%endcontext

  --%context--%rollback annotation)

      --%test(Sets rollback type using first --%rollback annotation)
      procedure rollback_type_valid;

      --%test(Gives warning if more than one --%rollback annotation used)
      procedure rollback_type_duplicated;

      --%test(Gives warning if --%rollback annotation has no value)
      procedure rollback_type_empty;

      --%test(Gives warning if --%rollback annotation has invalid value)
      procedure rollback_type_invalid;

  --%endcontext

  --%context(--%before/after all/each annotations)

      --%test(Supports multiple before/after all/each procedure level definitions)
      procedure multiple_before_after;

      --%test(Supports multiple before/after all/each standalone level definitions)
      procedure multiple_standalone_bef_aft;

      --%test(Supports mixing before/after all/each annotations on single procedure)
      procedure before_after_on_single_proc;

      --%test(Supports mixed before/after all/each as standalone and procedure level definitions)
      procedure multiple_mixed_bef_aft;

      --%test(Gives warning if more than one --%beforeall annotation used on procedure)
      procedure beforeall_annot_duplicated;

      --%test(Gives warning if more than one --%beforeeach annotation used on procedure)
      procedure beforeeach_annot_duplicated;

      --%test(Gives warning if more than one --%afterall annotation used on procedure)
      procedure afterall_annot_duplicated;

      --%test(Gives warning if more than one --%aftereach annotation used on procedure)
      procedure aftereach_annot_duplicated;

      --%test(Gives warning on before/after all/each annotations mixed with test)
      procedure before_after_mixed_with_test;

  --%endcontext

  --%context(--%context annotation)
    --%name(context)

    --%test(Creates nested suite for content between context/endcontext annotations)
    procedure suite_from_context;

    --%test(Creates nested contexts inside a context)
    procedure nested_contexts;

    --%test(Creates multiple nested contexts inside a context)
    procedure nested_contexts_2;

    --%test(Associates before/after all/each to tests in context only)
    procedure before_after_in_context;

    --%test(Propagates beforeeach/aftereach to context)
    procedure before_after_out_of_context;

    --%test(Gives warning when endcontext is missing)
    procedure context_without_endcontext;

    --%test(Gives warning if --%endcontext is missing a preceding --%context)
    procedure endcontext_without_context;

    --%test(Gives warning when two contexts have the same name and falls back to default context name)
    procedure duplicate_context_name;

  --%endcontext

  --%context(--%name annotation)

    --%test(Falls back to default context name and gives warning when context name contains "." character)
    procedure hard_stop_in_ctx_name;

    --%test(Falls back to default context name and gives warning when name contains spaces)
    procedure name_with_spaces_invalid;

    --%test(Raises warning when more than one name annotation used )
    procedure duplicate_name_annotation;

    --%test(Is ignored when used outside of context - no warning given)
    procedure name_outside_of_context;

    --%test(Is ignored when name value is empty)
    procedure name_empty_value;

    --%test(Is is applied to corresponding context when multiple contexts used)
    procedure multiple_contexts;

  --%endcontext

  --%context(--%throws annotation)

      --%test(Gives warning if --%throws annotation has no value)
      procedure throws_value_empty;

  --%endcontext

  --%context(--%beforetest/aftertest annotation)

      --%test(Supports multiple occurrences of beforetest/aftertest for a test)
      procedure before_aftertest_multi;

      --%test(Supports same procedure defined twice)
      procedure before_aftertest_twice;

      --%test(Supports beforetest from external package)
      procedure before_aftertest_pkg_proc;

      --%test(Supports mix of procedure and package.procedure)
      procedure before_aftertest_mixed_syntax;

  --%endcontext

  --%context(--%bad_annotation)

      --%test(Gives warning when unknown procedure level annotation passed)
      procedure test_bad_procedure_annotation;

      --%test(Gives warning when unknown package level annotation passed)
      procedure test_bad_package_annotation;

  --%endcontext

  --%context(--%tag_annotation)
  
      --%test(Build suite test with tag)
      procedure test_tag_annotation;

      --%test(Build suite with tag)
      procedure suite_tag_annotation;

      --%test(Build suite test with three tags)
      procedure test_tags_annotation;

      --%test(Build suite with three tags)
      procedure suite_tags_annotation;

      --%test(Build suite test with two line tag annotation)
      procedure test_2line_tags_annotation;

      --%test(Build suite with two line tag annotation)
      procedure suite_2line_tags_annotation;

      --%test(Build suite test with empty line tag annotation)
      procedure test_empty_tag;

      --%test(Build suite with empty line tag annotation)
      procedure suite_empty_tag;

      --%test(Build suite test with duplicate tag annotation)
      procedure test_duplicate_tag;

      --%test(Build suite with duplicate tag annotation)
      procedure suite_duplicate_tag;

      --%test(Build suite test with empty between tag annotation)
      procedure test_empty_tag_between;

      --%test(Build suite with empty between tag annotation)
      procedure suite_empty_tag_between;

      --%test(Build suite test with special char tag annotation)
      procedure test_special_char_tag;

      --%test(Build suite with special char tag annotation)
      procedure suite_special_char_tag;

      --%test(Raise warning and ignore tag with spaces in tag name)
      procedure test_spaces_in_tag;

      --%test(Raise warning and ignore tag starting ith '-')
      procedure test_minus_in_tag;

  --%endcontext
  
end test_suite_builder;
/
