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
    l_expected := json_element_t.parse('    {
      "Actors": [
        {
          "name": "Tom Cruise",
          "age": 56,
          "Born At": "Syracuse, NY",
          "Birthdate": "July 3, 1962",
          "photo": "https://jsonformatter.org/img/tom-cruise.jpg",
          "wife": null,
          "weight": 67.5,
          "hasChildren": true,
          "hasGreyHair": false,
          "children": [
            "Suri",
            "Isabella Jane",
            "Connor"
          ]
        },
        {
          "name": "Robert Downey Jr.",
          "age": 53,
          "Born At": "New York City, NY",
          "Birthdate": "April 4, 1965",
          "photo": "https://jsonformatter.org/img/Robert-Downey-Jr.jpg",
          "wife": "Susan Downey",
          "weight": 77.1,
          "hasChildren": true,
          "hasGreyHair": false,
          "children": [
            "Indio Falconer",
            "Avri Roel",
            "Exton Elias"
          ]
        }
      ]
    }');
    l_actual   := json_element_t.parse('    {
      "Actors": [
        {
          "name": "Tom Cruise",
          "age": 56,
          "Born At": "Syracuse, NY",
          "Birthdate": "July 3, 1962",
          "photo": "https://jsonformatter.org/img/tom-cruise.jpg",
          "wife": null,
          "weight": 67.5,
          "hasChildren": true,
          "hasGreyHair": false,
          "children": [
            "Suri",
            "Isabella Jane",
            "Connor"
          ]
        },
        {
          "name": "Robert Downey Jr.",
          "age": 53,
          "Born At": "New York City, NY",
          "Birthdate": "April 4, 1965",
          "photo": "https://jsonformatter.org/img/Robert-Downey-Jr.jpg",
          "wife": "Susan Downey",
          "weight": 77.1,
          "hasChildren": true,
          "hasGreyHair": false,
          "children": [
            "Indio Falconer",
            "Avri Roel",
            "Exton Elias"
          ]
        }
      ]
    }');

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
    l_expected   := json_element_t.parse('{"Aidan Gillen": {"array": ["Game of Thrones","The Wire"],"string": "some string","int": "2","otherint": 4, "aboolean": "true", "boolean": false,"object": {"foo": "bar"}},"Amy Ryan": ["In Treatment","The Wire"],"Annie Fitzgerald": ["True Blood","Big Love","The Sopranos","Oz"],"Anwan Glover": ["Treme","The Wire"],"Alexander Skarsg?rd": ["Generation Kill","True Blood"],"Alice Farmer": ["The Corner","Oz","The Wire"]}');
    l_actual := json_element_t.parse('{"Aidan Gillen": {"array": ["Game of Thron\"es","The Wire"],"string": "some string","int": 2,"aboolean": true, "boolean": true,"object": {"foo": "bar","object1": {"new prop1": "new prop value"},"object2": {"new prop1": "new prop value"},"object3": {"new prop1": "new prop value"},"object4": {"new prop1": "new prop value"}}},"Amy Ryan": {"one": "In Treatment","two": "The Wire"},"Annie Fitzgerald": ["Big Love","True Blood"],"Anwan Glover": ["Treme","The Wire"],"Alexander Skarsgard": ["Generation Kill","True Blood"], "Clarke Peters": null}');

    --Act
    ut3.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    l_expected_message := q'[%Actual type is 'array' was expected to be 'object' on path :$.Amy Ryan
%Missing property 'Alexander Skarsg?rd' on path :$.Alexander Skarsg?rd
%Extra property 'Alexander Skarsgard' on path :$.Alexander Skarsgard
%Missing property 'Alice Farmer' on path :$.Alice Farmer
%Extra property 'Clarke Peters' on path :$.Clarke Peters
%Actual value is 'True Blood' was expected to be 'Big Love' on path :$.Annie Fitzgerald[0]
%Actual value is 'Big Love' was expected to be 'True Blood' on path :$.Annie Fitzgerald[1]
%Missing property '"The Sopranos"' on path :$.Annie Fitzgerald[2]
%Missing property '"Oz"' on path :$.Annie Fitzgerald[3]
%Actual type is 'string' was expected to be 'number' on path :$.Aidan Gillen.int
%Missing property 'otherint' on path :$.Aidan Gillen.otherint
%Actual type is 'string' was expected to be 'boolean' on path :$.Aidan Gillen.aboolean
%Actual value is 'false' was expected to be 'true' on path :$.Aidan Gillen.boolean
%Actual value is 'Game of Thrones' was expected to be 'Game of Thron"es' on path :$.Aidan Gillen.array[0]
%Extra property 'object1' on path :$.Aidan Gillen.object.object1
%Extra property 'object2' on path :$.Aidan Gillen.object.object2
%Extra property 'object3' on path :$.Aidan Gillen.object.object3
%Extra property 'object4' on path :$.Aidan Gillen.object.object4%]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
 
  procedure null_json_variable
  as
    l_expected json_object_t ;
  begin
    -- Arrange
    l_expected := cast (null as json_object_t );

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
    l_expected := json_object_t();

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
    l_expected := json_object_t('{ "t" : "1" }');

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
    l_expected := cast (null as json_object_t );

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
    l_expected json_object_t;
  begin
    -- Arrange
    l_expected := json_object_t();

    --Act
    ut3.ut.expect( l_expected ).to_be_empty;
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;
  
  procedure not_empty_json
  as
    l_expected json_object_t;
  begin
    -- Arrange
    l_expected := json_object_t.parse('{ "name" : "test" }');

    --Act
    ut3.ut.expect( l_expected ).not_to_be_empty;
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;  

  procedure fail_empty_json
  as
    l_expected json_object_t;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    -- Arrange
    l_expected := json_object_t.parse('{ "name" : "test" }');

    --Act
    ut3.ut.expect( l_expected ).to_be_empty;
    --Assert
    l_expected_message := q'[%Actual: (json)
%'{"name":"test"}'
%was expected to be empty%]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
  
  procedure fail_not_empty_json
  as
    l_expected json_object_t;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    -- Arrange
    l_expected := json_object_t();

    --Act
    ut3.ut.expect( l_expected ).not_to_be_empty;
    --Assert
    l_expected_message := q'[%Actual: (json)
%'{}'
%was expected not to be empty%]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure to_have_count as
    l_actual   json_element_t;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    -- Arrange
    l_actual   := json_element_t.parse('{"Aidan Gillen": {"array": ["Game of Thrones","The Wire"],"string": "some string","int": "2","otherint": 4, "aboolean": "true", "boolean": false,"object": {"foo": "bar"}},"Amy Ryan": ["In Treatment","The Wire"],"Annie Fitzgerald": ["True Blood","Big Love","The Sopranos","Oz"],"Anwan Glover": ["Treme","The Wire"],"Alexander Skarsg?rd": ["Generation Kill","True Blood"],"Alice Farmer": ["The Corner","Oz","The Wire"]}');

    --Act
    ut3.ut.expect( l_actual ).to_have_count( 6 );  
    
    --Assert
     ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);

  end;
  
  procedure fail_to_have_count
  as
    l_actual   json_element_t;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    -- Arrange
    l_actual   := json_element_t.parse('{"Aidan Gillen": {"array": ["Game of Thrones","The Wire"],"string": "some string","int": "2","otherint": 4, "aboolean": "true", "boolean": false,"object": {"foo": "bar"}},"Amy Ryan": ["In Treatment","The Wire"],"Annie Fitzgerald": ["True Blood","Big Love","The Sopranos","Oz"],"Anwan Glover": ["Treme","The Wire"],"Alexander Skarsg?rd": ["Generation Kill","True Blood"],"Alice Farmer": ["The Corner","Oz","The Wire"]}');

    --Act
    ut3.ut.expect( l_actual ).to_have_count( 2 ); 
    --Assert
    l_expected_message := q'[%Actual: (json [ count = 6 ]) was expected to have [ count = 2 ]%]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);

  end;
  
  procedure not_to_have_count
  as
    l_actual   json_element_t;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    -- Arrange
    l_actual   := json_element_t.parse('{"Aidan Gillen": {"array": ["Game of Thrones","The Wire"],"string": "some string","int": "2","otherint": 4, "aboolean": "true", "boolean": false,"object": {"foo": "bar"}},"Amy Ryan": ["In Treatment","The Wire"],"Annie Fitzgerald": ["True Blood","Big Love","The Sopranos","Oz"],"Anwan Glover": ["Treme","The Wire"],"Alexander Skarsg?rd": ["Generation Kill","True Blood"],"Alice Farmer": ["The Corner","Oz","The Wire"]}');

    --Act
    ut3.ut.expect( l_actual ).not_to_have_count( 7 );  
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure fail_not_to_have_count
  as
    l_actual   json_element_t;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    -- Arrange
    l_actual   := json_element_t.parse('{"Aidan Gillen": {"array": ["Game of Thrones","The Wire"],"string": "some string","int": "2","otherint": 4, "aboolean": "true", "boolean": false,"object": {"foo": "bar"}},"Amy Ryan": ["In Treatment","The Wire"],"Annie Fitzgerald": ["True Blood","Big Love","The Sopranos","Oz"],"Anwan Glover": ["Treme","The Wire"],"Alexander Skarsg?rd": ["Generation Kill","True Blood"],"Alice Farmer": ["The Corner","Oz","The Wire"]}');

    --Act
    ut3.ut.expect( l_actual ).not_to_have_count( 6 );  
    --Assert
    l_expected_message := q'[%Actual: json [ count = 6 ] was expected not to have [ count = 6 ]%]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure to_have_count_array
  as
    l_actual   json_element_t;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    -- Arrange
    l_actual   := json_element_t.parse('["Game of Thrones","The Wire"]');

    --Act
    ut3.ut.expect( l_actual ).to_have_count( 2 );  
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;
 
  procedure to_diff_json_extract_same
  as
         l_expected   json_object_t;
        l_actual     json_object_t;
    BEGIN
    -- Arrange
        l_expected := json_object_t.parse('    {
      "Actors": [
        {
          "name": "Tom Cruise",
          "age": 56,
          "Born At": "Syracuse, NY",
          "Birthdate": "July 3, 1962",
          "photo": "https://jsonformatter.org/img/tom-cruise.jpg",
          "wife": null,
          "weight": 67.5,
          "hasChildren": true,
          "hasGreyHair": false,
          "children": [
            "Suri",
            "Isabella Jane",
            "Connor"
          ]
        },
        {
          "name": "Robert Downey Jr.",
          "age": 53,
          "Born At": "New York City, NY",
          "Birthdate": "April 4, 1965",
          "photo": "https://jsonformatter.org/img/Robert-Downey-Jr.jpg",
          "wife": "Susan Downey",
          "weight": 77.1,
          "hasChildren": true,
          "hasGreyHair": false,
          "children": [
            "Indio Falconer",
            "Avri Roel",
            "Exton Elias"
          ]
        }
      ]
    }'
        );
        l_actual := json_object_t.parse('    {
      "Actors": 
        {
          "name": "Krzystof Jarzyna",
          "age": 53,
          "Born At": "Szczecin",
          "Birthdate": "April 4, 1965",
          "photo": "niewidzialny",
          "wife": "Susan Downey",
          "children": [
            "Indio Falconer",
            "Avri Roel",
            "Exton Elias"
          ]
        }
    }'
        );
    
    
    --Act
    ut3.ut.expect(json_array_t(json_query(l_actual.stringify,'$.Actors.children'))).to_equal(json_array_t(json_query(l_expected
        .stringify,'$.Actors[1].children')));
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure to_diff_json_extract_diff
  as
    l_expected   json_object_t;
    l_actual     json_object_t;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    -- Arrange
        l_expected := json_object_t.parse('    {
      "Actors": [
        {
          "name": "Tom Cruise",
          "age": 56,
          "Born At": "Syracuse, NY",
          "Birthdate": "July 3, 1962",
          "photo": "https://jsonformatter.org/img/tom-cruise.jpg",
          "wife": null,
          "weight": 67.5,
          "hasChildren": true,
          "hasGreyHair": false,
          "children": [
            "Suri",
            "Isabella Jane",
            "Connor"
          ]
        },
        {
          "name": "Robert Downey Jr.",
          "age": 53,
          "Born At": "New York City, NY",
          "Birthdate": "April 4, 1965",
          "photo": "https://jsonformatter.org/img/Robert-Downey-Jr.jpg",
          "wife": "Susan Downey",
          "weight": 77.1,
          "hasChildren": true,
          "hasGreyHair": false,
          "children": [
            "Noemi",
            "Avri Roel",
            "Exton Elias"
          ]
        }
      ]
    }'
        );
        l_actual := json_object_t.parse('    {
      "Actors": 
        {
          "name": "Krzystof Jarzyna",
          "age": 53,
          "Born At": "Szczecin",
          "Birthdate": "April 4, 1965",
          "photo": "niewidzialny",
          "wife": "Susan Downey",
          "children": [
            "Indio Falconer",
            "Avri Roel",
            "Exton Elias"
          ]
        }
    }'
        );
    
    
    --Act
    ut3.ut.expect(json_array_t(json_query(l_actual.stringify,'$.Actors.children'))).to_equal(json_array_t(json_query(l_expected
        .stringify,'$.Actors[1].children')));
    --Assert
    l_expected_message := q'[%Actual: json was expected to equal: json
%Diff:
%Found: 1 differences
%1 unequal values
%Actual value is 'Noemi' was expected to be 'Indio Falconer' on path :$[0]%]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
  
end;
/
