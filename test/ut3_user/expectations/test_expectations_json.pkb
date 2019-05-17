create or replace package body test_expectations_json is

  procedure cleanup_expectations is
  begin
    ut3_tester_helper.main_helper.clear_expectations( );
  end;

  procedure success_on_same_data
  as
    l_expected json_element_t;
    l_actual   json_element_t;
  begin
    -- Arrange
    l_expected := json_element_t.parse('{"name1":"value1","name2":"value2"}');
    l_actual   := json_element_t.parse('{"name1":"value1","name2":"value2"}');

    --Act
    ut3.ut.expect( l_actual ).to_equal( l_actual );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;
  
  procedure fail_on_diff_data 
  as
    l_expected json_element_t;
    l_actual   json_element_t;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    -- Arrange
    l_expected := json_element_t.parse('{"name1":"value2","name2":"value2"}');
    l_actual   := json_element_t.parse('{"name1":"value1","name2":"value2"}');

    --Act
    ut3.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    l_expected_message := q'[%Actual: '{"name1":"value1","name2":"value2"}' (json) was expected to equal: '{"name1":"value2","name2":"value2"}' (json)%]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
 
  procedure null_json_variable
  as
    l_expected json_object_t ;
  begin
    -- Arrange
    l_expected := cast (null as JSON_OBJECT_T );

    --Act
    ut3.ut.expect( l_expected ).to_be_null;
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure null_json
  as
    l_expected json_element_t;
    l_actual   json_element_t;
  begin
    -- Arrange
    l_expected := JSON_OBJECT_T();

    --Act
    ut3.ut.expect( l_expected ).to_be_null;
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;
  
end;
/
