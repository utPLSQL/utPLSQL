create or replace package body test_expect_to_be_empty is

  procedure cleanup_expectations is
  begin
    expectations.cleanup_expectations( );
  end;

  procedure success_be_empty_cursor is
    l_cursor sys_refcursor;
  begin
    --Arrange
    open l_cursor for select * from dual where 1 = 2;
    --Act
    ut3.ut.expect(l_cursor).to_be_empty;
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure fail_be_empty_cursor is
    l_cursor sys_refcursor;
  begin
    --Arrange
    open l_cursor for select * from dual;
    --Act
    ut3.ut.expect(l_cursor).to_be_empty;
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure success_not_be_empty_cursor is
    l_cursor sys_refcursor;
  begin
    --Arrange
    open l_cursor for select * from dual;
    --Act
    ut3.ut.expect(l_cursor).not_to_be_empty;
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure fail_not_be_empty_cursor is
    l_cursor sys_refcursor;
  begin
    --Arrange
    open l_cursor for select * from dual where 1 = 2;
    --Act
    ut3.ut.expect(l_cursor).not_to_be_empty;
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure success_be_empty_collection is
    l_actual anydata;
  begin
    --Arrange
    l_actual := anydata.convertcollection(ora_mining_varchar2_nt());
    -- Act
    ut3.ut.expect(l_actual).to_be_empty();
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure fail_be_empty_collection is
    l_actual anydata;
  begin
    --Arrange
    l_actual := anydata.convertcollection(ora_mining_varchar2_nt('a'));
    -- Act
    ut3.ut.expect(l_actual).to_be_empty();
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure success_not_be_empty_coll is
    l_actual anydata;
  begin
    --Arrange
    l_actual := anydata.convertcollection(ora_mining_varchar2_nt('a'));
    -- Act
    ut3.ut.expect(l_actual).not_to_be_empty();
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure fail_not_be_empty_collection is
    l_actual anydata;
  begin
    --Arrange
    l_actual := anydata.convertcollection(ora_mining_varchar2_nt());
    -- Act
    ut3.ut.expect(l_actual).not_to_be_empty();
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_be_empty_null_collection is
    l_actual anydata;
    l_data   ora_mining_varchar2_nt;
  begin
    --Arrange
    l_actual := anydata.convertcollection(l_data);
    -- Act
    ut3.ut.expect(l_actual).to_be_empty();
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_not_be_empty_null_coll is
    l_actual anydata;
    l_data   ora_mining_varchar2_nt;
  begin
    --Arrange
    l_actual := anydata.convertcollection(l_data);
    -- Act
    ut3.ut.expect(l_actual).not_to_be_empty();
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_be_empty_object is
    l_actual anydata;
  begin
    --Arrange
    l_actual := anydata.convertObject(ut3.ut_data_value_number(1));
    -- Act
    ut3.ut.expect(l_actual).to_be_empty();
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_be_empty_null_object is
    l_actual anydata;
    l_data   ut3.ut_data_value_number;
  begin
    --Arrange
    l_actual := anydata.convertObject(l_data);
    -- Act
    ut3.ut.expect(l_actual).to_be_empty();
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_be_empty_number is
  begin
    -- Act
    ut3.ut.expect( 1 ).to_be_empty();
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_not_be_empty_object is
    l_actual anydata;
  begin
    --Arrange
    l_actual := anydata.convertObject(ut3.ut_data_value_number(1));
    -- Act
    ut3.ut.expect(l_actual).not_to_be_empty();
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_not_be_empty_null_object is
    l_actual anydata;
    l_data   ut3.ut_data_value_number;
  begin
    --Arrange
    l_actual := anydata.convertObject(l_data);
    -- Act
    ut3.ut.expect(l_actual).not_to_be_empty();
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_not_be_empty_number is
  begin
    -- Act
    ut3.ut.expect( 1 ).not_to_be_empty();
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

end;
/