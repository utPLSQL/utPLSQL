create or replace package body test_annotation_parser is

  procedure test1 is
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
    l_actual := ut3.ut_annotation_parser.parse_package_annotations(l_source);

    --Assert

    l_expected := ut3.ut_annotations(
      ut3.ut_annotation(1,'suite',null, null),
      ut3.ut_annotation(2,'displayname','Name of suite',null),
      ut3.ut_annotation(3,'suitepath','all.globaltests',null),
      ut3.ut_annotation(5,'ann2','some_value','foo')
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure test2 is
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

    procedure foo;
  END;';

    --Act
    l_actual := ut3.ut_annotation_parser.parse_package_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 1, 'suite', null, null ),
      ut3.ut_annotation( 2, 'displayname', 'Name of suite', null ),
      ut3.ut_annotation( 3, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure test3 is
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

    function foo4(a_val number default null
      , a_par varchar2 default := ''asdf'');
  END;';

    --Act
    l_actual         := ut3.ut_annotation_parser.parse_package_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 1, 'suite', null, null ),
      ut3.ut_annotation( 2, 'displayname', 'Name of suite', null ),
      ut3.ut_annotation( 3, 'suitepath', 'all.globaltests', null ),
      ut3.ut_annotation( 4, 'test', null, 'foo' ),
      ut3.ut_annotation( 5, 'beforeeach', null,'foo2' ),
      ut3.ut_annotation( 6, 'beforeeach', 'key=testval','foo3' )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure test4 is
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
  END;';

    --Act
    l_actual         := ut3.ut_annotation_parser.parse_package_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 1, 'suite', null, null ),
      ut3.ut_annotation( 2, 'displayname', 'Name of suite', null ),
      ut3.ut_annotation( 3, 'suitepath', 'all.globaltests', null ),
      ut3.ut_annotation( 4, 'test', null, 'foo' )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure test5 is
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
    l_actual         := ut3.ut_annotation_parser.parse_package_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 1, 'suite', null, null ),
      ut3.ut_annotation( 2, 'displayname', 'Name of suite', null ),
      ut3.ut_annotation( 3, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure test6 is
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
    l_actual         := ut3.ut_annotation_parser.parse_package_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 1, 'suite', null, null ),
      ut3.ut_annotation( 2, 'displayname', 'Name of suite', null ),
      ut3.ut_annotation( 3, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure test7 is
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
    l_actual         := ut3.ut_annotation_parser.parse_package_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 1, 'suite', null, null ),
      ut3.ut_annotation( 2, 'displayname', 'Name of suite', null ),
      ut3.ut_annotation( 3, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure test8 is
    l_source         clob;
    l_actual         ut3.ut_annotations;
    l_expected       ut3.ut_annotations;

  begin
    l_source := 'PACKAGE test_tt AS
    -- %suite
    --%displayname(name = Name of suite)
    -- %suitepath(key=all.globaltests,key2=foo)

    procedure foo;
  END;';

    --Act
    l_actual         := ut3.ut_annotation_parser.parse_package_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 1, 'suite', null, null ),
      ut3.ut_annotation( 2, 'displayname', 'name = Name of suite', null ),
      ut3.ut_annotation( 3, 'suitepath', 'key=all.globaltests,key2=foo', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure test9 is
    l_source         clob;
    l_actual         ut3.ut_annotations;
    l_expected       ut3.ut_annotations;

  begin
    l_source := 'PACKAGE test_tt AS
    /*
    Some comment
    -- inlined
    */
    -- %suite
    --%displayname(Name of suite)
    -- %suitepath(all.globaltests)

    procedure foo;
  END;';

    --Act
    l_actual         := ut3.ut_annotation_parser.parse_package_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 1, 'suite', null, null ),
      ut3.ut_annotation( 2, 'displayname', 'Name of suite', null ),
      ut3.ut_annotation( 3, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

  end;

  procedure ignore_wrapped_package is
    l_actual ut3.ut_annotations;
    pragma autonomous_transaction;
  begin

    l_actual := ut3.ut_annotation_parser.get_package_annotations(user, 'TST_WRAPPED_PCK');

    ut.expect(l_actual.count).to_equal(0);

  end;

  procedure cre_wrapped_pck is
    pragma autonomous_transaction;
  begin
    dbms_ddl.create_wrapped(q'[
CREATE OR REPLACE PACKAGE tst_wrapped_pck IS
  PROCEDURE dummy;
END;
]');
  end;

  procedure drop_wrapped_pck is
    ex_pck_doesnt_exist exception;
    pragma autonomous_transaction;
    pragma exception_init(ex_pck_doesnt_exist, -04043);
  begin
    execute immediate 'drop package tst_wrapped_pck';
  exception
    when ex_pck_doesnt_exist then
      null;
  end;

  procedure brackets_in_desc is

    l_source         clob;
    l_actual         ut3.ut_annotations;
    l_expected       ut3.ut_annotations;
    l_ann_param      ut3.ut_annotation_parser.typ_annotation_param := null;
    --l_results        ut_expectation_results;
  begin
    l_source := 'PACKAGE test_tt AS
  -- %suite(Name of suite (including some brackets) and some more text)
END;';

    --Act
    l_actual         := ut3.ut_annotation_parser.parse_package_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 1, 'suite', 'Name of suite (including some brackets) and some more text', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure test_space_Before_Annot_Params is
    l_source clob;
    l_actual         ut3.ut_annotations;
    l_expected ut3.ut_annotations;
    l_ann_param ut3.ut_annotation_parser.typ_annotation_param;

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
    l_actual         := ut3.ut_annotation_parser.parse_package_annotations(l_source);

  --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 1, 'suite', null, null ),
      ut3.ut_annotation( 2, 'suitepath', 'all.globaltests', null )
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
    l_actual         := ut3.ut_annotation_parser.parse_package_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 1, 'suite', null, null ),
      ut3.ut_annotation( 2, 'displayname', 'Name of suite', null ),
      ut3.ut_annotation( 3, 'suitepath', 'all.globaltests', null )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure test_annot_very_long_name
  as
    l_source clob;
    l_actual         ut3.ut_annotations;
    l_expected ut3.ut_annotations;
    l_ann_param ut3.ut_annotation_parser.typ_annotation_param;
  begin
    l_source := 'PACKAGE test_tt AS
      -- %suite
      -- %displayname(Name of suite)
      -- %suitepath(all.globaltests)

      --%test
      procedure very_long_procedure_name_valid_for_oracle_12_so_utplsql_should_allow_it_definitely_well_still_not_reached_128_but_wait_we_ditit;
    END;';

    --Act
    l_actual         := ut3.ut_annotation_parser.parse_package_annotations(l_source);

    --Assert
    l_expected := ut3.ut_annotations(
      ut3.ut_annotation( 1, 'suite', null, null ),
      ut3.ut_annotation( 2, 'displayname', 'Name of suite', null ),
      ut3.ut_annotation( 3, 'suitepath', 'all.globaltests', null ),
      ut3.ut_annotation( 4, 'test', null, 'very_long_procedure_name_valid_for_oracle_12_so_utplsql_should_allow_it_definitely_well_still_not_reached_128_but_wait_we_ditit' )
    );

    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;


end test_annotation_parser;
/
