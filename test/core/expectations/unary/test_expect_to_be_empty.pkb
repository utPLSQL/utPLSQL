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

  procedure fail_be_empty_cursor_report is
    l_cursor sys_refcursor;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_cursor for select * from dual;
    --Act
    ut3.ut.expect(l_cursor).to_be_empty;

    l_expected_message := q'[Actual: (refcursor [ count = 1 ])%
    <ROW><DUMMY>X</DUMMY></ROW>%
was expected to be empty%%]';
    l_actual_message := ut3.ut_expectation_processor.get_failed_expectations()(1).message;

    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
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
    ut3.ut.expect( 1 ).to_( ut3.be_empty() );
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;
  
  /**
  * https://docs.oracle.com/en/database/oracle/oracle-database/18/adobj/declaring-initializing-objects-in-plsql.html#GUID-23135172-82E2-4C3E-800D-E584B43B578E
  * User-defined types, just like collections, are atomically null, until you initialize the object by calling the constructor for its object type. That is, the object itself is null, not just its attributes. 
  */
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
    ut3.ut.expect( 1 ).not_to( ut3.be_empty() );
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure success_be_empty_clob is
    begin
      -- Act
      ut3.ut.expect( empty_clob() ).to_( ut3.be_empty() );
      --Assert
      ut.expect(expectations.failed_expectations_data()).to_be_empty();
    end;

  procedure fail_be_empty_clob is
    begin
      -- Act
      ut3.ut.expect( to_clob(' ') ).to_( ut3.be_empty() );
      --Assert
      ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
    end;

  procedure success_be_empty_blob is
    begin
      -- Act
      ut3.ut.expect( empty_blob() ).to_( ut3.be_empty() );
      --Assert
      ut.expect(expectations.failed_expectations_data()).to_be_empty();
    end;

  procedure fail_be_empty_blob is
    begin
      -- Act
      ut3.ut.expect( to_blob('AA') ).to_( ut3.be_empty() );
      --Assert
      ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
    end;


  procedure fail_not_be_empty_clob is
  begin
    -- Act
    ut3.ut.expect( empty_clob() ).not_to( ut3.be_empty() );
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure success_not_be_empty_clob is
  begin
    -- Act
    ut3.ut.expect( to_clob(' ') ).not_to( ut3.be_empty() );
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure fail_not_be_empty_blob is
  begin
    -- Act
    ut3.ut.expect( empty_blob() ).not_to( ut3.be_empty() );
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure success_not_be_empty_blob is
  begin
    -- Act
    ut3.ut.expect( to_blob('AA') ).not_to( ut3.be_empty() );
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

end;
/