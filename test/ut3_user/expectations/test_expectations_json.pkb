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
    l_actual   := json_element_t.parse('{"Aidan Gillen": {"array": ["Game of Thrones","The Wire"],"string": "some string","int": "2","otherint": 4, "aboolean": "true", "boolean": false,"object": {"foo": "bar"}},"Amy Ryan": ["In Treatment","The Wire"],"Annie Fitzgerald": ["True Blood","Big Love","The Sopranos","Oz"],"Anwan Glover": ["Treme","The Wire"],"Alexander Skarsg?rd": ["Generation Kill","True Blood"],"Alice Farmer": ["The Corner","Oz","The Wire"]}');
    l_expected := json_element_t.parse('{"Aidan Gillen": {"array": ["Game of Thron\"es","The Wire"],"string": "some string","int": 2,"aboolean": true, "boolean": true,"object": {"foo": "bar","object1": {"new prop1": "new prop value"},"object2": {"new prop1": "new prop value"},"object3": {"new prop1": "new prop value"},"object4": {"new prop1": "new prop value"}}},"Amy Ryan": {"one": "In Treatment","two": "The Wire"},"Annie Fitzgerald": ["Big Love","True Blood"],"Anwan Glover": ["Treme","The Wire"],"Alexander Skarsgard": ["Generation Kill","True Blood"], "Clarke Peters": null}');

    --Act
    ut3.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    l_expected_message := q'[%%Actual type is "array" was expected to be "object" on path :$.Amy Ryan
%Missing property "Alexander Skarsg?rd" on path :$.Alexander Skarsg?rd
%Extra property "Alexander Skarsgard" on path :$.Alexander Skarsgard
%Missing property "Alice Farmer" on path :$.Alice Farmer
%Extra property "Clarke Peters" on path :$.Clarke Peters
%Actual value is "True Blood" was expected to be "Big Love" on path :$.Annie Fitzgerald[0]
%Actual value is "Big Love" was expected to be "True Blood" on path :$.Annie Fitzgerald[1]
%Missing property ""The Sopranos"" on path :$.Annie Fitzgerald[2]
%Missing property ""Oz"" on path :$.Annie Fitzgerald[3]
%Actual type is "string" was expected to be "number" on path :$.Aidan Gillen.int
%Missing property "otherint" on path :$.Aidan Gillen.otherint
%Actual type is "string" was expected to be "boolean" on path :$.Aidan Gillen.aboolean
%Actual value is "0" was expected to be "1" on path :$.Aidan Gillen.boolean
%Actual value is "Game of Thrones" was expected to be "Game of Thron"es" on path :$.Aidan Gillen.array[0]
%Extra property "object1" on path :$.Aidan Gillen.object.object1
%Extra property "object2" on path :$.Aidan Gillen.object.object2
%Extra property "object3" on path :$.Aidan Gillen.object.object3
%Extra property "object4" on path :$.Aidan Gillen.object.object4]';
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

  procedure not_null_json_variable
  as
    l_expected json_object_t ;
  begin
    -- Arrange
    l_expected := JSON_OBJECT_T();

    --Act
    ut3.ut.expect( l_expected ).not_to_be_null;
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure fail_null_json_var
  as
    l_expected json_object_t ;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    -- Arrange
    l_expected := JSON_OBJECT_T('{ "t" : "1" }');

    --Act
    ut3.ut.expect( l_expected ).to_be_null;
    --Assert
    l_expected_message := q'[%Actual: (json)
%'{"t":"1"}'
%was expected to be null%]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure fail_not_null_json_var
  as
    l_expected json_object_t;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    -- Arrange
    l_expected := cast (null as JSON_OBJECT_T );

    --Act
    ut3.ut.expect( l_expected ).not_to_be_null;
    --Assert
    l_expected_message := q'[%Actual: NULL (json) was expected not to be null%]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure empty_json
  as
    l_expected JSON_OBJECT_T;
  begin
    -- Arrange
    l_expected := JSON_OBJECT_T();

    --Act
    ut3.ut.expect( l_expected ).to_be_empty;
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;
  
  procedure not_empty_json
  as
    l_expected JSON_OBJECT_T;
  begin
    -- Arrange
    l_expected := JSON_OBJECT_T.parse('{ "name" : "test" }');

    --Act
    ut3.ut.expect( l_expected ).not_to_be_empty;
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;  
  
end;
/
