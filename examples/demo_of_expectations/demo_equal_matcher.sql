create or replace type demo_department as object(
  dept_name varchar2(30)
)
/

create or replace type demo_department_new as object(
  dept_name varchar2(30)
)
/

create or replace type demo_departments as table of demo_department
/

create or replace package demo_equal_matcher as

  -- %suite
  -- %displayname(Equal matcher)
  -- %suitepath(org.utplsql.v3.demo.matchers)

  -- TODO this should go into context(compare_objects, Comparing objects)
  -- %context(compare_objects, Comparing objects)

    -- %test
    -- %displayname(Gives success when comparing identical objects containing identical data)
    procedure object_compare_success;

    -- %test
    -- %displayname(Gives failure when comparing to a null actual)
    procedure object_compare_null_actual;

    -- %test
    -- %displayname(Gives failure when comparing to a null expected)
    procedure object_compare_null_expected;

    -- %test
    -- %displayname(Gives success when comparing null actual to a null expected)
    procedure object_compare_null_both_ok;

    -- %test
    -- %displayname(Gives failure when comparing null actual to a null expected, setting null equal to false)
    procedure object_compare_null_both_fail;

    -- %test
    -- %displayname(Gives failure when comparing identical objects containing different data)
    procedure object_compare_different_data;

    -- %test
    -- %displayname(Gives failure when comparing different objects containing identical data)
    procedure object_compare_different_type;

  -- %end_context

end;
/

create or replace package body demo_equal_matcher as

  procedure object_compare_success is
    l_expected demo_department;
    l_actual   demo_department;
  begin
    --setup the expected
    l_expected := demo_department('Sales');
    --get the actual data
    l_actual   := demo_department('Sales');
    ut.expect(anydata.convertObject(l_actual)).to_(equal(anydata.convertObject(l_expected))
    );
  end;

  procedure object_compare_null_actual is
    l_expected demo_department;
    l_actual   demo_department;
  begin
    --setup the expected
    l_expected := demo_department('Sales');
    --get the actual data
    -- nothing done
    ut.expect(anydata.convertObject(l_actual)).to_(equal(anydata.convertObject(l_expected))
    );
  end;

  procedure object_compare_null_expected is
    l_expected demo_department;
    l_actual   demo_department;
  begin
    l_actual   := demo_department('Sales');
    ut.expect(anydata.convertObject(l_actual)).to_(equal(anydata.convertObject(l_expected))
    );
  end;

  procedure object_compare_null_both_ok is
    l_expected demo_department;
    l_actual   demo_department;
  begin
    ut.expect(anydata.convertObject(l_actual)).to_(equal(anydata.convertObject(l_expected))
    );
  end;

  procedure object_compare_null_both_fail is
    l_expected demo_department;
    l_actual   demo_department;
  begin
    ut.expect(anydata.convertObject(l_actual)).to_(equal(anydata.convertObject(l_expected),false)
    );
  end;


  procedure object_compare_different_data is
    l_expected demo_department;
    l_actual   demo_department;
  begin
    --setup the expected
    l_expected := demo_department('Sales');
    --get the actual data
    l_actual   := demo_department('HR');
    ut.expect(anydata.convertObject(l_actual)).to_(equal(anydata.convertObject(l_expected))
      );
  end;

  procedure object_compare_different_type is
    l_expected demo_department;
    l_actual   demo_department_new;
  begin
    --setup the expected
    l_expected := demo_department('Sales');
    --get the actual data
    l_actual   := demo_department_new('Sales');
    ut.expect(anydata.convertObject(l_actual)).to_(equal(anydata.convertObject(l_expected))
    );
  end;

end;
/
