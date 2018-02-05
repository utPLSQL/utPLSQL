create or replace package body test_expect_to_have_count is

  procedure cleanup_expectations is
  begin
    expectations.cleanup_expectations( );
  end;

  procedure success_have_count_cursor is
    l_cursor sys_refcursor;
  begin
    --Arrange
    open l_cursor for select * from dual connect by level <= 11;
    --Act
    ut3.ut.expect(l_cursor).to_have_count(11);
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure fail_have_count_cursor is
    l_cursor sys_refcursor;
  begin
    --Arrange
    open l_cursor for select * from dual where 0=1;
    --Act
    ut3.ut.expect(l_cursor).to_have_count(1);
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_have_count_cursor_report is
    l_cursor sys_refcursor;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_cursor for select * from dual;
    --Act
    ut3.ut.expect(l_cursor).to_have_count(2);

    l_expected_message := q'[Actual: (refcursor [ count = 1 ]) was expected to have [ count = 2 ]%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;

    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure success_not_have_count_cursor is
    l_cursor sys_refcursor;
  begin
    --Arrange
    open l_cursor for select * from dual;
    --Act
    ut3.ut.expect(l_cursor).not_to_have_count(2);
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure fail_not_have_count_cursor is
    l_cursor sys_refcursor;
  begin
    --Arrange
    open l_cursor for select * from dual where 1 = 2;
    --Act
    ut3.ut.expect(l_cursor).not_to_have_count(0);
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure success_have_count_collection is
    l_actual anydata;
  begin
    --Arrange
    l_actual := anydata.convertcollection(ora_mining_varchar2_nt());
    -- Act
    ut3.ut.expect(l_actual).to_have_count(0);
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure fail_have_count_collection is
    l_actual anydata;
  begin
    --Arrange
    l_actual := anydata.convertcollection(ora_mining_varchar2_nt('a'));
    -- Act
    ut3.ut.expect(l_actual).to_have_count(0);
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure success_not_have_count_coll is
    l_actual anydata;
  begin
    --Arrange
    l_actual := anydata.convertcollection(ora_mining_varchar2_nt('a'));
    -- Act
    ut3.ut.expect(l_actual).not_to_have_count(2);
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure fail_not_have_count_coll is
    l_actual anydata;
  begin
    --Arrange
    l_actual := anydata.convertcollection(ora_mining_varchar2_nt());
    -- Act
    ut3.ut.expect(l_actual).not_to_have_count(0);
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_have_count_null_coll is
    l_actual anydata;
    l_data   ora_mining_varchar2_nt;
  begin
    --Arrange
    l_actual := anydata.convertcollection(l_data);
    -- Act
    ut3.ut.expect(l_actual).to_have_count(0);
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_not_have_count_null_coll is
    l_actual anydata;
    l_data   ora_mining_varchar2_nt;
  begin
    --Arrange
    l_actual := anydata.convertcollection(l_data);
    -- Act
    ut3.ut.expect(l_actual).not_to_have_count(0);
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_have_count_object is
    l_actual anydata;
  begin
    --Arrange
    l_actual := anydata.convertObject(ut3.ut_data_value_number(1));
    -- Act
    ut3.ut.expect(l_actual).to_have_count(0);
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_have_count_null_object is
    l_actual anydata;
    l_data   ut3.ut_data_value_number;
  begin
    --Arrange
    l_actual := anydata.convertObject(l_data);
    -- Act
    ut3.ut.expect(l_actual).to_have_count(0);
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_have_count_number is
  begin
    -- Act
    ut3.ut.expect( 1 ).to_( ut3.have_count(0) );
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_not_have_count_object is
    l_actual anydata;
  begin
    --Arrange
    l_actual := anydata.convertObject(ut3.ut_data_value_number(1));
    -- Act
    ut3.ut.expect(l_actual).not_to_have_count(0);
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_not_have_count_null_obj is
    l_actual anydata;
    l_data   ut3.ut_data_value_number;
  begin
    --Arrange
    l_actual := anydata.convertObject(l_data);
    -- Act
    ut3.ut.expect(l_actual).not_to_have_count(0);
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_not_have_count_number is
  begin
    -- Act
    ut3.ut.expect( 1 ).not_to( ut3.have_count(0) );
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

end;
/