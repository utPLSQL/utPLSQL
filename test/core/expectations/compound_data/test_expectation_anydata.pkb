create or replace package body test_expectation_anydata is

  g_test_expected anydata;
  g_test_actual   anydata;

  procedure cleanup_expectations is
  begin
    expectations.cleanup_expectations( );
  end;

  procedure cleanup is
  begin
    g_test_expected := null;
    g_test_actual   := null;
    cleanup_expectations();
  end;

  procedure fail_on_different_type_null is
  begin
    --Arrange
    g_test_expected := anydata.convertObject( cast(null as test_dummy_object) );
    g_test_actual   := anydata.convertObject( cast(null as other_dummy_object) );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_on_different_type is
  begin
    --Arrange
    g_test_expected := anydata.convertObject( test_dummy_object(1, 'A', '0') );
    g_test_actual   := anydata.convertObject( other_dummy_object(1, 'A', '0') );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_on_different_object_data is
  begin
    --Arrange
    g_test_expected := anydata.convertObject( test_dummy_object(1, 'A', '0') );
    g_test_actual   := anydata.convertObject( test_dummy_object(1, null, '0') );
    --Act
    ut3.ut.expect( g_test_actual ).not_to_equal( g_test_expected );
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure fail_on_one_object_null is
  begin
    --Arrange
    g_test_expected := anydata.convertObject( test_dummy_object(1, 'A', '0') );
    g_test_actual   := anydata.convertObject( cast(null as test_dummy_object) );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_on_collection_vs_object is
  begin
    --Arrange
    g_test_expected := anydata.convertObject( test_dummy_object(1, 'A', '0') );
    g_test_actual   := anydata.convertCollection( test_dummy_object_list(test_dummy_object(1, 'A', '0')) );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_on_null_vs_empty_coll is
    l_null_list test_dummy_object_list;
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( test_dummy_object_list() );
    g_test_actual   := anydata.convertCollection( l_null_list );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;
  
  procedure fail_on_one_collection_null is
    l_null_list test_dummy_object_list;
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( test_dummy_object_list(test_dummy_object(1, 'A', '0')) );
    g_test_actual   := anydata.convertCollection( l_null_list );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_on_one_collection_empty is
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( test_dummy_object_list(test_dummy_object(1, 'A', '0')) );
    g_test_actual   := anydata.convertCollection( test_dummy_object_list() );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure fail_on_different_coll_data is
    l_obj test_dummy_object := test_dummy_object(1, 'A', '0');
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( test_dummy_object_list(l_obj) );
    g_test_actual   := anydata.convertCollection( test_dummy_object_list(l_obj, l_obj) );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  --%test(Gives success when both anydata are NULL)
  procedure success_on_both_anydata_null is
    --Arrange
    l_null_anydata anydata;
  begin
    --Act
    ut3.ut.expect( l_null_anydata ).to_equal( l_null_anydata );
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure success_on_both_object_null is
    --Arrange
    l_null_object test_dummy_object;
    l_anydata     anydata := anydata.convertObject(l_null_object);
  begin
    --Act
    ut3.ut.expect( l_anydata ).to_equal( l_anydata );
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure success_on_both_coll_null is
    --Arrange
    l_null_collection test_dummy_object_list;
    l_anydata         anydata := anydata.convertCollection(l_null_collection);
    begin
      --Act
      ut3.ut.expect( l_anydata ).to_equal( l_anydata );
      --Assert
      ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure success_on_same_coll_data is
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( test_dummy_object_list(test_dummy_object(1, 'A', '0')) );
    g_test_actual   := anydata.convertCollection( test_dummy_object_list(test_dummy_object(1, 'A', '0')) );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure fail_on_coll_different_order is
    l_first_obj  test_dummy_object := test_dummy_object(1, 'A', '0');
    l_second_obj test_dummy_object := test_dummy_object(2, 'b', '1');
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( test_dummy_object_list(l_first_obj, l_second_obj) );
    g_test_actual   := anydata.convertCollection( test_dummy_object_list(l_second_obj, l_first_obj) );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    ut.expect(expectations.failed_expectations_data()).not_to_be_empty();
  end;

  procedure success_on_same_object_data is
  begin
    --Arrange
    g_test_expected := anydata.convertObject( test_dummy_object(1, 'A', '0') );
    g_test_actual   := anydata.convertObject( test_dummy_object(1, 'A', '0') );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure exclude_attributes_as_list is
    l_list ut3.ut_varchar2_list;
  begin
    --Arrange
    l_list := ut3.ut_varchar2_list('Value','ID');
    g_test_expected := anydata.convertObject( test_dummy_object(id=>1, "name"=>'A',"Value"=>'0') );
    g_test_actual   := anydata.convertObject( test_dummy_object(id=>3, "name"=>'A',"Value"=>'1') );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected, a_exclude=> l_list );
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure exclude_attributes_as_csv is
    l_list varchar2(100);
  begin
    --Arrange
    l_list := 'Value,ID';
    g_test_expected := anydata.convertObject( test_dummy_object(id=>1, "name"=>'A',"Value"=>'0') );
    g_test_actual   := anydata.convertObject( test_dummy_object(id=>2, "name"=>'A',"Value"=>'1') );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected, a_exclude=> l_list );
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure exclude_attrib_xpath_invalid is
    l_anydata_object anydata;
    l_xpath          varchar2(100);
  begin
    --Arrange
    l_xpath := '//KEY,//Value';
    l_anydata_object := anydata.convertObject( test_dummy_object(id=>1, "name"=>'A',"Value"=>'0') );
    --Act
    ut3.ut.expect( l_anydata_object ).to_equal( l_anydata_object, a_exclude=> l_xpath );
    --Assert
    ut.fail('Expected exception -31011 but nothing was raised');
  exception
    when others then
      ut.expect(sqlcode).to_equal(-31011);
  end;

  procedure exclude_attributes_xpath is
    l_xpath varchar2(100);
  begin
    --Arrange
    l_xpath := '//Value|//ID';
    g_test_expected := anydata.convertObject( test_dummy_object(id=>1, "name"=>'A',"Value"=>'0') );
    g_test_actual   := anydata.convertObject( test_dummy_object(id=>2, "name"=>'A',"Value"=>'1') );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected, a_exclude=> l_xpath );
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure exclude_ignores_invalid_attrib is
    l_exclude varchar2(100);
  begin
    --Arrange
    l_exclude := 'BadAttributeName';
    g_test_expected := anydata.convertObject( test_dummy_object(id=>1, "name"=>'A',"Value"=>'0') );
    g_test_actual   := anydata.convertObject( test_dummy_object(id=>1, "name"=>'A',"Value"=>'0') );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected, a_exclude=> l_exclude );
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure include_attributes_as_list is
    l_list ut3.ut_varchar2_list;
  begin
    --Arrange
    l_list := ut3.ut_varchar2_list('Value','ID');
    g_test_expected := anydata.convertObject( test_dummy_object(id=>1, "name"=>'A',"Value"=>'0') );
    g_test_actual   := anydata.convertObject( test_dummy_object(id=>1, "name"=>'b',"Value"=>'0') );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected, a_include=> l_list );
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure include_attributes_as_csv is
    l_xpath          varchar2(100);
  begin
    --Arrange
    l_xpath := 'key,ID';
    g_test_expected := anydata.convertObject( test_dummy_object(id=>1, "name"=>'A',"Value"=>'0') );
    g_test_actual   := anydata.convertObject( test_dummy_object(id=>1, "name"=>'A',"Value"=>'1') );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected, a_include=> l_xpath );
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure include_attrib_xpath_invalid is
    l_anydata_object anydata;
    l_xpath          varchar2(100);
  begin
    --Arrange
    l_xpath := '//KEY,//Value';
    l_anydata_object := anydata.convertObject( test_dummy_object(id=>1, "name"=>'A',"Value"=>'0') );
    --Act
    ut3.ut.expect( l_anydata_object ).to_equal( l_anydata_object, a_include=> l_xpath );
    --Assert
    ut.fail('Expected exception -31011 but nothing was raised');
    exception
    when others then
    ut.expect(sqlcode).to_equal(-31011);
  end;

  procedure include_attributes_xpath is
    l_xpath varchar2(100);
  begin
    --Arrange
    l_xpath := '//key|//ID';
    g_test_expected := anydata.convertObject( test_dummy_object(id=>1, "name"=>'A',"Value"=>'0') );
    g_test_actual   := anydata.convertObject( test_dummy_object(id=>1, "name"=>'A',"Value"=>'1') );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected, a_include=> l_xpath );
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure include_ignores_invalid_attrib is
    l_include varchar2(100);
  begin
    --Arrange
    l_include := ' BadAttributeName, ID ';
    g_test_expected := anydata.convertObject( test_dummy_object(id=>1, "name"=>'B',"Value"=>'0') );
    g_test_actual   := anydata.convertObject( test_dummy_object(id=>1, "name"=>'A',"Value"=>'1') );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected, a_include=> l_include );
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure include_exclude_attributes_csv is
    l_exclude varchar2(100);
    l_include varchar2(100);
  begin
    --Arrange
    l_include := 'key,ID,Value';
    l_exclude := '//key|//Value';
    g_test_expected := anydata.convertObject( test_dummy_object(id=>1, "name"=>'B',"Value"=>'0') );
    g_test_actual   := anydata.convertObject( test_dummy_object(id=>1, "name"=>'A',"Value"=>'1') );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected, a_include=> l_include , a_exclude=> l_exclude );
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure include_exclude_attrib_list is
    l_exclude ut3.ut_varchar2_list;
    l_include ut3.ut_varchar2_list;
  begin
    --Arrange
    l_include := ut3.ut_varchar2_list('key','ID','Value');
    l_exclude := ut3.ut_varchar2_list('key','Value');
    g_test_expected := anydata.convertObject( test_dummy_object(id=>1, "name"=>'B',"Value"=>'0') );
    g_test_actual   := anydata.convertObject( test_dummy_object(id=>1, "name"=>'A',"Value"=>'1') );
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected, a_include=> l_include , a_exclude=> l_exclude );
    --Assert
    ut.expect(expectations.failed_expectations_data()).to_be_empty();
  end;

  procedure reports_object_structure is
    l_expected varchar2(32767);
    l_actual   varchar2(32767);
  begin
    --Arrange
    g_test_expected := anydata.convertObject( test_dummy_object(1, 'A', '0') );
    g_test_actual   := anydata.convertObject( test_dummy_object(1, 'B', '0') );
    l_expected := q'[%Actual:%
    <TEST_DUMMY_OBJECT>
      <ID>1</ID>
      <name>B</name>
      <Value>0</Value>
    </TEST_DUMMY_OBJECT>%
was expected to equal:%
    <TEST_DUMMY_OBJECT>
      <ID>1</ID>
      <name>A</name>
      <Value>0</Value>
    </TEST_DUMMY_OBJECT>%]';
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    l_actual := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    ut.expect(l_actual).to_be_like(l_expected);
  end;


  procedure reports_collection_structre is
    l_obj      test_dummy_object := test_dummy_object(1, 'A', '0');
    l_expected varchar2(32767);
    l_actual   varchar2(32767);
  begin
    --Arrange
    g_test_expected := anydata.convertCollection( test_dummy_object_list(l_obj) );
    g_test_actual   := anydata.convertCollection( test_dummy_object_list(l_obj, l_obj) );
    l_expected := q'[%Actual:%[ count = % ])
    <TEST_DUMMY_OBJECT_LIST>
      <TEST_DUMMY_OBJECT>
        <ID>1</ID>
        <name>A</name>
        <Value>0</Value>
      </TEST_DUMMY_OBJECT>
      <TEST_DUMMY_OBJECT>
        <ID>1</ID>
        <name>A</name>
        <Value>0</Value>
      </TEST_DUMMY_OBJECT>
    </TEST_DUMMY_OBJECT_LIST>%
was expected to equal:%[ count = % ])
    <TEST_DUMMY_OBJECT_LIST>
      <TEST_DUMMY_OBJECT>
        <ID>1</ID>
        <name>A</name>
        <Value>0</Value>
      </TEST_DUMMY_OBJECT>
    </TEST_DUMMY_OBJECT_LIST>%]';
    --Act
    ut3.ut.expect( g_test_actual ).to_equal( g_test_expected );
    --Assert
    l_actual := ut3.ut_expectation_processor.get_failed_expectations()(1).message;
    ut.expect(l_actual).to_be_like(l_expected);
  end;

end;
/