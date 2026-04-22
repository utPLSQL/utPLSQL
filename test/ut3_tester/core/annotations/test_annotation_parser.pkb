create or replace package body test_annotation_parser is

  procedure test_proc_comments is
    l_source   dbms_preprocessor.source_lines_t;
    l_actual   ut3_develop.ut_annotations;
    l_expected ut3_develop.ut_annotations;
  begin
    --Arrange
    l_source := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'PACKAGE test_tt AS'                 || chr(10),
      '    -- %suite'                      || chr(10),
      '    -- %displayname(Name of suite)' || chr(10),
      '    -- %suitepath(all.globaltests)' || chr(10),
      ''                                   || chr(10),
      '    -- %ann1(Name of suite)'        || chr(10),
      '    -- wrong line'                  || chr(10),
      '    -- %ann2(some_value)'           || chr(10),
      '    procedure foo;'                 || chr(10),
      '  END;'                             || chr(10)
    ));

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source, 'PACKAGE');

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation(2,'suite',null, null),
      ut3_develop.ut_annotation(3,'displayname','Name of suite',null),
      ut3_develop.ut_annotation(4,'suitepath','all.globaltests',null),
      ut3_develop.ut_annotation(6,'ann1','Name of suite',null),
      ut3_develop.ut_annotation(8,'ann2','some_value','foo')
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure include_floating_annotations is
    l_source    dbms_preprocessor.source_lines_t;
    l_actual    ut3_develop.ut_annotations;
    l_expected  ut3_develop.ut_annotations;
  begin
    --Arrange
    l_source := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'PACKAGE test_tt AS'                 || chr(10),
      '    -- %suite'                      || chr(10),
      '    -- %displayname(Name of suite)' || chr(10),
      '    -- %suitepath(all.globaltests)' || chr(10),
      ''                                   || chr(10),
      '    -- %ann1(Name of suite)'        || chr(10),
      '    -- %ann2(all.globaltests)'      || chr(10),
      ''                                   || chr(10),
      '    --%test'                        || chr(10),
      '    procedure foo;'                 || chr(10),
      ''                                   || chr(10),
      '    -- %ann3(Name of suite)'        || chr(10),
      '    -- %ann4(all.globaltests)'      || chr(10),
      ''                                   || chr(10),
      '    --%test'                        || chr(10),
      '    procedure bar;'                 || chr(10),
      '  END;'                             || chr(10)
    ));

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source, 'PACKAGE');

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 2, 'suite', null, null ),
      ut3_develop.ut_annotation( 3, 'displayname', 'Name of suite', null ),
      ut3_develop.ut_annotation( 4, 'suitepath', 'all.globaltests', null ),
      ut3_develop.ut_annotation( 6, 'ann1', 'Name of suite', null ),
      ut3_develop.ut_annotation( 7, 'ann2', 'all.globaltests', null ),
      ut3_develop.ut_annotation( 9, 'test', null, 'foo'),
      ut3_develop.ut_annotation( 12, 'ann3', 'Name of suite', null ),
      ut3_develop.ut_annotation( 13, 'ann4', 'all.globaltests', null ),
      ut3_develop.ut_annotation( 15, 'test', null, 'bar')
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure parse_complex_with_functions is
    l_source         dbms_preprocessor.source_lines_t;
    l_actual         ut3_develop.ut_annotations;
    l_expected       ut3_develop.ut_annotations;

  begin
    l_source := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
    'PACKAGE test_tt AS'              || chr(10),
    ' -- %suite'                      || chr(10),
    ' -- %displayname(Name of suite)' || chr(10),
    ' -- %suitepath(all.globaltests)' || chr(10),
    ''                                || chr(10),
    ' --%test'                        || chr(10),
    ' procedure foo;'                 || chr(10),
    ''                                || chr(10),
    ''                                || chr(10),
    ' --%beforeeach'                  || chr(10),
    ' procedure foo2;'                || chr(10),
    ''                                || chr(10),
    '    --test comment'              || chr(10),
    '    -- wrong comment'            || chr(10),
    ''                                || chr(10),
    ''                                || chr(10),
    '/*'                              || chr(10),
    '    describtion of the procedure'  || chr(10),
    '    */'                            || chr(10),
    '    --%beforeeach(key=testval)'    || chr(10),
    '    PROCEDURE foo3(a_value number default null);' || chr(10),
    ''                                                 || chr(10),
    '    --%all'                                       || chr(10),
    '    function foo4(a_val number default null'      || chr(10),
    '      , a_par varchar2 default := ''asdf'');'     || chr(10),
    'END;'));

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source, 'PACKAGE');

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 2, 'suite', null, null ),
      ut3_develop.ut_annotation( 3, 'displayname', 'Name of suite', null ),
      ut3_develop.ut_annotation( 4, 'suitepath', 'all.globaltests', null ),
      ut3_develop.ut_annotation( 6, 'test', null, 'foo' ),
      ut3_develop.ut_annotation( 10, 'beforeeach', null,'foo2' ),
      ut3_develop.ut_annotation( 20, 'beforeeach', 'key=testval','foo3' ),
      ut3_develop.ut_annotation( 23, 'all', null,'foo4' )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure no_procedure_annotation is
    l_source         dbms_preprocessor.source_lines_t;
    l_actual         ut3_develop.ut_annotations;
    l_expected       ut3_develop.ut_annotations;

  begin
    --Arrange
    l_source := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'PACKAGE test_tt AS'                 || chr(10),
      '    -- %suite'                      || chr(10),
      '    -- %displayname(Name of suite)' || chr(10),
      '    -- %suitepath(all.globaltests)' || chr(10),
      ''                                   || chr(10),
      '    procedure foo;'                 || chr(10),
      '  END;'                             || chr(10)
    ));

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source, 'PACKAGE');

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 2, 'suite', null, null ),
      ut3_develop.ut_annotation( 3, 'displayname', 'Name of suite', null ),
      ut3_develop.ut_annotation( 4, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure parse_accessible_by is
    l_source         dbms_preprocessor.source_lines_t;
    l_actual         ut3_develop.ut_annotations;
    l_expected       ut3_develop.ut_annotations;

  begin
    --Arrange
    l_source := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'PACKAGE test_tt accessible by (foo) AS' || chr(10),
      '    -- %suite'                           || chr(10),
      '    -- %displayname(Name of suite)'      || chr(10),
      '    -- %suitepath(all.globaltests)'      || chr(10),
      ''                                        || chr(10),
      '    procedure foo;'                      || chr(10),
      '  END;'                                  || chr(10)
    ));

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source, 'PACKAGE');

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 2, 'suite', null, null ),
      ut3_develop.ut_annotation( 3, 'displayname', 'Name of suite', null ),
      ut3_develop.ut_annotation( 4, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure complex_package_declaration is
    l_source         dbms_preprocessor.source_lines_t;
    l_actual         ut3_develop.ut_annotations;
    l_expected       ut3_develop.ut_annotations;

  begin
    --Arrange
    l_source := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'PACKAGE test_tt'                         || chr(10),
      '    ACCESSIBLE BY (calling_proc)'        || chr(10),
      '    authid current_user'                 || chr(10),
      '    AS'                                  || chr(10),
      '    -- %suite'                           || chr(10),
      '    -- %displayname(Name of suite)'      || chr(10),
      '    -- %suitepath(all.globaltests)'      || chr(10),
      ''                                        || chr(10),
      '    procedure foo;'                      || chr(10),
      '  END;'                                  || chr(10)
    ));

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source, 'PACKAGE');

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 5, 'suite', null, null ),
      ut3_develop.ut_annotation( 6, 'displayname', 'Name of suite', null ),
      ut3_develop.ut_annotation( 7, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure complex_text is
    l_source         dbms_preprocessor.source_lines_t;
    l_actual         ut3_develop.ut_annotations;
    l_expected       ut3_develop.ut_annotations;

  begin
    --Arrange
    l_source := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'PACKAGE test_tt AS'                                              || chr(10),
      '    -- %suite'                                                   || chr(10),
      '    --%displayname(name = Name of suite)'                        || chr(10),
      '    -- %suitepath(key=all.globaltests,key2=foo,"--%some text")'  || chr(10),
      ''                                                                || chr(10),
      '    procedure foo;'                                              || chr(10),
      '  END;'                                                          || chr(10)
    ));

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source, 'PACKAGE');

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 2, 'suite', null, null ),
      ut3_develop.ut_annotation( 3, 'displayname', 'name = Name of suite', null ),
      ut3_develop.ut_annotation( 4, 'suitepath', 'key=all.globaltests,key2=foo,"--%some text"', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure ignore_annotations_in_comments is
    l_source         dbms_preprocessor.source_lines_t;
    l_actual         ut3_develop.ut_annotations;
    l_expected       ut3_develop.ut_annotations;

  begin
    --Arrange
    l_source := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'PACKAGE test_tt AS'                 || chr(10),
      '    /*'                             || chr(10),
      '    Some comment'                   || chr(10),
      '    -- inlined'                     || chr(10),
      '    -- %ignored'                    || chr(10),
      '    */'                             || chr(10),
      '    -- %suite'                      || chr(10),
      '    --%displayname(Name of suite)'  || chr(10),
      '    -- %suitepath(all.globaltests)' || chr(10),
      ''                                   || chr(10),
      '    procedure foo;'                 || chr(10),
      '  END;'                             || chr(10)
    ));

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source, 'PACKAGE');

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 7, 'suite', null, null ),
      ut3_develop.ut_annotation( 8, 'displayname', 'Name of suite', null ),
      ut3_develop.ut_annotation( 9, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure ignore_wrapped_package is
    l_source         dbms_preprocessor.source_lines_t;
    l_actual         ut3_develop.ut_annotations;
  begin
    --Arrange
    l_source(1) := 'create or replace PACKAGE tst_wrapped_pck wrapped
a000000
369
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
9
34 6d
bg9Jaf2KguofrwaqloE8yvbggKcwg5m49TOf9b9cFj7R9JaW8lYWWi70llr/K6V0iwlp5+eb
v58yvbLAXLi9gYHwoIvAgccti+Cmpg0DKLY=
-- %some_annotation_like_text
';
    --Act
    l_actual   := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source,'PACKAGE');
    --Assert
    ut.expect(anydata.convertCollection(l_actual)).to_be_empty();
  end;

  procedure brackets_in_desc is
    l_source         dbms_preprocessor.source_lines_t;
    l_actual         ut3_develop.ut_annotations;
    l_expected       ut3_develop.ut_annotations;
  begin
    --Arrange
    l_source := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'PACKAGE test_tt AS'                                                                   || chr(10),
      '  -- %suite(Name of suite (including some brackets) and some more text)'             || chr(10),
      'END;'                                                                                 || chr(10)
    ));

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source, 'PACKAGE');

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 2, 'suite', 'Name of suite (including some brackets) and some more text', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure test_space_before_annot_params is
    l_source         dbms_preprocessor.source_lines_t;
    l_actual         ut3_develop.ut_annotations;
    l_expected       ut3_develop.ut_annotations;

  begin
    --Arrange
    l_source := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'PACKAGE test_tt AS'              || chr(10),
      '  /*'                            || chr(10),
      '  Some comment'                  || chr(10),
      '  -- inlined'                    || chr(10),
      '  */'                            || chr(10),
      '  -- %suite'                     || chr(10),
      '  -- %suitepath (all.globaltests)'|| chr(10),
      ''                                || chr(10),
      '  procedure foo;'                || chr(10),
      'END;'                            || chr(10)
    ));

  --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source, 'PACKAGE');

  --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 6, 'suite', null, null ),
      ut3_develop.ut_annotation( 7, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure test_windows_newline
  as
    l_source    dbms_preprocessor.source_lines_t;
    l_actual    ut3_develop.ut_annotations;
    l_expected  ut3_develop.ut_annotations;
  begin
    --Arrange
    l_source := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'PACKAGE test_tt AS'                                         || chr(10),
      '        -- %suite'                                          || chr(10),
      '        -- %displayname(Name of suite)' || chr(13) || chr(10),
      '  -- %suitepath(all.globaltests)'                           || chr(10),
      '      END;'                                                 || chr(10)
    ));

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source, 'PACKAGE');

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 2, 'suite', null, null ),
      ut3_develop.ut_annotation( 3, 'displayname', 'Name of suite', null ),
      ut3_develop.ut_annotation( 4, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure test_annot_very_long_name
  as
    l_source    dbms_preprocessor.source_lines_t;
    l_actual    ut3_develop.ut_annotations;
    l_expected  ut3_develop.ut_annotations;
  begin
    --Arrange
    l_source := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'PACKAGE very_long_procedure_name_valid_for_oracle_12_so_utPLSQL_should_allow_it_definitely_well_still_not_reached_128_but_wait_we_did_it AS' || chr(10),
      '      -- %suite'                                                                                                                             || chr(10),
      '      -- %displayname(Name of suite)'                                                                                                        || chr(10),
      '      -- %suitepath(all.globaltests)'                                                                                                        || chr(10),
      ''                                                                                                                                            || chr(10),
      '      --%test'                                                                                                                               || chr(10),
      '      procedure very_long_procedure_name_valid_for_oracle_12_so_utPLSQL_should_allow_it_definitely_well_still_not_reached_128_but_wait_we_dit_it;' || chr(10),
      '    END;'                                                                                                                                    || chr(10)
    ));

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source, 'PACKAGE');

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 2, 'suite', null, null ),
      ut3_develop.ut_annotation( 3, 'displayname', 'Name of suite', null ),
      ut3_develop.ut_annotation( 4, 'suitepath', 'all.globaltests', null ),
      ut3_develop.ut_annotation( 6, 'test', null, 'very_long_procedure_name_valid_for_oracle_12_so_utPLSQL_should_allow_it_definitely_well_still_not_reached_128_but_wait_we_dit_it' )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure test_upper_annot is
    l_source    dbms_preprocessor.source_lines_t;
    l_actual    ut3_develop.ut_annotations;
    l_expected  ut3_develop.ut_annotations;
  begin
    --Arrange
    l_source := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'PACKAGE test_tt AS'                 || chr(10),
      '    -- %SUITE'                      || chr(10),
      '    -- %DISPLAYNAME(Name of suite)' || chr(10),
      '    -- %SUITEPATH(all.globaltests)' || chr(10),
      ''                                   || chr(10),
      '    -- %ANN1(Name of suite)'        || chr(10),
      '    -- %ANN2(all.globaltests)'      || chr(10),
      ''                                   || chr(10),
      '    --%TEST'                        || chr(10),
      '    procedure foo;'                 || chr(10),
      ''                                   || chr(10),
      '    -- %ANN3(Name of suite)'        || chr(10),
      '    -- %ANN4(all.globaltests)'      || chr(10),
      ''                                   || chr(10),
      '    --%TEST'                        || chr(10),
      '    procedure bar;'                 || chr(10),
      '  END;'                             || chr(10)
    ));

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source, 'PACKAGE');

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 2, 'suite', null, null ),
      ut3_develop.ut_annotation( 3, 'displayname', 'Name of suite', null ),
      ut3_develop.ut_annotation( 4, 'suitepath', 'all.globaltests', null ),
      ut3_develop.ut_annotation( 6, 'ann1', 'Name of suite', null ),
      ut3_develop.ut_annotation( 7, 'ann2', 'all.globaltests', null ),
      ut3_develop.ut_annotation( 9, 'test', null, 'foo'),
      ut3_develop.ut_annotation( 12, 'ann3', 'Name of suite', null ),
      ut3_develop.ut_annotation( 13, 'ann4', 'all.globaltests', null ),
      ut3_develop.ut_annotation( 15, 'test', null, 'bar')
      );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  ------------------------------------------------------------
  -- replace_multiline_comments coverage tests
  ------------------------------------------------------------

  procedure test_rmc_empty_source is
    l_input  dbms_preprocessor.source_lines_t;
    l_result dbms_preprocessor.source_lines_t;
  begin
    --Act
    l_result := ut3_develop.ut_utils.replace_multiline_comments(l_input);

    --Assert
    ut.expect(l_result.count).to_equal(0);
  end;

  procedure test_rmc_no_ml_comment_marker is
    l_input  dbms_preprocessor.source_lines_t;
    l_result dbms_preprocessor.source_lines_t;
  begin
    --Arrange
    l_input := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'procedure foo is' || chr(10),
      'begin'            || chr(10),
      '  null;'          || chr(10),
      'end;'             || chr(10)
    ));

    --Act
    l_result := ut3_develop.ut_utils.replace_multiline_comments(l_input);

    --Assert
    ut.expect(ut3_tester_helper.main_helper.lines_to_str(l_result)).to_equal(ut3_tester_helper.main_helper.lines_to_str(l_input));
  end;

  procedure test_rmc_line_inside_ml_comment is
    l_input  dbms_preprocessor.source_lines_t;
    l_result dbms_preprocessor.source_lines_t;
  begin
    --Arrange
    l_input := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'x := 1; /* start'           || chr(10),
      'this whole line is comment' || chr(10),
      'end comment */ x := 2;'    || chr(10)
    ));

    --Act
    l_result := ut3_develop.ut_utils.replace_multiline_comments(l_input);

    --Assert
    ut.expect(l_result(1)).to_equal('x := 1; ' || chr(10));
    ut.expect(l_result(2)).to_equal('');
    ut.expect(l_result(3)).to_equal(' x := 2;' || chr(10));
  end;

  procedure test_rmc_ml_comment_closed_midline is
    l_input  dbms_preprocessor.source_lines_t;
    l_result dbms_preprocessor.source_lines_t;
  begin
    --Arrange
    l_input := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      '/* open'                            || chr(10),
      'still inside'                       || chr(10),
      '*/ code /* remove this too */ kept' || chr(10)
    ));

    --Act
    l_result := ut3_develop.ut_utils.replace_multiline_comments(l_input);

    --Assert
    ut.expect(l_result(2)).to_equal('');
    ut.expect(l_result(3)).to_equal(' code  kept' || chr(10));
  end;

  procedure test_rmc_fast_path_no_tokens is
    l_input  dbms_preprocessor.source_lines_t;
    l_result dbms_preprocessor.source_lines_t;
  begin
    --Arrange
    -- line 2 has none of / - ' so hits fast path B; line 1 needed to pass pre-scan
    l_input := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      '/* comment */' || chr(10),
      'begin'         || chr(10)
    ));

    --Act
    l_result := ut3_develop.ut_utils.replace_multiline_comments(l_input);

    --Assert
    ut.expect(l_result(2)).to_equal('begin' || chr(10));
  end;

  procedure test_rmc_ml_comment_single_line is
    l_input  dbms_preprocessor.source_lines_t;
    l_result dbms_preprocessor.source_lines_t;
  begin
    --Arrange
    l_input := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'x := /* inline comment */ 42;' || chr(10)
    ));

    --Act
    l_result := ut3_develop.ut_utils.replace_multiline_comments(l_input);

    --Assert
    ut.expect(l_result(1)).to_equal('x :=  42;' || chr(10));
  end;

  procedure test_rmc_single_line_comment_preserved is
    l_input  dbms_preprocessor.source_lines_t;
    l_result dbms_preprocessor.source_lines_t;
  begin
    --Arrange
    l_input := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      '/* marker */'          || chr(10),
      '  -- %test annotation' || chr(10)
    ));

    --Act
    l_result := ut3_develop.ut_utils.replace_multiline_comments(l_input);

    --Assert
    ut.expect(l_result(2)).to_equal('  -- %test annotation' || chr(10));
  end;

  procedure test_rmc_string_literal_protects_markers is
    l_input  dbms_preprocessor.source_lines_t;
    l_result dbms_preprocessor.source_lines_t;
  begin
    --Arrange
    l_input := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'v := ''val /* not a comment */ here'';' || chr(10)
    ));

    --Act
    l_result := ut3_develop.ut_utils.replace_multiline_comments(l_input);

    --Assert
    ut.expect(l_result(1)).to_equal('v := ''val /* not a comment */ here'';' || chr(10));
  end;

  procedure test_rmc_string_literal_escaped_quotes is
    l_input  dbms_preprocessor.source_lines_t;
    l_result dbms_preprocessor.source_lines_t;
  begin
    --Arrange
    l_input := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'v := ''it''''s a /* test */'';' || chr(10)
    ));

    --Act
    l_result := ut3_develop.ut_utils.replace_multiline_comments(l_input);

    --Assert
    ut.expect(l_result(1)).to_equal('v := ''it''''s a /* test */'';' || chr(10));
  end;

  procedure test_rmc_q_quoted_string_literal is
    l_input  dbms_preprocessor.source_lines_t;
    l_result dbms_preprocessor.source_lines_t;
  begin
    --Arrange
    l_input := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'v := q''[/* not a comment */]'';' || chr(10)
    ));

    --Act
    l_result := ut3_develop.ut_utils.replace_multiline_comments(l_input);

    --Assert
    ut.expect(l_result(1)).to_equal('v := q''[/* not a comment */]'';' || chr(10));
  end;

  procedure test_rmc_unclosed_string_literal is
    l_input  dbms_preprocessor.source_lines_t;
    l_result dbms_preprocessor.source_lines_t;
  begin
    --Arrange
    l_input := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'v := ''hello /* inside unclosed' || chr(10)
    ));

    --Act
    l_result := ut3_develop.ut_utils.replace_multiline_comments(l_input);

    --Assert
    ut.expect(l_result(1)).to_equal('v := ''hello /* inside unclosed' || chr(10));
  end;

  procedure test_rmc_unclosed_q_string is
    l_input  dbms_preprocessor.source_lines_t;
    l_result dbms_preprocessor.source_lines_t;
    c_line   constant varchar2(100) := q'(v := q'[/* unclosed q-string)' || chr(10);
  begin
    --Arrange
    l_input := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(c_line));

    --Act
    l_result := ut3_develop.ut_utils.replace_multiline_comments(l_input);

    --Assert
    ut.expect(l_result(1)).to_equal(c_line);
  end;

  procedure test_rmc_multiple_ml_comments_one_line is
    l_input  dbms_preprocessor.source_lines_t;
    l_result dbms_preprocessor.source_lines_t;
  begin
    --Arrange
    l_input := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'a /* one */ := /* two */ 1;' || chr(10)
    ));

    --Act
    l_result := ut3_develop.ut_utils.replace_multiline_comments(l_input);

    --Assert
    ut.expect(l_result(1)).to_equal('a  :=  1;' || chr(10));
  end;

  procedure test_rmc_comment_after_string_with_slash is
    l_input  dbms_preprocessor.source_lines_t;
    l_result dbms_preprocessor.source_lines_t;
  begin
    --Arrange
    l_input := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'v := ''a/b''; -- this is /* not */ a ml comment' || chr(10)
    ));

    --Act
    l_result := ut3_develop.ut_utils.replace_multiline_comments(l_input);

    --Assert
    ut.expect(l_result(1)).to_equal('v := ''a/b''; -- this is /* not */ a ml comment' || chr(10));
  end;

  procedure test_multiline_proc_header_lines is
    l_source    dbms_preprocessor.source_lines_t;
    l_actual    ut3_develop.ut_annotations;
    l_expected  ut3_develop.ut_annotations;
  begin
    --Arrange
    -- procedure header spans multiple lines before terminating ;
    l_source := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'PACKAGE test_tt AS'                        || chr(10),
      '    -- %suite'                             || chr(10),
      ''                                          || chr(10),
      '    --%test'                               || chr(10),
      '    procedure foo('                        || chr(10),
      '      a_param1 varchar2'                   || chr(10),
      '     ,a_param2 number default null'        || chr(10),
      '    );'                                    || chr(10),
      '  END;'                                    || chr(10)
    ));

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source, 'PACKAGE');

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 2, 'suite', null, null ),
      ut3_develop.ut_annotation( 4, 'test', null, 'foo' )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure test_non_comment_line_resets_block_lines is
    l_source    dbms_preprocessor.source_lines_t;
    l_actual    ut3_develop.ut_annotations;
    l_expected  ut3_develop.ut_annotations;
  begin
    --Arrange
    -- a non-comment non-proc line between annotation and procedure breaks the association
    -- %test becomes a floating top-level annotation with no subobject
    l_source := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'PACKAGE test_tt AS'             || chr(10),
      '    -- %suite'                  || chr(10),
      ''                               || chr(10),
      '    --%test'                    || chr(10),
      '    pragma serially_reusable;'  || chr(10),
      '    procedure foo;'             || chr(10),
      '  END;'                         || chr(10)
    ));

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source, 'PACKAGE');

    --Assert
    -- %test is NOT associated with foo — accumulator was reset by pragma line
    -- it surfaces as a top-level annotation with no subobject_name
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 2, 'suite', null, null ),
      ut3_develop.ut_annotation( 4, 'test', null, null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure test_annotation_not_at_line_start_ignored_lines is
    l_source    dbms_preprocessor.source_lines_t;
    l_actual    ut3_develop.ut_annotations;
    l_expected  ut3_develop.ut_annotations;
  begin
    --Arrange
    -- code before -- means it is not at start of line and must be ignored
    l_source := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'PACKAGE test_tt AS'                || chr(10),
      '    -- %suite'                     || chr(10),
      '    x := 1; -- %not_an_annotation' || chr(10),
      '    procedure foo;'                || chr(10),
      '  END;'                            || chr(10)
    ));

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source, 'PACKAGE');

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 2, 'suite', null, null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure test_whitespace_line_between_comment_and_proc_lines is
    l_source    dbms_preprocessor.source_lines_t;
    l_actual    ut3_develop.ut_annotations;
    l_expected  ut3_develop.ut_annotations;
  begin
    --Arrange
    -- space-only line between annotation comment and procedure declaration is tolerated
    l_source := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'PACKAGE test_tt AS'  || chr(10),
      '    -- %suite'       || chr(10),
      ''                    || chr(10),
      '    --%test'         || chr(10),
      '    '                || chr(10),
      '    procedure foo;'  || chr(10),
      '  END;'              || chr(10)
    ));

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source, 'PACKAGE');

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 2, 'suite', null, null ),
      ut3_develop.ut_annotation( 4, 'test', null, 'foo' )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure test_space_between_dashes_and_qualifier_lines is
    l_source    dbms_preprocessor.source_lines_t;
    l_actual    ut3_develop.ut_annotations;
    l_expected  ut3_develop.ut_annotations;
  begin
    --Arrange
    -- spaces between -- and % are skipped and annotation is still recognised
    -- annotations are not adjacent to a procedure so they are top-level
    l_source := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'PACKAGE test_tt AS'              || chr(10),
      '    --   %suite'                 || chr(10),
      '    --   %displayname(my suite)' || chr(10),
      ''                                || chr(10),
      '    procedure foo;'              || chr(10),
      '  END;'                          || chr(10)
    ));

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source, 'PACKAGE');

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 2, 'suite', null, null ),
      ut3_develop.ut_annotation( 3, 'displayname', 'my suite', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure test_percent_not_after_dashes_ignored_lines is
    l_source    dbms_preprocessor.source_lines_t;
    l_actual    ut3_develop.ut_annotations;
    l_expected  ut3_develop.ut_annotations;
  begin
    --Arrange
    -- -- present and % present on line but % is not immediately after --
    -- e.g. a regular comment that happens to mention 100%
    l_source := ut3_tester_helper.main_helper.make_source(ut3_develop.ut_varchar2_list(
      'PACKAGE test_tt AS'                     || chr(10),
      '    -- %suite'                          || chr(10),
      '    -- coverage is 100% on this module' || chr(10),
      '    procedure foo;'                     || chr(10),
      '  END;'                                 || chr(10)
    ));

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source, 'PACKAGE');

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 2, 'suite', null, null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

end test_annotation_parser;
/