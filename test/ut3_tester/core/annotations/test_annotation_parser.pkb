create or replace package body test_annotation_parser is

  function lines_to_str(a_lines dbms_preprocessor.source_lines_t) return varchar2 is
    l_result varchar2(32767);
  begin
    for i in 1 .. a_lines.count loop
      l_result := l_result || a_lines(i);
    end loop;
    return l_result;
  end;

  function make_source(a_lines ut_varchar2_list) return dbms_preprocessor.source_lines_t is
    l_result dbms_preprocessor.source_lines_t;
  begin
    for i in 1 .. a_lines.count loop
      l_result(i) := a_lines(i);
    end loop;
    return l_result;
  end;

  procedure test_proc_comments is
    l_source   clob;
    l_actual   ut3_develop.ut_annotations;
    l_expected ut3_develop.ut_annotations;

  begin
    l_source := 'PACKAGE test_tt AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)

    -- %ann1(Name of suite)
    -- wrong line
    -- %ann2(some_value)
    procedure foo;
  END;';

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source);

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
    l_source    clob;
    l_actual    ut3_develop.ut_annotations;
    l_expected  ut3_develop.ut_annotations;
  begin
    l_source := 'PACKAGE test_tt AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)

    -- %ann1(Name of suite)
    -- %ann2(all.globaltests)

    --%test
    procedure foo;

    -- %ann3(Name of suite)
    -- %ann4(all.globaltests)

    --%test
    procedure bar;
  END;';

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source);

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
    l_source         clob;
    l_actual         ut3_develop.ut_annotations;
    l_expected       ut3_develop.ut_annotations;

  begin
    l_source := 'PACKAGE test_tt AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)

    --%test
    procedure foo;


    --%beforeeach
    procedure foo2;

    --test comment
    -- wrong comment


    /*
    describtion of the procedure
    */
    --%beforeeach(key=testval)
    PROCEDURE foo3(a_value number default null);

    --%all
    function foo4(a_val number default null
      , a_par varchar2 default := ''asdf'');
  END;';

    --Act
    l_actual         := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source);

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
    l_source         clob;
    l_actual         ut3_develop.ut_annotations;
    l_expected       ut3_develop.ut_annotations;

  begin
    l_source := 'PACKAGE test_tt AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)

    procedure foo;
  END;';

    --Act
    l_actual         := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source);

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 2, 'suite', null, null ),
      ut3_develop.ut_annotation( 3, 'displayname', 'Name of suite', null ),
      ut3_develop.ut_annotation( 4, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure parse_accessible_by is
    l_source         clob;
    l_actual         ut3_develop.ut_annotations;
    l_expected       ut3_develop.ut_annotations;

  begin
    l_source := 'PACKAGE test_tt accessible by (foo) AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)

    procedure foo;
  END;';

    --Act
    l_actual         := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source);

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 2, 'suite', null, null ),
      ut3_develop.ut_annotation( 3, 'displayname', 'Name of suite', null ),
      ut3_develop.ut_annotation( 4, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure complex_package_declaration is
    l_source         clob;
    l_actual         ut3_develop.ut_annotations;
    l_expected       ut3_develop.ut_annotations;

  begin
    l_source := 'PACKAGE test_tt
    ACCESSIBLE BY (calling_proc)
    authid current_user
    AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)

    procedure foo;
  END;';

    --Act
    l_actual         := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source);

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 5, 'suite', null, null ),
      ut3_develop.ut_annotation( 6, 'displayname', 'Name of suite', null ),
      ut3_develop.ut_annotation( 7, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure complex_text is
    l_source         clob;
    l_actual         ut3_develop.ut_annotations;
    l_expected       ut3_develop.ut_annotations;

  begin
    l_source := 'PACKAGE test_tt AS
    -- %suite
    --%displayname(name = Name of suite)
    -- %suitepath(key=all.globaltests,key2=foo,"--%some text")

    procedure foo;
  END;';

    --Act
    l_actual         := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source);

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 2, 'suite', null, null ),
      ut3_develop.ut_annotation( 3, 'displayname', 'name = Name of suite', null ),
      ut3_develop.ut_annotation( 4, 'suitepath', 'key=all.globaltests,key2=foo,"--%some text"', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure ignore_annotations_in_comments is
    l_source         clob;
    l_actual         ut3_develop.ut_annotations;
    l_expected       ut3_develop.ut_annotations;

  begin
    l_source := 'PACKAGE test_tt AS
    /*
    Some comment
    -- inlined
    -- %ignored
    */
    -- %suite
    --%displayname(Name of suite)
    -- %suitepath(all.globaltests)

    procedure foo;
  END;';

    --Act
    l_actual         := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source);

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

    l_source         clob;
    l_actual         ut3_develop.ut_annotations;
    l_expected       ut3_develop.ut_annotations;
  begin
    l_source := 'PACKAGE test_tt AS
  -- %suite(Name of suite (including some brackets) and some more text)
END;';

    --Act
    l_actual         := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source);

    --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 2, 'suite', 'Name of suite (including some brackets) and some more text', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure test_space_before_annot_params is
    l_source clob;
    l_actual         ut3_develop.ut_annotations;
    l_expected ut3_develop.ut_annotations;

  begin
    l_source := 'PACKAGE test_tt AS
  /*
  Some comment
  -- inlined
  */
  -- %suite
  -- %suitepath (all.globaltests)

  procedure foo;
END;';

  --Act
    l_actual         := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source);

  --Assert
    l_expected := ut3_develop.ut_annotations(
      ut3_develop.ut_annotation( 6, 'suite', null, null ),
      ut3_develop.ut_annotation( 7, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure test_windows_newline
  as
    l_source    clob;
    l_actual    ut3_develop.ut_annotations;
    l_expected  ut3_develop.ut_annotations;
  begin
    l_source := 'PACKAGE test_tt AS
        -- %suite
        -- %displayname(Name of suite)' || chr(13) || chr(10)
      || '  -- %suitepath(all.globaltests)
      END;';

    --Act
    l_actual         := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source);

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
    l_source clob;
    l_actual         ut3_develop.ut_annotations;
    l_expected ut3_develop.ut_annotations;
  begin
    l_source := 'PACKAGE very_long_procedure_name_valid_for_oracle_12_so_utPLSQL_should_allow_it_definitely_well_still_not_reached_128_but_wait_we_did_it AS
      -- %suite
      -- %displayname(Name of suite)
      -- %suitepath(all.globaltests)

      --%test
      procedure very_long_procedure_name_valid_for_oracle_12_so_utPLSQL_should_allow_it_definitely_well_still_not_reached_128_but_wait_we_dit_it;
    END;';

    --Act
    l_actual         := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source);

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
    l_source    clob;
    l_actual    ut3_develop.ut_annotations;
    l_expected  ut3_develop.ut_annotations;
  begin
    l_source := 'PACKAGE test_tt AS
    -- %SUITE
    -- %DISPLAYNAME(Name of suite)
    -- %SUITEPATH(all.globaltests)

    -- %ANN1(Name of suite)
    -- %ANN2(all.globaltests)

    --%TEST
    procedure foo;

    -- %ANN3(Name of suite)
    -- %ANN4(all.globaltests)

    --%TEST
    procedure bar;
  END;';

    --Act
    l_actual := ut3_develop.ut_annotation_parser.parse_object_annotations(l_source);

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
  -- source_lines_t overload equivalents of existing tests
  ------------------------------------------------------------

  procedure test_proc_comments_lines is
    l_source   dbms_preprocessor.source_lines_t;
    l_actual   ut3_develop.ut_annotations;
    l_expected ut3_develop.ut_annotations;
  begin
    --Arrange
    l_source := make_source(ut_varchar2_list(
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

  procedure include_floating_annotations_lines is
    l_source    dbms_preprocessor.source_lines_t;
    l_actual    ut3_develop.ut_annotations;
    l_expected  ut3_develop.ut_annotations;
  begin
    --Arrange
    l_source := make_source(ut_varchar2_list(
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

  procedure ignore_annotations_in_comments_lines is
    l_source         dbms_preprocessor.source_lines_t;
    l_actual         ut3_develop.ut_annotations;
    l_expected       ut3_develop.ut_annotations;
  begin
    --Arrange
    l_source := make_source(ut_varchar2_list(
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

  procedure no_procedure_annotation_lines is
    l_source         dbms_preprocessor.source_lines_t;
    l_actual         ut3_develop.ut_annotations;
    l_expected       ut3_develop.ut_annotations;
  begin
    --Arrange
    l_source := make_source(ut_varchar2_list(
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
    l_input := make_source(ut_varchar2_list(
      'procedure foo is' || chr(10),
      'begin'            || chr(10),
      '  null;'          || chr(10),
      'end;'             || chr(10)
    ));

    --Act
    l_result := ut3_develop.ut_utils.replace_multiline_comments(l_input);

    --Assert
    ut.expect(lines_to_str(l_result)).to_equal(lines_to_str(l_input));
  end;

  procedure test_rmc_line_inside_ml_comment is
    l_input  dbms_preprocessor.source_lines_t;
    l_result dbms_preprocessor.source_lines_t;
  begin
    --Arrange
    l_input := make_source(ut_varchar2_list(
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
    l_input := make_source(ut_varchar2_list(
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
    l_input := make_source(ut_varchar2_list(
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
    l_input := make_source(ut_varchar2_list(
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
    l_input := make_source(ut_varchar2_list(
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
    l_input := make_source(ut_varchar2_list(
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
    l_input := make_source(ut_varchar2_list(
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
    l_input := make_source(ut_varchar2_list(
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
    l_input := make_source(ut_varchar2_list(
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
    l_input := make_source(ut_varchar2_list(c_line));

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
    l_input := make_source(ut_varchar2_list(
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
    l_input := make_source(ut_varchar2_list(
      'v := ''a/b''; -- this is /* not */ a ml comment' || chr(10)
    ));

    --Act
    l_result := ut3_develop.ut_utils.replace_multiline_comments(l_input);

    --Assert
    ut.expect(l_result(1)).to_equal('v := ''a/b''; -- this is /* not */ a ml comment' || chr(10));
  end;

procedure test_windows_newline_lines
  as
    l_source    dbms_preprocessor.source_lines_t;
    l_actual    ut3_develop.ut_annotations;
    l_expected  ut3_develop.ut_annotations;
  begin
    --Arrange
    l_source := make_source(ut_varchar2_list(
      'PACKAGE test_tt AS'                                          || chr(10),
      '        -- %suite'                                           || chr(10),
      '        -- %displayname(Name of suite)'  || chr(13) || chr(10),
      '  -- %suitepath(all.globaltests)'                            || chr(10),
      '      END;'                                                  || chr(10)
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

  procedure test_annot_very_long_name_lines
  as
    l_source    dbms_preprocessor.source_lines_t;
    l_actual    ut3_develop.ut_annotations;
    l_expected  ut3_develop.ut_annotations;
  begin
    --Arrange
    l_source := make_source(ut_varchar2_list(
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

end test_annotation_parser;
/