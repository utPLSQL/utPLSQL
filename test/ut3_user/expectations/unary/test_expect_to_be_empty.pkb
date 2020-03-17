create or replace package body test_expect_to_be_empty is

  procedure cleanup_expectations is
  begin
    ut3_tester_helper.main_helper.clear_expectations( );
  end;
 procedure success_be_empty_cursor is
    l_cursor sys_refcursor;
  begin
    --Arrange
    open l_cursor for select * from dual where 1 = 2;
    --Act
    ut3_develop.ut.expect(l_cursor).to_be_empty;
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure fail_be_empty_cursor is
    l_cursor sys_refcursor;
  begin
    --Arrange
    open l_cursor for select * from dual;
    --Act
    ut3_develop.ut.expect(l_cursor).to_be_empty;
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure fail_be_empty_cursor_report is
    l_cursor sys_refcursor;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    open l_cursor for select * from dual;
    --Act
    ut3_develop.ut.expect(l_cursor).to_be_empty;

    l_expected_message := q'[Actual: (refcursor [ count = 1 ])%
    <ROW><DUMMY>X</DUMMY></ROW>%
 was expected to be empty%]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);

    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure success_not_be_empty_cursor is
    l_cursor sys_refcursor;
  begin
    --Arrange
    open l_cursor for select * from dual;
    --Act
    ut3_develop.ut.expect(l_cursor).not_to_be_empty;
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure fail_not_be_empty_cursor is
    l_cursor sys_refcursor;
  begin
    --Arrange
    open l_cursor for select * from dual where 1 = 2;
    --Act
    ut3_develop.ut.expect(l_cursor).not_to_be_empty;
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure success_be_empty_collection is
    l_actual anydata;
  begin
    --Arrange
    l_actual := anydata.convertcollection(ora_mining_varchar2_nt());
    -- Act
    ut3_develop.ut.expect(l_actual).to_be_empty();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure fail_be_empty_collection is
    l_actual anydata;
  begin
    --Arrange
    l_actual := anydata.convertcollection(ora_mining_varchar2_nt('a'));
    -- Act
    ut3_develop.ut.expect(l_actual).to_be_empty();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure success_not_be_empty_coll is
    l_actual anydata;
  begin
    --Arrange
    l_actual := anydata.convertcollection(ora_mining_varchar2_nt('a'));
    -- Act
    ut3_develop.ut.expect(l_actual).not_to_be_empty();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure fail_not_be_empty_collection is
    l_actual anydata;
  begin
    --Arrange
    l_actual := anydata.convertcollection(ora_mining_varchar2_nt());
    -- Act
    ut3_develop.ut.expect(l_actual).not_to_be_empty();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure fail_be_empty_null_collection is
    l_actual anydata;
    l_data   ora_mining_varchar2_nt;
  begin
    --Arrange
    l_actual := anydata.convertcollection(l_data);
    -- Act
    ut3_develop.ut.expect(l_actual).to_be_empty();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure fail_not_be_empty_null_coll is
    l_actual anydata;
    l_data   ora_mining_varchar2_nt;
  begin
    --Arrange
    l_actual := anydata.convertcollection(l_data);
    -- Act
    ut3_develop.ut.expect(l_actual).not_to_be_empty();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure fail_be_empty_object is
    l_actual anydata;
  begin
    --Arrange
    l_actual := anydata.convertObject(ut3_tester_helper.test_dummy_number(1));
    -- Act
    ut3_develop.ut.expect(l_actual).to_be_empty();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure fail_be_empty_null_object is
    l_actual anydata;
    l_data   ut3_tester_helper.test_dummy_number;
  begin
    --Arrange
    l_actual := anydata.convertObject(l_data);
    -- Act
    ut3_develop.ut.expect(l_actual).to_be_empty();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure fail_be_empty_number is
  begin
    -- Act
    ut3_develop.ut.expect( 1 ).to_( ut3_develop.be_empty() );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;
  
  /**
  * https://docs.oracle.com/en/database/oracle/oracle-database/18/adobj/declaring-initializing-objects-in-plsql.html#GUID-23135172-82E2-4C3E-800D-E584B43B578E
  * User-defined types, just like collections, are atomically null, until you initialize the object by calling the constructor for its object type. That is, the object itself is null, not just its attributes. 
  */
  procedure fail_not_be_empty_object is
    l_actual anydata;
  begin
    --Arrange
    l_actual := anydata.convertObject(ut3_tester_helper.test_dummy_number(1));
    -- Act
    ut3_develop.ut.expect(l_actual).not_to_be_empty();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure fail_not_be_empty_null_object is
    l_actual anydata;
    l_data   ut3_tester_helper.test_dummy_number;
  begin
    --Arrange
    l_actual := anydata.convertObject(l_data);
    -- Act
    ut3_develop.ut.expect(l_actual).not_to_be_empty();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure fail_not_be_empty_number is
  begin
    -- Act
    ut3_develop.ut.expect( 1 ).not_to( ut3_develop.be_empty() );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure success_be_empty_clob is
    begin
      -- Act
      ut3_develop.ut.expect( empty_clob() ).to_( ut3_develop.be_empty() );
      --Assert
      ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
    end;

  procedure fail_be_empty_clob is
    begin
      -- Act
      ut3_develop.ut.expect( to_clob(' ') ).to_( ut3_develop.be_empty() );
      --Assert
      ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
    end;

  procedure success_be_empty_blob is
    begin
      -- Act
      ut3_develop.ut.expect( empty_blob() ).to_( ut3_develop.be_empty() );
      --Assert
      ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
    end;

  procedure fail_be_empty_blob is
    begin
      -- Act
      ut3_develop.ut.expect( to_blob('AA') ).to_( ut3_develop.be_empty() );
      --Assert
      ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
    end;


  procedure fail_not_be_empty_clob is
  begin
    -- Act
    ut3_develop.ut.expect( empty_clob() ).not_to( ut3_develop.be_empty() );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure success_not_be_empty_clob is
  begin
    -- Act
    ut3_develop.ut.expect( to_clob(' ') ).not_to( ut3_develop.be_empty() );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure fail_not_be_empty_blob is
  begin
    -- Act
    ut3_develop.ut.expect( empty_blob() ).not_to( ut3_develop.be_empty() );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure success_not_be_empty_blob is
  begin
    -- Act
    ut3_develop.ut.expect( to_blob('AA') ).not_to( ut3_develop.be_empty() );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

end;
/