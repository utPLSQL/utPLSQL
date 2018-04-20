create or replace package test_suite_builder is
  --%suite(suite_builder)
  --%suitepath(utplsql.core)

  --%test(Sets suite name from package name and leaves description empty)
  procedure no_suite_description;

  --%test(Sets suite description using first --%suite annotation)
  procedure suite_description_from_suite;

  --%test(Sets suite path using first --%suitepath annotation)
  procedure suitepath_from_non_empty_path;

  --%test(Overrides suite description using first --%displayname annotation)
  procedure suite_descr_from_displayname;

  --%test(Sets rollback type using first --%rollback annotation)
  procedure rollback_type_valid;

  --%test(Gives warning if more than one --%rollback annotation used)
  procedure rollback_type_duplicated;

  --%test(Gives warning if more than one --%suite annotation used)
  procedure suite_annot_duplicated;

  --%test(Gives warning if more than one --%test annotation used)
  procedure test_annot_duplicated;

  --%test(Gives warning if more than one --%beforeall annotation used)
  procedure beforeall_annot_duplicated;

  --%test(Gives warning if more than one --%beforeeach annotation used)
  procedure beforeeach_annot_duplicated;

  --%test(Gives warning if more than one --%afterall annotation used)
  procedure afterall_annot_duplicated;

  --%test(Gives warning if more than one --%aftereach annotation used)
  procedure aftereach_annot_duplicated;

  --%test(Gives warning if more than one --%suitepath annotation used)
  procedure suitepath_annot_duplicated;

  --%test(Gives warning if more than one --%displayname annotation used)
  procedure displayname_annot_duplicated;

  --%test(Gives warning if --%suitepath annotation has no value)
  procedure suitepath_annot_empty;

  --%test(Gives warning if --%suitepath annotation has invalid value)
  procedure suitepath_annot_invalid_path;

  --%test(Gives warning if --%displayname annotation has no value)
  procedure displayname_annot_empty;

  --%test(Gives warning if --%rollback annotation has no value)
  procedure rollback_type_empty;

  --%test(Gives warning if --%rollback annotation has invalid value)
  procedure rollback_type_invalid;

  --%test(Supports multiple before/after definitions)
  procedure multiple_before_after;

  --%test(Supports before/after all/each annotations on single procedure)
  procedure before_after_on_single_proc;

  --%test(Gives warning on before/after all/each annotations mixed with test)
  procedure before_after_mixed_with_test;

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

end;
/
