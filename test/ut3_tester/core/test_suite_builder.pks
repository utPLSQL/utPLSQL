create or replace package test_suite_builder is
  --%suite(suite_builder)
  --%suitepath(utplsql.ut3_tester.core)

  --%context(suite)
  --%displayname(--%suite annotation)

      --%test(Sets suite name from package name and leaves description empty)
      procedure no_suite_description;

      --%test(Sets suite description using first --%suite annotation)
      procedure suite_description_from_suite;

      --%test(Gives warning if more than one --%suite annotation used)
      procedure suite_annot_duplicated;

  --%endcontext

  --%context(displayname)
  --%displayname(--%displayname annotation)

      --%test(Overrides suite description using first --%displayname annotation)
      procedure suite_descr_from_displayname;

      --%test(Gives warning if more than one --%displayname annotation used)
      procedure displayname_annot_duplicated;

      --%test(Gives warning if --%displayname annotation has no value)
      procedure displayname_annot_empty;

  --%endcontext

  --%context(test)
  --%displayname(--%test annotation)

      --%test(Creates a test item for procedure annotated with --%test annotation)
      procedure test_annotation;

      --%test(Gives warning if more than one --%test annotation used)
      procedure test_annot_duplicated;

      --%test(Is added to suite according to annotation order in package spec)
      procedure test_annotation_ordering;

  --%endcontext

  --%context(suitepath)
  --%displayname(--%suitepath annotation)

      --%test(Sets suite path using first --%suitepath annotation)
      procedure suitepath_from_non_empty_path;

      --%test(Gives warning if more than one --%suitepath annotation used)
      procedure suitepath_annot_duplicated;

      --%test(Gives warning if --%suitepath annotation has no value)
      procedure suitepath_annot_empty;

      --%test(Gives warning if --%suitepath annotation has invalid value)
      procedure suitepath_annot_invalid_path;

  --%endcontext

  --%context(rollback)
  --%displayname(--%rollback annotation)

      --%test(Sets rollback type using first --%rollback annotation)
      procedure rollback_type_valid;

      --%test(Gives warning if more than one --%rollback annotation used)
      procedure rollback_type_duplicated;

      --%test(Gives warning if --%rollback annotation has no value)
      procedure rollback_type_empty;

      --%test(Gives warning if --%rollback annotation has invalid value)
      procedure rollback_type_invalid;

  --%endcontext

  --%context(before_after_all_each)
  --%displayname(--%before/after all/each annotations)

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

  --%context(context)
  --%displayname(--%context annotation)

      --%test(Creates nested suite for content between context/endcontext annotations)
      procedure suite_from_context;

      --%test(Associates before/after all/each to tests in context only)
      procedure before_after_in_context;

      --%test(Propagates beforeeach/aftereach to context)
      procedure before_after_out_of_context;

      --%test(Does not create context and gives warning when endcontext is missing)
      procedure context_without_endcontext;

      --%test(Gives warning if --%endcontext is missing a preceding --%context)
      procedure endcontext_without_context;

      --%test(Gives warning when two contexts have the same name and ignores duplicated context)
      procedure duplicate_context_name;

  --%endcontext

  --%context(throws)
  --%displayname(--%throws annotation)

      --%test(Gives warning if --%throws annotation has no value)
      procedure throws_value_empty;

      --%test(Gives warning if --%throws annotation has invalid value)
      procedure throws_value_invalid;

  --%endcontext

  --%context(beforetest_aftertest)
  --%displayname(--%beforetest/aftertest annotation)

      --%test(Supports multiple occurrences of beforetest/aftertest for a test)
      procedure before_aftertest_multi;

      --%test(Supports same procedure defined twice)
      procedure before_aftertest_twice;

      --%test(Supports beforetest from external package)
      procedure before_aftertest_pkg_proc;

      --%test(Supports mix of procedure and package.procedure)
      procedure before_aftertest_mixed_syntax;

  --%endcontext

  --%context(unknown_annotation)
  --%displayname(--%bad_annotation)

      --%test(Gives warning when unknown procedure level annotation passed)
      procedure test_bad_procedure_annotation;

      --%test(Gives warning when unknown package level annotation passed)
      procedure test_bad_package_annotation;

  --%endcontext

  --%context(tags_annotation)
  --%displayname(--%tag_annotation)
  
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
