create or replace package body test_expectation_anydata is

  g_test_expected anydata;
  g_test_actual   anydata;

  procedure cleanup_expectations is
  begin
    ut3_tester_helper.main_helper.clear_expectations( );
  end;

  procedure cleanup is
  begin
    g_test_expected := null;
    g_test_actual   := null;
    cleanup_expectations();
  end;

  procedure fail_on_different_type_null is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    g_test_expected := anydata.convertObject( cast(null as ut3_tester_helper.test_dummy_object) );
    g_test_actual   := anydata.convertObject( cast(null as ut3_tester_helper.other_dummy_object) );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    l_expected_message := q'[%Actual (ut3_tester_helper.other_dummy_object) cannot be compared to Expected (ut3_tester_helper.test_dummy_object) using matcher 'equal'.]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure fail_on_different_type is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_object(1, 'A', '0') );
    g_test_actual   := anydata.convertObject( ut3_tester_helper.other_dummy_object(1, 'A', '0') );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    l_expected_message := q'[%Actual (ut3_tester_helper.other_dummy_object) cannot be compared to Expected (ut3_tester_helper.test_dummy_object) using matcher 'equal'.]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure fail_on_different_object_data is
  begin
    --Arrange
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_object(1, 'A', '0') );
    g_test_actual   := anydata.convertObject( ut3_tester_helper.test_dummy_object(1, null, '0') );
    --Act
    ut3_develop.ut.expect( g_test_actual ).not_to_equal( g_test_expected );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure fail_on_one_object_null is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);  
  begin
    --Arrange
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_object(1, 'A', '0') );
    g_test_actual   := anydata.convertObject( cast(null as ut3_tester_helper.test_dummy_object) );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    l_expected_message := q'[%Actual: ut3_tester_helper.test_dummy_object was expected to equal: ut3_tester_helper.test_dummy_object
%Diff:
%Rows: [ 1 differences ]
%Row No. 1 - Missing:  <TEST_DUMMY_OBJECT><ID>1</ID><name>A</name><Value>0</Value></TEST_DUMMY_OBJECT>]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
      
  end;

  procedure fail_on_collection_vs_object is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_object(1, 'A', '0') );
    g_test_actual   := anydata.convertCollection( ut3_tester_helper.test_dummy_object_list(ut3_tester_helper.test_dummy_object(1, 'A', '0')) );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    l_expected_message := q'[%Actual (ut3_tester_helper.test_dummy_object_list) cannot be compared to Expected (ut3_tester_helper.test_dummy_object) using matcher 'equal'.]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure fail_on_null_vs_empty_coll is
    l_null_list ut3_tester_helper.test_dummy_object_list;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( ut3_tester_helper.test_dummy_object_list() );
    g_test_actual   := anydata.convertCollection( l_null_list );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    l_expected_message := q'[%Actual: ut3_tester_helper.test_dummy_object_list [ null ] was expected to equal: ut3_tester_helper.test_dummy_object_list [ count = 0 ]]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
      
  end;
  
  procedure fail_on_one_collection_null is
    l_null_list ut3_tester_helper.test_dummy_object_list;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( ut3_tester_helper.test_dummy_object_list(ut3_tester_helper.test_dummy_object(1, 'A', '0')) );
    g_test_actual   := anydata.convertCollection( l_null_list );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    l_expected_message := q'[%Actual: ut3_tester_helper.test_dummy_object_list [ null ] was expected to equal: ut3_tester_helper.test_dummy_object_list [ count = 1 ]
%Diff:
%Rows: [ 1 differences ]
%Row No. 1 - Missing:  <TEST_DUMMY_OBJECT><ID>1</ID><name>A</name><Value>0</Value></TEST_DUMMY_OBJECT>]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure fail_on_one_collection_empty is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( ut3_tester_helper.test_dummy_object_list(ut3_tester_helper.test_dummy_object(1, 'A', '0')) );
    g_test_actual   := anydata.convertCollection( ut3_tester_helper.test_dummy_object_list() );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    l_expected_message := q'[%Actual: ut3_tester_helper.test_dummy_object_list [ count = 0 ] was expected to equal: ut3_tester_helper.test_dummy_object_list [ count = 1 ]
%Diff:
%Rows: [ 1 differences ]
%Row No. 1 - Missing:  <TEST_DUMMY_OBJECT><ID>1</ID><name>A</name><Value>0</Value></TEST_DUMMY_OBJECT>]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
      
  end;

  procedure fail_on_different_coll_data is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
    l_obj ut3_tester_helper.test_dummy_object := ut3_tester_helper.test_dummy_object(1, 'A', '0');
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( ut3_tester_helper.test_dummy_object_list(l_obj) );
    g_test_actual   := anydata.convertCollection( ut3_tester_helper.test_dummy_object_list(l_obj, l_obj) );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    l_expected_message := q'[%Actual: ut3_tester_helper.test_dummy_object_list [ count = 2 ] was expected to equal: ut3_tester_helper.test_dummy_object_list [ count = 1 ]
%Diff:
%Rows: [ 1 differences ]
%Row No. 2 - Extra:    <TEST_DUMMY_OBJECT><ID>1</ID><name>A</name><Value>0</Value></TEST_DUMMY_OBJECT>]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  --%test(Gives success when both anydata are NULL)
  procedure success_on_both_anydata_null is
    --Arrange
    l_null_anydata anydata;
  begin
    --Act
    ut3_develop.ut.expect( l_null_anydata ).to_equal( l_null_anydata );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure success_on_both_object_null is
    --Arrange
    l_null_object ut3_tester_helper.test_dummy_object;
    l_anydata     anydata := anydata.convertObject(l_null_object);
  begin
    --Act
    ut3_develop.ut.expect( l_anydata ).to_equal( l_anydata );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure success_on_both_coll_null is
    --Arrange
    l_null_collection ut3_tester_helper.test_dummy_object_list;
    l_anydata         anydata := anydata.convertCollection(l_null_collection);
    begin
      --Act
      ut3_develop.ut.expect( l_anydata ).to_equal( l_anydata );
      --Assert
      ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure success_on_same_coll_data is
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( ut3_tester_helper.test_dummy_object_list(ut3_tester_helper.test_dummy_object(1, 'A', '0')) );
    g_test_actual   := anydata.convertCollection( ut3_tester_helper.test_dummy_object_list(ut3_tester_helper.test_dummy_object(1, 'A', '0')) );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure fail_on_coll_different_order is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
    l_first_obj  ut3_tester_helper.test_dummy_object := ut3_tester_helper.test_dummy_object(1, 'A', '0');
    l_second_obj ut3_tester_helper.test_dummy_object := ut3_tester_helper.test_dummy_object(2, 'b', '1');
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( ut3_tester_helper.test_dummy_object_list(l_first_obj, l_second_obj) );
    g_test_actual   := anydata.convertCollection( ut3_tester_helper.test_dummy_object_list(l_second_obj, l_first_obj) );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure success_on_same_object_data is
  begin
    --Arrange
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_object(1, 'A', '0') );
    g_test_actual   := anydata.convertObject( ut3_tester_helper.test_dummy_object(1, 'A', '0') );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure exclude_attributes_as_list is
    l_list ut3_develop.ut_varchar2_list;
  begin
    --Arrange
    l_list := ut3_develop.ut_varchar2_list('Value','/ID');
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_object(id=>1, "name"=>'A',"Value"=>'0') );
    g_test_actual   := anydata.convertObject( ut3_tester_helper.test_dummy_object(id=>3, "name"=>'A',"Value"=>'1') );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected, a_exclude=> l_list );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure exclude_attributes_as_csv is
    l_list varchar2(100);
  begin
    --Arrange
    l_list := 'Value,ID';
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_object(id=>1, "name"=>'A',"Value"=>'0') );
    g_test_actual   := anydata.convertObject( ut3_tester_helper.test_dummy_object(id=>2, "name"=>'A',"Value"=>'1') );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected, a_exclude=> l_list );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure exclude_attributes_xpath is
    l_xpath varchar2(100);
  begin
    --Arrange
    l_xpath := '//Value|//ID';
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_object(id=>1, "name"=>'A',"Value"=>'0') );
    g_test_actual   := anydata.convertObject( ut3_tester_helper.test_dummy_object(id=>2, "name"=>'A',"Value"=>'1') );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected, a_exclude=> l_xpath );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure exclude_ignores_invalid_attrib is
    l_exclude varchar2(100);
  begin
    --Arrange
    l_exclude := 'BadAttributeName';
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_object(id=>1, "name"=>'A',"Value"=>'0') );
    g_test_actual   := anydata.convertObject( ut3_tester_helper.test_dummy_object(id=>1, "name"=>'A',"Value"=>'0') );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected, a_exclude=> l_exclude );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure include_attributes_as_list is
    l_list ut3_develop.ut_varchar2_list;
  begin
    --Arrange
    l_list := ut3_develop.ut_varchar2_list('Value','ID');
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_object(id=>1, "name"=>'A',"Value"=>'0') );
    g_test_actual   := anydata.convertObject( ut3_tester_helper.test_dummy_object(id=>1, "name"=>'b',"Value"=>'0') );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected ).include( l_list );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure include_attributes_as_csv is
    l_xpath          varchar2(100);
  begin
    --Arrange
    l_xpath := 'key,ID';
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_object(id=>1, "name"=>'A',"Value"=>'0') );
    g_test_actual   := anydata.convertObject( ut3_tester_helper.test_dummy_object(id=>1, "name"=>'A',"Value"=>'1') );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected ).include( l_xpath );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure include_attributes_xpath is
    l_xpath varchar2(100);
  begin
    --Arrange
    l_xpath := '//key|//ID';
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_object(id=>1, "name"=>'A',"Value"=>'0') );
    g_test_actual   := anydata.convertObject( ut3_tester_helper.test_dummy_object(id=>1, "name"=>'A',"Value"=>'1') );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected ).include( l_xpath );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure include_ignores_invalid_attrib is
    l_include varchar2(100);
  begin
    --Arrange
    l_include := ' BadAttributeName, ID ';
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_object(id=>1, "name"=>'B',"Value"=>'0') );
    g_test_actual   := anydata.convertObject( ut3_tester_helper.test_dummy_object(id=>1, "name"=>'A',"Value"=>'1') );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected ).include( l_include );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure include_exclude_attributes_csv is
    l_exclude varchar2(100);
    l_include varchar2(100);
  begin
    --Arrange
    l_include := 'key,ID,Value';
    l_exclude := '//key|//Value';
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_object(id=>1, "name"=>'B',"Value"=>'0') );
    g_test_actual   := anydata.convertObject( ut3_tester_helper.test_dummy_object(id=>1, "name"=>'A',"Value"=>'1') );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected ).exclude( l_exclude ).include( l_include );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure include_exclude_attrib_list is
    l_exclude ut3_develop.ut_varchar2_list;
    l_include ut3_develop.ut_varchar2_list;
    l_expected varchar2(32767);
    l_actual   varchar2(32767);
  begin
    --Arrange
    l_include := ut3_develop.ut_varchar2_list('key','ID','Value');
    l_exclude := ut3_develop.ut_varchar2_list('key','Value');
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_object(id=>1, "name"=>'B',"Value"=>'0') );
    g_test_actual   := anydata.convertObject( ut3_tester_helper.test_dummy_object(id=>1, "name"=>'A',"Value"=>'1') );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected ).exclude( l_exclude ).include( l_include );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure reports_diff_attribute is
    l_expected varchar2(32767);
    l_actual   varchar2(32767);
  begin
    --Arrange
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_object(1, 'A', '0') );
    g_test_actual   := anydata.convertObject( ut3_tester_helper.test_dummy_object(1, NULL, '0') );
    l_expected := q'[Actual: ut3_tester_helper.test_dummy_object was expected to equal: ut3_tester_helper.test_dummy_object
Diff:
Rows: [ 1 differences ]
  Row No. 1 - Actual:   <name/>
  Row No. 1 - Expected: <name>A</name>]';
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    l_actual := ut3_tester_helper.main_helper.get_failed_expectations(1);
    ut.expect(l_actual).to_be_like(l_expected);
  end;


  procedure reports_diff_structure is
    l_obj      ut3_tester_helper.test_dummy_object := ut3_tester_helper.test_dummy_object(1, 'A', '0');
    l_expected varchar2(32767);
    l_actual   varchar2(32767);
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( ut3_tester_helper.test_dummy_object_list(l_obj) );
    g_test_actual   := anydata.convertCollection( ut3_tester_helper.test_dummy_object_list(l_obj, l_obj) );
    l_expected := q'[Actual: ut3_tester_helper.test_dummy_object_list [ count = 2 ] was expected to equal: ut3_tester_helper.test_dummy_object_list [ count = 1 ]
Diff:
Rows: [ 1 differences ]
  Row No. 2 - Extra:    <TEST_DUMMY_OBJECT><ID>1</ID><name>A</name><Value>0</Value></TEST_DUMMY_OBJECT>]';
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    l_actual := ut3_tester_helper.main_helper.get_failed_expectations(1);
    ut.expect(l_actual).to_be_like(l_expected);
  end;

  function get_anydata return anydata is
  begin
    return anydata.convertObject( ut3_tester_helper.test_dummy_object(1, 'B', '0') );
  end;

  procedure deprec_to_equal_excl_varch is
  begin
    --Act
    ut3_develop.ut.expect(get_anydata()).to_equal(get_anydata(), a_exclude => 'A_COLUMN,Some_Col');
    --Assert
    ut.expect(cardinality(ut3_tester_helper.main_helper.get_warnings())).to_equal(1);
    ut.expect(ut3_tester_helper.main_helper.get_warnings()(1)).to_be_like('The syntax: "%" is deprecated.%');
  end;

  procedure deprec_to_equal_excl_list is
  begin
    --Act
    ut3_develop.ut.expect(get_anydata()).to_equal(get_anydata(), a_exclude => ut3_develop.ut_varchar2_list('A_COLUMN','Some_Col'));
    --Assert
    ut.expect(cardinality(ut3_tester_helper.main_helper.get_warnings())).to_equal(1);
    ut.expect(ut3_tester_helper.main_helper.get_warnings()(1)).to_be_like('The syntax: "%" is deprecated.%');
  end;

  procedure deprec_not_to_equal_excl_varch is
  begin
    --Act
    ut3_develop.ut.expect(get_anydata()).not_to_equal(get_anydata(), a_exclude => 'A_COLUMN,Some_Col');
    --Assert
    ut.expect(cardinality(ut3_tester_helper.main_helper.get_warnings())).to_equal(1);
    ut.expect(ut3_tester_helper.main_helper.get_warnings()(1)).to_be_like('The syntax: "%" is deprecated.%');
  end;

  procedure deprec_not_to_equal_excl_list is
  begin
    --Act
    ut3_develop.ut.expect(get_anydata()).not_to_equal(get_anydata(), a_exclude => ut3_develop.ut_varchar2_list('A_COLUMN','Some_Col'));
    --Assert
    ut.expect(cardinality(ut3_tester_helper.main_helper.get_warnings())).to_equal(1);
    ut.expect(ut3_tester_helper.main_helper.get_warnings()(1)).to_be_like('The syntax: "%" is deprecated.%');
  end;

  procedure deprec_equal_excl_varch is
  begin
    --Act
    ut3_develop.ut.expect(get_anydata()).to_(ut3_develop.equal(get_anydata(), a_exclude => 'A_COLUMN,Some_Col'));
    --Assert
    ut.expect(cardinality(ut3_tester_helper.main_helper.get_warnings())).to_equal(1);
    ut.expect(ut3_tester_helper.main_helper.get_warnings()(1)).to_be_like('The syntax: "%" is deprecated.%');
  end;

  procedure deprec_equal_excl_list is
  begin
    --Act
    ut3_develop.ut.expect(get_anydata()).to_(ut3_develop.equal(get_anydata(), a_exclude => ut3_develop.ut_varchar2_list('A_COLUMN','Some_Col')));
    --Assert
    ut.expect(cardinality(ut3_tester_helper.main_helper.get_warnings())).to_equal(1);
    ut.expect(ut3_tester_helper.main_helper.get_warnings()(1)).to_be_like('The syntax: "%" is deprecated.%');
  end;

  procedure data_diff_on_atr_data_mismatch is
    l_actual           ut3_tester_helper.test_dummy_object_list;
    l_expected         ut3_tester_helper.test_dummy_object_list;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    select ut3_tester_helper.test_dummy_object( rownum, 'Something '||rownum, rownum)
      bulk collect into l_actual
      from dual connect by level <=2;
    select ut3_tester_helper.test_dummy_object( rownum, 'Something '||rownum, rownum)
      bulk collect into l_expected
      from dual connect by level <=2
     order by rownum desc;
    --Act
    ut3_develop.ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

    l_expected_message := q'[Actual: ut3_tester_helper.test_dummy_object_list [ count = 2 ] was expected to equal: ut3_tester_helper.test_dummy_object_list [ count = 2 ]
Diff:
Rows: [ 2 differences ]
  Row No. 1 - Actual:   <ID>1</ID><name>Something 1</name><Value>1</Value>
  Row No. 1 - Expected: <ID>2</ID><name>Something 2</name><Value>2</Value>
  Row No. 2 - Actual:   <ID>2</ID><name>Something 2</name><Value>2</Value>
  Row No. 2 - Expected: <ID>1</ID><name>Something 1</name><Value>1</Value>]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure data_diff_on_20_rows_only is
    l_actual           ut3_tester_helper.test_dummy_object_list;
    l_expected         ut3_tester_helper.test_dummy_object_list;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    select ut3_tester_helper.test_dummy_object( rn, 'Something '||rn, rn1)
       bulk collect into l_actual
       from (select rownum * case when mod(rownum,2) = 0 then -1 else 1 end rn,
                    rownum * case when mod(rownum,4) = 0 then -1 else 1 end rn1
               from dual connect by level <=100);
    select ut3_tester_helper.test_dummy_object( rownum, 'Something '||rownum, rownum)
      bulk collect into l_expected
      from dual connect by level <=110;
    --Act
    ut3_develop.ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));

    l_expected_message := q'[Actual: ut3_tester_helper.test_dummy_object_list [ count = 100 ] was expected to equal: ut3_tester_helper.test_dummy_object_list [ count = 110 ]
Diff:
Rows: [ 60 differences, showing first 20 ]
  Row No. 2 - Actual:   <ID>-2</ID><name>Something -2</name>
  Row No. 2 - Expected: <ID>2</ID><name>Something 2</name>
  Row No. 4 - Actual:   <ID>-4</ID><name>Something -4</name><Value>-4</Value>
  Row No. 4 - Expected: <ID>4</ID><name>Something 4</name><Value>4</Value>
  %
  Row No. 38 - Actual:   <ID>-38</ID><name>Something -38</name>
  Row No. 38 - Expected: <ID>38</ID><name>Something 38</name>
  Row No. 40 - Actual:   <ID>-40</ID><name>Something -40</name><Value>-40</Value>
  Row No. 40 - Expected: <ID>40</ID><name>Something 40</name><Value>40</Value>]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure collection_include_list is
    l_actual           ut3_tester_helper.test_dummy_object_list;
    l_expected         ut3_tester_helper.test_dummy_object_list;
    l_list ut3_develop.ut_varchar2_list;
  begin
    l_list := ut3_develop.ut_varchar2_list('Value','ID');
    --Arrange
    select ut3_tester_helper.test_dummy_object( rownum, 'SomethingsDifferent '||rownum, rownum)
      bulk collect into l_actual
      from dual connect by level <=2;
    select ut3_tester_helper.test_dummy_object( rownum, 'Something '||rownum, rownum)
      bulk collect into l_expected
      from dual connect by level <=2;
    --Act
    ut3_develop.ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected)).include( l_list );

    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure collection_exclude_list is
    l_actual           ut3_tester_helper.test_dummy_object_list;
    l_expected         ut3_tester_helper.test_dummy_object_list;
    l_list ut3_develop.ut_varchar2_list;
  begin
    l_list := ut3_develop.ut_varchar2_list('Value','ID');
    --Arrange
    select ut3_tester_helper.test_dummy_object( rownum*2, 'Something '||rownum, rownum*2)
      bulk collect into l_actual
      from dual connect by level <=2;
    select ut3_tester_helper.test_dummy_object( rownum, 'Something '||rownum, rownum)
      bulk collect into l_expected
      from dual connect by level <=2;
    --Act
    ut3_develop.ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected)).exclude( l_list );

    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure collection_include_list_fail is
    l_actual           ut3_tester_helper.test_dummy_object_list;
    l_expected         ut3_tester_helper.test_dummy_object_list;
    l_list ut3_develop.ut_varchar2_list;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    l_list := ut3_develop.ut_varchar2_list('name');
    --Arrange
    select ut3_tester_helper.test_dummy_object( rownum, 'SomethingsDifferent '||rownum, rownum)
      bulk collect into l_actual
      from dual connect by level <=2;
    select ut3_tester_helper.test_dummy_object( rownum, 'Something '||rownum, rownum)
      bulk collect into l_expected
      from dual connect by level <=2;
    --Act
    ut3_develop.ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected)).include( l_list );

    l_expected_message := q'[%Actual: ut3_tester_helper.test_dummy_object_list [ count = 2 ] was expected to equal: ut3_tester_helper.test_dummy_object_list [ count = 2 ]
%Diff:
%Rows: [ 2 differences ]
%Row No. 1 - Actual:   <name>SomethingsDifferent 1</name>
%Row No. 1 - Expected: <name>Something 1</name>
%Row No. 2 - Actual:   <name>SomethingsDifferent 2</name>
%Row No. 2 - Expected: <name>Something 2</name>]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure array_same_data is
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( ut3_tester_helper.t_tab_varchar('A') );
    g_test_actual   := anydata.convertCollection(  ut3_tester_helper.t_tab_varchar('A')  );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure array_diff_data is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( ut3_tester_helper.t_tab_varchar('A') );
    g_test_actual   := anydata.convertCollection(  ut3_tester_helper.t_tab_varchar('B')  );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    l_expected_message := q'[%Actual: ut3_tester_helper.t_tab_varchar [ count = 1 ] was expected to equal: ut3_tester_helper.t_tab_varchar [ count = 1 ]
%Diff:
%Rows: [ 1 differences ]
%Row No. 1 - Actual:   <T_TAB_VARCHAR>B</T_TAB_VARCHAR>
%Row No. 1 - Expected: <T_TAB_VARCHAR>A</T_TAB_VARCHAR>]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure array_is_null is
   l_is_null ut3_tester_helper.t_tab_varchar ;
  begin
    ut3_develop.ut.expect( anydata.convertCollection( l_is_null ) ).to_be_null;
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;  

  procedure array_null_equal_array_null is
   l_is_null ut3_tester_helper.t_tab_varchar ;
   l_is_null_bis ut3_tester_helper.t_tab_varchar ;
  begin
    ut3_develop.ut.expect( anydata.convertCollection( l_is_null ) ).to_equal(anydata.convertCollection( l_is_null_bis ));
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;  
  
  procedure array_null_equal_array_notnull is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
    l_is_null ut3_tester_helper.t_tab_varchar ;
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( l_is_null );
    g_test_actual   := anydata.convertCollection(  ut3_tester_helper.t_tab_varchar('A')  );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    l_expected_message := q'[%Actual: ut3_tester_helper.t_tab_varchar [ count = 1 ] was expected to equal: ut3_tester_helper.t_tab_varchar [ null ]
%Diff:
%Rows: [ 1 differences ]
%Row No. 1 - Extra:    <T_TAB_VARCHAR>A</T_TAB_VARCHAR>]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
  
  procedure empty_array_have_zero_elem is
  begin
     ut3_develop.ut.expect( anydata.convertCollection(ut3_tester_helper.t_tab_varchar())).to_have_count(0);
     ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;
  
  procedure array_empty_equal_array_empty is
  begin
    --Arrange
    g_test_expected := anydata.convertCollection(ut3_tester_helper.t_tab_varchar());
    g_test_actual   := anydata.convertCollection(ut3_tester_helper.t_tab_varchar());
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);  
  end;
  
  procedure arr_empty_equal_arr_notempty is  
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
    l_is_null ut3_tester_helper.t_tab_varchar ;
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( ut3_tester_helper.t_tab_varchar() );
    g_test_actual   := anydata.convertCollection(  ut3_tester_helper.t_tab_varchar('A')  );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    l_expected_message := q'[%Actual: ut3_tester_helper.t_tab_varchar [ count = 1 ] was expected to equal: ut3_tester_helper.t_tab_varchar [ count = 0 ]
%Diff:
%Rows: [ 1 differences ]
%Row No. 1 - Extra:    <T_TAB_VARCHAR>A</T_TAB_VARCHAR>]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
  
  procedure collection_is_null is
    l_null_list ut3_tester_helper.test_dummy_object_list;
  begin
    --Arrange
    g_test_actual   := anydata.convertCollection( l_null_list );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_be_null;
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure collection_is_empty is
  begin
    --Arrange
    g_test_actual   := anydata.convertCollection( ut3_tester_helper.test_dummy_object_list() );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_have_count(0);
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
      
  end;  
  
 procedure varray_same_data is
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( ut3_tester_helper.t_varray(1) );
    g_test_actual   := anydata.convertCollection(  ut3_tester_helper.t_varray(1)  );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure varray_diff_data is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( ut3_tester_helper.t_varray(1) );
    g_test_actual   := anydata.convertCollection(  ut3_tester_helper.t_varray(2) );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    l_expected_message := q'[%Actual: ut3_tester_helper.t_varray [ count = 1 ] was expected to equal: ut3_tester_helper.t_varray [ count = 1 ]
%Diff:
%Rows: [ 1 differences ]
%Row No. 1 - Actual:   <T_VARRAY>2</T_VARRAY>
%Row No. 1 - Expected: <T_VARRAY>1</T_VARRAY>]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure varray_is_null is
   l_is_null ut3_tester_helper.t_varray ;
  begin
    ut3_develop.ut.expect( anydata.convertCollection( l_is_null ) ).to_be_null;
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;  

  procedure varray_null_equal_varray_null is
   l_is_null ut3_tester_helper.t_varray ;
   l_is_null_bis ut3_tester_helper.t_varray ;
  begin
    ut3_develop.ut.expect( anydata.convertCollection( l_is_null ) ).to_equal(anydata.convertCollection( l_is_null_bis ));
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;  
  
  procedure varr_null_equal_varr_notnull is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
    l_is_null ut3_tester_helper.t_varray ;
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( l_is_null );
    g_test_actual   := anydata.convertCollection(  ut3_tester_helper.t_varray(1)  );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    l_expected_message := q'[%Actual: ut3_tester_helper.t_varray [ count = 1 ] was expected to equal: ut3_tester_helper.t_varray [ null ]
%Diff:
%Rows: [ 1 differences ]
%Row No. 1 - Extra:    <T_VARRAY>1</T_VARRAY>]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
  
  procedure empty_varray_have_zero_elem is
  begin
     ut3_develop.ut.expect( anydata.convertCollection(ut3_tester_helper.t_varray())).to_have_count(0);
     ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;
  
  procedure varr_empty_equal_varr_empty is
  begin
    --Arrange
    g_test_expected := anydata.convertCollection(ut3_tester_helper.t_varray());
    g_test_actual   := anydata.convertCollection(ut3_tester_helper.t_varray());
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);  
  end;
  
  procedure varr_empty_equal_varr_notempty is  
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
    l_is_null ut3_tester_helper.t_varray ;
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( ut3_tester_helper.t_varray() );
    g_test_actual   := anydata.convertCollection(  ut3_tester_helper.t_varray(1)  );
    --Act
    ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected );
    l_expected_message := q'[%Actual: ut3_tester_helper.t_varray [ count = 1 ] was expected to equal: ut3_tester_helper.t_varray [ count = 0 ]
%Diff:
%Rows: [ 1 differences ]
%Row No. 1 - Extra:    <T_VARRAY>1</T_VARRAY>]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure collection_join_by is
    l_actual           ut3_tester_helper.test_dummy_object_list;
    l_expected         ut3_tester_helper.test_dummy_object_list;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    select ut3_tester_helper.test_dummy_object( rownum, 'Something '||rownum, rownum)
      bulk collect into l_actual
      from dual connect by level <=2;
    select ut3_tester_helper.test_dummy_object( rownum, 'Something '||rownum, rownum)
      bulk collect into l_expected
      from dual connect by level <=2
     order by rownum desc;
    --Act
    ut3_develop.ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected)).join_by('ID');
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0); 
  end;
    
  procedure collection_join_by_fail is
    l_actual           ut3_tester_helper.test_dummy_object_list;
    l_expected         ut3_tester_helper.test_dummy_object_list;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    select ut3_tester_helper.test_dummy_object( rownum, 'Something '||rownum, rownum)
      bulk collect into l_actual
      from dual connect by level <=2;
    select ut3_tester_helper.test_dummy_object( rownum * 2, 'Something '||rownum, rownum)
      bulk collect into l_expected
      from dual connect by level <=2
     order by rownum desc;
    --Act
    ut3_develop.ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected)).join_by('ID');
    l_expected_message := q'[%Actual: ut3_tester_helper.test_dummy_object_list [ count = 2 ] was expected to equal: ut3_tester_helper.test_dummy_object_list [ count = 2 ]
%Diff:
%Rows: [ 3 differences ]
%PK <ID>2</ID> - Actual:   <name>Something 2</name><Value>2</Value>
%PK <ID>2</ID> - Expected: <name>Something 1</name><Value>1</Value>
%PK <ID>1</ID> - Extra:    <TEST_DUMMY_OBJECT><ID>1</ID><name>Something 1</name><Value>1</Value></TEST_DUMMY_OBJECT>
%PK <ID>4</ID> - Missing:  <TEST_DUMMY_OBJECT><ID>4</ID><name>Something 2</name><Value>2</Value></TEST_DUMMY_OBJECT>]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
  
  procedure collection_unordered is
    l_actual           ut3_tester_helper.test_dummy_object_list;
    l_expected         ut3_tester_helper.test_dummy_object_list;
  begin
    --Arrange
    select ut3_tester_helper.test_dummy_object( rownum, 'Something '||rownum, rownum)
      bulk collect into l_actual
      from dual connect by level <=3;
    select ut3_tester_helper.test_dummy_object( rownum, 'Something '||rownum, rownum)
      bulk collect into l_expected
      from dual connect by level <=3
     order by rownum desc;
    --Act
    ut3_develop.ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected)).unordered;
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0); 
  end;  
 
 procedure collection_unordered_fail is
    l_actual           ut3_tester_helper.test_dummy_object_list;
    l_expected         ut3_tester_helper.test_dummy_object_list;
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    select ut3_tester_helper.test_dummy_object( rownum, 'Something '||rownum, rownum)
      bulk collect into l_actual
      from dual connect by level <=2;
    select ut3_tester_helper.test_dummy_object( rownum * 2, 'Something '||rownum, rownum)
      bulk collect into l_expected
      from dual connect by level <=2
     order by rownum desc;

    l_expected_message := q'[%Actual: ut3_tester_helper.test_dummy_object_list [ count = 2 ] was expected to equal: ut3_tester_helper.test_dummy_object_list [ count = 2 ]
%Diff:
%Rows: [ 4 differences ]
%Extra:    <TEST_DUMMY_OBJECT><ID>1</ID><name>Something 1</name><Value>1</Value></TEST_DUMMY_OBJECT>
%Extra:    <TEST_DUMMY_OBJECT><ID>2</ID><name>Something 2</name><Value>2</Value></TEST_DUMMY_OBJECT>
%Missing:  <TEST_DUMMY_OBJECT><ID>4</ID><name>Something 2</name><Value>2</Value></TEST_DUMMY_OBJECT>
%Missing:  <TEST_DUMMY_OBJECT><ID>2</ID><name>Something 1</name><Value>1</Value></TEST_DUMMY_OBJECT>]';

    ut3_develop.ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected)).unordered;
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end; 
 
  procedure object_join_by is
  begin
    --Arrange
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_object(1, 'A', '0') );
    g_test_actual   := anydata.convertObject( ut3_tester_helper.test_dummy_object(1, 'A', '0') );
    
    --Act
    ut3_develop.ut.expect(g_test_actual).to_equal(g_test_expected).join_by('ID');
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0); 
  end;
    
  procedure object_unordered is
  begin
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_object(1, 'A', '0') );
    g_test_actual   := anydata.convertObject( ut3_tester_helper.test_dummy_object(1, 'A', '0') );
    
    --Act
    ut3_develop.ut.expect(g_test_actual).to_equal(g_test_expected).unordered;
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0); 
  end;   
 
  procedure collection_to_contain is
    l_actual           ut3_tester_helper.test_dummy_object_list;
    l_expected         ut3_tester_helper.test_dummy_object_list;
  begin
    --Arrange
    select ut3_tester_helper.test_dummy_object( rownum, 'Something '||rownum, rownum)
      bulk collect into l_actual
      from dual connect by level <=4;
    select ut3_tester_helper.test_dummy_object( rownum, 'Something '||rownum, rownum)
      bulk collect into l_expected
      from dual connect by level <=2
     order by rownum desc;
    --Act
    ut3_develop.ut.expect(anydata.convertCollection(l_actual)).to_contain(anydata.convertCollection(l_expected));
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0); 
  end;  
  
  procedure object_to_contain is
  begin
  --Arrange
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_object(1, 'A', '0') );
    g_test_actual   := anydata.convertObject( ut3_tester_helper.test_dummy_object(1, 'A', '0') );
    
    --Act
    ut3_develop.ut.expect(g_test_actual).to_contain(g_test_expected);
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0); 
  end;  
   
  procedure arr_empty_eq_arr_empty_unord is
  begin
   --Arrange
   g_test_expected := anydata.convertCollection(ut3_tester_helper.t_tab_varchar(null));
   g_test_actual   := anydata.convertCollection(ut3_tester_helper.t_tab_varchar(null));

   --Act
   ut3_develop.ut.expect( g_test_actual ).to_equal( g_test_expected ).unordered();
   ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);   

  end;   
  
  procedure arr_empty_nqua_arr_e_unord is
  begin
   --Arrange
   g_test_expected := anydata.convertCollection(ut3_tester_helper.t_tab_varchar('t'));
   g_test_actual   := anydata.convertCollection(ut3_tester_helper.t_tab_varchar(' '));

   --Act
   ut3_develop.ut.expect( g_test_actual ).not_to_equal( g_test_expected ).unordered();
   ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0); 

  end;  

  procedure failure_nesting_objects is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);	  
  begin
  --Arrange
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_nested_object(ut3_tester_helper.test_dummy_object(1, 'A', '0'),ut3_tester_helper.test_dummy_object(1, 'B', '0') ));
    g_test_actual   := anydata.convertObject( ut3_tester_helper.test_dummy_nested_object(ut3_tester_helper.test_dummy_object(1, 'A', '0'),ut3_tester_helper.test_dummy_object(1, 'C', '0') ));
    --Act
    l_expected_message := q'[%Actual: ut3_tester_helper.test_dummy_nested_object was expected to equal: ut3_tester_helper.test_dummy_nested_object
%Diff:
%Rows: [ 1 differences ]
%Row No. 1 - Actual:   <SEC_NESTED_OBJ><ID>1</ID><name>C</name><Value>0</Value></SEC_NESTED_OBJ>
%Row No. 1 - Expected: <SEC_NESTED_OBJ><ID>1</ID><name>B</name><Value>0</Value></SEC_NESTED_OBJ>]';
    ut3_develop.ut.expect(g_test_actual).to_equal(g_test_expected);
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);   
  end;
  
  procedure failure_double_nested_objects is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);	  
  begin
  --Arrange
    g_test_expected := anydata.convertObject( ut3_tester_helper.test_dummy_double_nested_object(ut3_tester_helper.test_dummy_nested_object(ut3_tester_helper.test_dummy_object(1, 'A', '0'),ut3_tester_helper.test_dummy_object(1, 'B', '0') ),'Test'));
    g_test_actual   := anydata.convertObject( ut3_tester_helper.test_dummy_double_nested_object(ut3_tester_helper.test_dummy_nested_object(ut3_tester_helper.test_dummy_object(1, 'A', '0'),ut3_tester_helper.test_dummy_object(1, 'C', '0') ),'Test'));
    --Act
    l_expected_message := q'[%Actual: ut3_tester_helper.test_dummy_double_nested_object was expected to equal: ut3_tester_helper.test_dummy_double_nested_object
%Diff:
%Rows: [ 1 differences ]
%Row No. 1 - Actual:   <FIRST_DOUBLE_NESTED_OBJ><FIRST_NESTED_OBJ><ID>1</ID><name>A</name><Value>0</Value></FIRST_NESTED_OBJ><SEC_NESTED_OBJ><ID>1</ID><name>C</name><Value>0</Value></SEC_NESTED_OBJ></FIRST_DOUBLE_NESTED_OBJ>
%Row No. 1 - Expected: <FIRST_DOUBLE_NESTED_OBJ><FIRST_NESTED_OBJ><ID>1</ID><name>A</name><Value>0</Value></FIRST_NESTED_OBJ><SEC_NESTED_OBJ><ID>1</ID><name>B</name><Value>0</Value></SEC_NESTED_OBJ></FIRST_DOUBLE_NESTED_OBJ>]';
    ut3_develop.ut.expect(g_test_actual).to_equal(g_test_expected);
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);   
  end;  
  
end;
/