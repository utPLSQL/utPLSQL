create or replace package body test_ut_metadata is

  c_cr constant varchar2(1) := chr(13);
  c_lf constant varchar2(2) := chr(10);
  c_crlf constant varchar2(2) := chr(13)||chr(10);

  c_pks_lf constant varchar2(1000) :=
      'create or replace package test_package1 is'||c_lf
    ||'        procedure test_max_length;'||c_lf
    ||'end;'
    ;
  c_pkg_lf constant varchar2(20000) :=
      q'[create or replace package body test_package1 is]'||c_lf
    ||q'[    procedure test_max_length is]'||c_lf
    ||q'[    begin]'||c_lf
    ||q'[      /* long comment over 4000 characters 1]'||rpad('*', 8000, '*')||'*/'||c_lf
    ||substrb(q'[      /* long comment 3999 and linebreak]'||rpad('*', 4000, '*'), 1, 3997)||'*/'||c_lf
    ||q'[      dbms_output.put_line('test_max_length called.');]'||c_lf
    ||q'[    end;]'||c_lf
    ||q'[  end;]'
    ;

  procedure test_over_varchar2_limit_trim_first_4000_lf
  is
    l_actual varchar2(32767);
    l_expect varchar2(32767);
  begin
    l_expect := trim(substrb(q'[      /* long comment over 4000 characters 1]'||rpad('*', 8000, '*')||'*/'||c_lf, 1, 4000));
    l_actual := ut3_develop.ut_metadata.get_source_definition_line('UT3_TESTER', 'TEST_PACKAGE1', 4);
    ut.expect(l_actual).to_equal(l_expect);

    l_expect := trim(substrb(q'[      /* long comment 3999 and linebreak]'||rpad('*', 4000, '*'), 1, 3997)||'*/'||c_lf);
    l_actual := ut3_develop.ut_metadata.get_source_definition_line('UT3_TESTER', 'TEST_PACKAGE1', 5);
    ut.expect(l_actual).to_equal(l_expect);

    l_expect := 'dbms_output.put_line(''test_max_length called.'');'||c_lf;
    l_actual := ut3_develop.ut_metadata.get_source_definition_line('UT3_TESTER', 'TEST_PACKAGE1', 6);
    ut.expect(l_actual).to_equal(l_expect);
  end;

  procedure test_over_varchar2_limit_trim_first_4000_crlf is
    l_actual varchar2(32767);
    l_expect varchar2(32767);
  begin
    l_expect := trim(substrb(q'[      /* long comment over 4000 characters 1]'||rpad('*', 8000, '*')||'*/'||c_crlf, 1, 4000));
    l_actual := ut3_develop.ut_metadata.get_source_definition_line('UT3_TESTER', 'TEST_PACKAGE1', 4);
    ut.expect(l_actual).to_equal(l_expect);

    l_expect := trim(substrb(q'[      /* long comment 3999 and linebreak]'||rpad('*', 4000, '*'), 1, 3997)||'*/'||c_cr);
    l_actual := ut3_develop.ut_metadata.get_source_definition_line('UT3_TESTER', 'TEST_PACKAGE1', 5);
    ut.expect(l_actual).to_equal(l_expect);

    l_expect := 'dbms_output.put_line(''test_max_length called.'');'||c_crlf;
    l_actual := ut3_develop.ut_metadata.get_source_definition_line('UT3_TESTER', 'TEST_PACKAGE1', 6);
    ut.expect(l_actual).to_equal(l_expect);
  end;

  procedure test_over_varchar2_limit_trim_first_4000_cr
  is
    l_actual varchar2(32767);
    l_expect varchar2(32767);
  begin
    l_expect := trim(substrb(q'[      /* long comment over 4000 characters 1]'||rpad('*', 8000, '*')||'*/'||c_cr, 1, 4000));
    l_actual := ut3_develop.ut_metadata.get_source_definition_line('UT3_TESTER', 'TEST_PACKAGE1', 4);
    ut.expect(l_actual).to_equal(l_expect);

    l_expect := trim(substrb(q'[      /* long comment 3999 and linebreak]'||rpad('*', 4000, '*'), 1, 3997)||'*/'||c_cr);
    l_actual := ut3_develop.ut_metadata.get_source_definition_line('UT3_TESTER', 'TEST_PACKAGE1', 5);
    ut.expect(l_actual).to_equal(l_expect);

    l_expect := 'ut.expect(l_actual).to_equal(l_expect);'||c_cr;
    l_actual := ut3_develop.ut_metadata.get_source_definition_line('UT3_TESTER', 'TEST_PACKAGE1', 6);
    ut.expect(l_actual).to_equal(l_expect);
  end;

  procedure clear_cache is
  begin
    ut3_develop.ut_metadata.reset_source_definition_cache();
  end;

  procedure drop_test_package is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package test_package1';
  end;

  procedure create_test_package_lf is
    pragma autonomous_transaction;
  begin
    execute immediate c_pks_lf;
    execute immediate c_pkg_lf;
  end;

  procedure create_test_package_crlf is
    pragma autonomous_transaction;
  begin
    execute immediate replace(c_pks_lf, c_lf, c_crlf);
    execute immediate replace(c_pkg_lf, c_lf, c_crlf);
  end;

  procedure create_test_package_cr is
    pragma autonomous_transaction;
  begin
    execute immediate replace(c_pks_lf, c_lf, c_cr);
    execute immediate replace(c_pkg_lf, c_lf, c_cr);
  end;

end;
/