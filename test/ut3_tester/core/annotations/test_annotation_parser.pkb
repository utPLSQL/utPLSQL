create or replace package body test_annotation_parser is

  procedure test_proc_comments is
    l_source   clob;
    l_actual   ut3.ut_annotations;
    l_expected ut3.ut_annotations;

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
    l_actual := ut3.ut_annotation_parser.parse_object_annotations(l_source);

    --Assert

    l_expected := ut3.ut_annotations(
      ut3.ut_annotation(2,'suite',null, null),
      ut3.ut_annotation(3,'displayname','Name of suite',null),
      ut3.ut_annotation(4,'suitepath','all.globaltests',null),
      ut3.ut_annotation(6,'ann1','Name of suite',null),
      ut3.ut_annotation(8,'ann2','some_value','foo')
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure include_floating_annotations is
    l_source    clob;
    l_actual    ut3.ut_annotations;
    l_expected  ut3.ut_annotations;
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
    l_actual := ut3.ut_annotation_parser.parse_object_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 2, 'suite', null, null ),
      ut3.ut_annotation( 3, 'displayname', 'Name of suite', null ),
      ut3.ut_annotation( 4, 'suitepath', 'all.globaltests', null ),
      ut3.ut_annotation( 6, 'ann1', 'Name of suite', null ),
      ut3.ut_annotation( 7, 'ann2', 'all.globaltests', null ),
      ut3.ut_annotation( 9, 'test', null, 'foo'),
      ut3.ut_annotation( 12, 'ann3', 'Name of suite', null ),
      ut3.ut_annotation( 13, 'ann4', 'all.globaltests', null ),
      ut3.ut_annotation( 15, 'test', null, 'bar')
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure parse_complex_with_functions is
    l_source         clob;
    l_actual         ut3.ut_annotations;
    l_expected       ut3.ut_annotations;

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
    l_actual         := ut3.ut_annotation_parser.parse_object_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 2, 'suite', null, null ),
      ut3.ut_annotation( 3, 'displayname', 'Name of suite', null ),
      ut3.ut_annotation( 4, 'suitepath', 'all.globaltests', null ),
      ut3.ut_annotation( 6, 'test', null, 'foo' ),
      ut3.ut_annotation( 10, 'beforeeach', null,'foo2' ),
      ut3.ut_annotation( 20, 'beforeeach', 'key=testval','foo3' ),
      ut3.ut_annotation( 23, 'all', null,'foo4' )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure no_procedure_annotation is
    l_source         clob;
    l_actual         ut3.ut_annotations;
    l_expected       ut3.ut_annotations;

  begin
    l_source := 'PACKAGE test_tt AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)

    procedure foo;
  END;';

    --Act
    l_actual         := ut3.ut_annotation_parser.parse_object_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 2, 'suite', null, null ),
      ut3.ut_annotation( 3, 'displayname', 'Name of suite', null ),
      ut3.ut_annotation( 4, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure parse_accessible_by is
    l_source         clob;
    l_actual         ut3.ut_annotations;
    l_expected       ut3.ut_annotations;

  begin
    l_source := 'PACKAGE test_tt accessible by (foo) AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)

    procedure foo;
  END;';

    --Act
    l_actual         := ut3.ut_annotation_parser.parse_object_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 2, 'suite', null, null ),
      ut3.ut_annotation( 3, 'displayname', 'Name of suite', null ),
      ut3.ut_annotation( 4, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure complex_package_declaration is
    l_source         clob;
    l_actual         ut3.ut_annotations;
    l_expected       ut3.ut_annotations;

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
    l_actual         := ut3.ut_annotation_parser.parse_object_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 5, 'suite', null, null ),
      ut3.ut_annotation( 6, 'displayname', 'Name of suite', null ),
      ut3.ut_annotation( 7, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure complex_text is
    l_source         clob;
    l_actual         ut3.ut_annotations;
    l_expected       ut3.ut_annotations;

  begin
    l_source := 'PACKAGE test_tt AS
    -- %suite
    --%displayname(name = Name of suite)
    -- %suitepath(key=all.globaltests,key2=foo,"--%some text")

    procedure foo;
  END;';

    --Act
    l_actual         := ut3.ut_annotation_parser.parse_object_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 2, 'suite', null, null ),
      ut3.ut_annotation( 3, 'displayname', 'name = Name of suite', null ),
      ut3.ut_annotation( 4, 'suitepath', 'key=all.globaltests,key2=foo,"--%some text"', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure ignore_annotations_in_comments is
    l_source         clob;
    l_actual         ut3.ut_annotations;
    l_expected       ut3.ut_annotations;

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
    l_actual         := ut3.ut_annotation_parser.parse_object_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 7, 'suite', null, null ),
      ut3.ut_annotation( 8, 'displayname', 'Name of suite', null ),
      ut3.ut_annotation( 9, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure ignore_wrapped_package is
    l_source         dbms_preprocessor.source_lines_t;
    l_actual         ut3.ut_annotations;
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
    l_actual   := ut3.ut_annotation_parser.parse_object_annotations(l_source);
    --Assert
    ut.expect(anydata.convertCollection(l_actual)).to_be_empty();
  end;

  procedure brackets_in_desc is

    l_source         clob;
    l_actual         ut3.ut_annotations;
    l_expected       ut3.ut_annotations;
  begin
    l_source := 'PACKAGE test_tt AS
  -- %suite(Name of suite (including some brackets) and some more text)
END;';

    --Act
    l_actual         := ut3.ut_annotation_parser.parse_object_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 2, 'suite', 'Name of suite (including some brackets) and some more text', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure test_space_before_annot_params is
    l_source clob;
    l_actual         ut3.ut_annotations;
    l_expected ut3.ut_annotations;

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
    l_actual         := ut3.ut_annotation_parser.parse_object_annotations(l_source);

  --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 6, 'suite', null, null ),
      ut3.ut_annotation( 7, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure test_windows_newline
  as
    l_source    clob;
    l_actual    ut3.ut_annotations;
    l_expected  ut3.ut_annotations;
  begin
    l_source := 'PACKAGE test_tt AS
        -- %suite
        -- %displayname(Name of suite)' || chr(13) || chr(10)
      || '  -- %suitepath(all.globaltests)
      END;';

    --Act
    l_actual         := ut3.ut_annotation_parser.parse_object_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 2, 'suite', null, null ),
      ut3.ut_annotation( 3, 'displayname', 'Name of suite', null ),
      ut3.ut_annotation( 4, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure test_annot_very_long_name
  as
    l_source clob;
    l_actual         ut3.ut_annotations;
    l_expected ut3.ut_annotations;
  begin
    l_source := 'PACKAGE very_long_procedure_name_valid_for_oracle_12_so_utPLSQL_should_allow_it_definitely_well_still_not_reached_128_but_wait_we_did_it AS
      -- %suite
      -- %displayname(Name of suite)
      -- %suitepath(all.globaltests)

      --%test
      procedure very_long_procedure_name_valid_for_oracle_12_so_utPLSQL_should_allow_it_definitely_well_still_not_reached_128_but_wait_we_dit_it;
    END;';

    --Act
    l_actual         := ut3.ut_annotation_parser.parse_object_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 2, 'suite', null, null ),
      ut3.ut_annotation( 3, 'displayname', 'Name of suite', null ),
      ut3.ut_annotation( 4, 'suitepath', 'all.globaltests', null ),
      ut3.ut_annotation( 6, 'test', null, 'very_long_procedure_name_valid_for_oracle_12_so_utPLSQL_should_allow_it_definitely_well_still_not_reached_128_but_wait_we_dit_it' )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure test_upper_annot is
    l_source    clob;
    l_actual    ut3.ut_annotations;
    l_expected  ut3.ut_annotations;
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
    l_actual := ut3.ut_annotation_parser.parse_object_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 2, 'suite', null, null ),
      ut3.ut_annotation( 3, 'displayname', 'Name of suite', null ),
      ut3.ut_annotation( 4, 'suitepath', 'all.globaltests', null ),
      ut3.ut_annotation( 6, 'ann1', 'Name of suite', null ),
      ut3.ut_annotation( 7, 'ann2', 'all.globaltests', null ),
      ut3.ut_annotation( 9, 'test', null, 'foo'),
      ut3.ut_annotation( 12, 'ann3', 'Name of suite', null ),
      ut3.ut_annotation( 13, 'ann4', 'all.globaltests', null ),
      ut3.ut_annotation( 15, 'test', null, 'bar')
      );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

end test_annotation_parser;
/
