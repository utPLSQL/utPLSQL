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
    ut3_develop.ut.expect( l_actual ).to_equal( l_actual );
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
    ut3_develop.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    l_expected_message := q'[%Missing property: "Alexander Skarsg?rd" on path: $
%Extra   property: "Alexander Skarsgard" on path: $
%Missing property: "Alice Farmer" on path: $
%Extra   property: "Clarke Peters" on path: $
%Extra   property: "one" on path: $."Amy Ryan"
%Missing property: "The Sopranos" on path: $."Annie Fitzgerald"[2]
%Extra   property: "two" on path: $."Amy Ryan"
%Missing property: "Oz" on path: $."Annie Fitzgerald"[3]
%Missing property: "otherint" on path: $."Aidan Gillen"
%Extra   property: "object1" on path: $."Aidan Gillen"."object"
%Extra   property: "object2" on path: $."Aidan Gillen"."object"
%Extra   property: "object3" on path: $."Aidan Gillen"."object"
%Extra   property: "object4" on path: $."Aidan Gillen"."object"
%Actual  type: 'array' was expected to be: 'object' on path: $."Amy Ryan"
%Actual  type: 'string' was expected to be: 'number' on path: $."Aidan Gillen"."int"
%Actual  type: 'string' was expected to be: 'boolean' on path: $."Aidan Gillen"."aboolean"
%Actual value: "True Blood" was expected to be: "Big Love" on path: $."Annie Fitzgerald"[0]
%Actual value: "Big Love" was expected to be: "True Blood" on path: $."Annie Fitzgerald"[1]
%Actual value: FALSE was expected to be: TRUE on path: $."Aidan Gillen"."boolean"
%Actual value: "Game of Thrones" was expected to be: "Game of Thron\"es" on path: $."Aidan Gillen"."array"[0]%]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
    ut.expect(l_actual_message).to_be_like('%Diff: 20 differences found%');
    ut.expect(l_actual_message).to_be_like('%13 missing properties%');
    ut.expect(l_actual_message).to_be_like('%4 unequal values%');
    ut.expect(l_actual_message).to_be_like('%3 incorrect types%');
  end;
 
  procedure null_json_variable
  as
    l_expected json_object_t ;
  begin
    -- Arrange
    l_expected := cast (null as json_object_t );

    --Act
    ut3_develop.ut.expect( l_expected ).to_be_null;
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
    ut3_develop.ut.expect( l_expected ).not_to_be_null;
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
    ut3_develop.ut.expect( l_expected ).to_be_null;
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
    ut3_develop.ut.expect( l_expected ).not_to_be_null;
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
    ut3_develop.ut.expect( l_expected ).to_be_empty;
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
    ut3_develop.ut.expect( l_expected ).not_to_be_empty;
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
    ut3_develop.ut.expect( l_expected ).to_be_empty;
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
    ut3_develop.ut.expect( l_expected ).not_to_be_empty;
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
    ut3_develop.ut.expect( l_actual ).to_have_count( 6 );
    
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
    ut3_develop.ut.expect( l_actual ).to_have_count( 2 );
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
    ut3_develop.ut.expect( l_actual ).not_to_have_count( 7 );
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
    ut3_develop.ut.expect( l_actual ).not_to_have_count( 6 );
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
    ut3_develop.ut.expect( l_actual ).to_have_count( 2 );
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
    ut3_develop.ut.expect(json_array_t(json_query(l_actual.stringify,'$.Actors.children'))).to_equal(json_array_t(json_query(l_expected
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
    ut3_develop.ut.expect(json_array_t(json_query(l_actual.stringify,'$.Actors.children'))).to_equal(json_array_t(json_query(l_expected
        .stringify,'$.Actors[1].children')));
    --Assert
    l_expected_message := q'[%Actual: json was expected to equal: json
%Diff: 1 differences found
%1 unequal values
%Actual value: "Noemi" was expected to be: "Indio Falconer" on path: $[0]%]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
  
  procedure long_json_test
  as
    l_actual   json_element_t;
  begin
     l_actual   := json_element_t.parse('[
  {
    "_id": "5ce6dc0c3a11766d5a26f494",
    "index": 0,
    "guid": "a86b8b2d-216d-4061-bafa-f3820e41efbe",
    "isActive": true,
    "balance": "$1,754.93",
    "picture": "http://placehold.it/32x32",
    "age": 39,
    "eyeColor": "green",
    "name": "Pearlie Lott",
    "gender": "female",
    "company": "KOG",
    "email": "pearlielott@kog.com",
    "phone": "+1 (852) 567-2605",
    "address": "357 Eldert Street, Benson, Montana, 5484",
    "about": "Est officia consectetur reprehenderit fugiat culpa ea commodo aliqua deserunt enim eu. Exercitation adipisicing laboris nisi irure commodo dolor consectetur tempor minim sunt ullamco Lorem occaecat. Irure quis ut Lorem aliquip aute pariatur magna laboris duis veniam qui velit. Pariatur occaecat eu minim adipisicing est do. Occaecat do ipsum ut in enim quis voluptate et. Sit ea irure nulla culpa in eiusmod.\r\n",
    "registered": "2018-08-24T12:46:31 -01:00",
    "latitude": -22.323554,
    "longitude": 139.071611,
    "tags": [
      "id",
      "do",
      "amet",
      "magna",
      "est",
      "veniam",
      "voluptate"
    ],
    "friends": [
      {
        "id": 0,
        "name": "Tammi Lowe"
      },
      {
        "id": 1,
        "name": "Simpson Miles"
      },
      {
        "id": 2,
        "name": "Hogan Osborne"
      }
    ],
    "greeting": "Hello, Pearlie Lott! You have 2 unread messages.",
    "favoriteFruit": "banana"
  },
  {
    "_id": "5ce6dc0c2b56a6f3271fc272",
    "index": 1,
    "guid": "2a24b446-d11a-4a52-b6c8-86acba1dc65f",
    "isActive": true,
    "balance": "$1,176.58",
    "picture": "http://placehold.it/32x32",
    "age": 30,
    "eyeColor": "brown",
    "name": "Bertha Mack",
    "gender": "female",
    "company": "AQUAFIRE",
    "email": "berthamack@aquafire.com",
    "phone": "+1 (804) 504-2151",
    "address": "636 Bouck Court, Cresaptown, Vermont, 5203",
    "about": "Ipsum est exercitation excepteur reprehenderit ipsum. Do velit dolore minim ad. Quis amet dolor dolore exercitation sint Lorem. Exercitation nulla magna ut incididunt enim veniam voluptate Lorem velit adipisicing sunt deserunt sunt aute. Ullamco id anim Lorem dolore do labore excepteur et reprehenderit sit adipisicing sunt esse veniam. Anim laborum labore labore incididunt in labore exercitation ad occaecat amet ea quis veniam ut.\r\n",
    "registered": "2017-12-29T06:00:27 -00:00",
    "latitude": 75.542572,
    "longitude": 147.312705,
    "tags": [
      "veniam",
      "sunt",
      "commodo",
      "ad",
      "enim",
      "officia",
      "nisi"
    ],
    "friends": [
      {
        "id": 0,
        "name": "Riddle Williams"
      },
      {
        "id": 1,
        "name": "Tracy Wagner"
      },
      {
        "id": 2,
        "name": "Morrow Phillips"
      }
    ],
    "greeting": "Hello, Bertha Mack! You have 8 unread messages.",
    "favoriteFruit": "banana"
  },
  {
    "_id": "5ce6dc0c6d8631fbfdd2afc7",
    "index": 2,
    "guid": "66ca5411-4c88-4347-9972-e1016f628098",
    "isActive": false,
    "balance": "$2,732.22",
    "picture": "http://placehold.it/32x32",
    "age": 33,
    "eyeColor": "blue",
    "name": "Fox Morgan",
    "gender": "male",
    "company": "PERKLE",
    "email": "foxmorgan@perkle.com",
    "phone": "+1 (985) 401-3450",
    "address": "801 Whitty Lane, Snyderville, Guam, 5253",
    "about": "Ex officia eu Lorem velit ullamco qui cupidatat irure sunt ea ad deserunt. Officia est consequat aute labore occaecat aliquip. Velit commodo cillum incididunt cupidatat ad id veniam aute labore tempor qui culpa voluptate dolor. Occaecat in ea id labore exercitation non tempor occaecat laboris aute irure fugiat dolor mollit. Voluptate non proident officia deserunt ex et ullamco aute eiusmod cupidatat consequat elit id.\r\n",
    "registered": "2015-04-02T06:40:53 -01:00",
    "latitude": -27.612441,
    "longitude": -134.005929,
    "tags": [
      "occaecat",
      "amet",
      "eu",
      "dolore",
      "ad",
      "fugiat",
      "quis"
    ],
    "friends": [
      {
        "id": 0,
        "name": "Case Preston"
      },
      {
        "id": 1,
        "name": "Pollard Dawson"
      },
      {
        "id": 2,
        "name": "Frye Mann"
      }
    ],
    "greeting": "Hello, Fox Morgan! You have 2 unread messages.",
    "favoriteFruit": "apple"
  },
  {
    "_id": "5ce6dc0c0a7fea91e0a1fdf5",
    "index": 3,
    "guid": "f895a236-fc0d-4c08-b2f0-9d1638dc256d",
    "isActive": true,
    "balance": "$2,746.32",
    "picture": "http://placehold.it/32x32",
    "age": 34,
    "eyeColor": "green",
    "name": "Deleon Tucker",
    "gender": "male",
    "company": "ZANILLA",
    "email": "deleontucker@zanilla.com",
    "phone": "+1 (883) 415-2709",
    "address": "540 Vandam Street, Chical, Wyoming, 5181",
    "about": "Consectetur consectetur sint Lorem non id. Fugiat reprehenderit nulla dolore nisi culpa esse ea. Ad occaecat qui magna proident ex pariatur aliquip adipisicing do aute aute sunt. Aliqua aliqua et exercitation sunt ut adipisicing.\r\n",
    "registered": "2017-10-08T09:05:49 -01:00",
    "latitude": 34.893845,
    "longitude": 110.699256,
    "tags": [
      "culpa",
      "sunt",
      "sit",
      "ut",
      "eiusmod",
      "laboris",
      "ullamco"
    ],
    "friends": [
      {
        "id": 0,
        "name": "Bernadine Pennington"
      },
      {
        "id": 1,
        "name": "Latoya Bradshaw"
      },
      {
        "id": 2,
        "name": "Iva Caldwell"
      }
    ],
    "greeting": "Hello, Deleon Tucker! You have 7 unread messages.",
    "favoriteFruit": "banana"
  },
  {
    "_id": "5ce6dc0c18bc92716a12a8e4",
    "index": 4,
    "guid": "6ed45f42-1a2b-48b2-89ce-5fdb2505343b",
    "isActive": true,
    "balance": "$1,049.96",
    "picture": "http://placehold.it/32x32",
    "age": 30,
    "eyeColor": "blue",
    "name": "Schwartz Norman",
    "gender": "male",
    "company": "UPDAT",
    "email": "schwartznorman@updat.com",
    "phone": "+1 (826) 404-3309",
    "address": "925 Harman Street, Cornucopia, Georgia, 5748",
    "about": "Qui Lorem ullamco veniam irure aliquip amet exercitation. Velit nisi id laboris adipisicing in esse adipisicing commodo cillum do exercitation tempor. Consequat tempor dolor minim consequat minim ad do tempor excepteur.\r\n",
    "registered": "2014-08-10T08:34:27 -01:00",
    "latitude": 27.35547,
    "longitude": -77.343791,
    "tags": [
      "reprehenderit",
      "nisi",
      "duis",
      "fugiat",
      "id",
      "non",
      "laboris"
    ],
    "friends": [
      {
        "id": 0,
        "name": "Dora Combs"
      },
      {
        "id": 1,
        "name": "Emerson Wade"
      },
      {
        "id": 2,
        "name": "Alma Mccormick"
      }
    ],
    "greeting": "Hello, Schwartz Norman! You have 1 unread messages.",
    "favoriteFruit": "apple"
  },
  {
    "_id": "5ce6dc0cb7ae44eb76c3e5fd",
    "index": 5,
    "guid": "0516df27-73db-42a8-b2c3-d34bd976e031",
    "isActive": false,
    "balance": "$3,679.94",
    "picture": "http://placehold.it/32x32",
    "age": 32,
    "eyeColor": "brown",
    "name": "Christi Oneal",
    "gender": "female",
    "company": "SUREPLEX",
    "email": "christioneal@sureplex.com",
    "phone": "+1 (985) 408-3098",
    "address": "640 Fayette Street, Dennard, Washington, 7962",
    "about": "Dolore fugiat sit non dolore nostrud mollit enim id sint culpa do reprehenderit ad. Velit occaecat incididunt nostrud aliqua incididunt do cillum occaecat laboris quis duis. Non tempor culpa aliquip est est consectetur ullamco elit. Voluptate et sit do et. Amet sit irure eu ex enim nulla anim deserunt ut. Sit aute ea ut fugiat eu tempor Lorem.\r\n",
    "registered": "2015-05-10T09:24:56 -01:00",
    "latitude": 43.343805,
    "longitude": 79.535043,
    "tags": [
      "occaecat",
      "laboris",
      "nulla",
      "nisi",
      "dolore",
      "cillum",
      "dolore"
    ],
    "friends": [
      {
        "id": 0,
        "name": "Marquez Wiggins"
      },
      {
        "id": 1,
        "name": "Mai Fischer"
      },
      {
        "id": 2,
        "name": "Newman Davenport"
      }
    ],
    "greeting": "Hello, Christi Oneal! You have 8 unread messages.",
    "favoriteFruit": "strawberry"
  }
]');

    --Act
    ut3_develop.ut.expect( l_actual ).to_equal( l_actual );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end; 
 
   procedure json_same_diffrent_ord
  as
    l_expected json_element_t;
    l_actual   json_element_t;
  begin
    -- Arrange
    l_expected   := json_element_t.parse('{ 
  "records": [ 
    {"field1": "outer", "field2": "thought"}, 
    {"field2": "thought", "field1": "outer"} 
  ] ,
  "special message": "hello, world!" 
}');
    l_actual := json_element_t.parse('{ 
  "special message": "hello, world!" ,
  "records": [ 
    {"field2": "thought" ,"field1": "outer"}, 
    {"field1": "outer" , "field2": "thought"} 
  ] 
}');

    --Act
    ut3_develop.ut.expect( l_actual ).to_equal( l_expected );
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0); 
  end;

  procedure long_json_test2
  as
    l_actual   json_element_t;
  begin
     l_actual   := json_element_t.parse('[
   {
      "_id":"5ce6dc0c3a11766d5a26f494",
      "index":0,
      "guid":"a86b8b2d-216d-4061-bafa-f3820e41efbe",
      "isActive":true,
      "balance":"$1,754.93",
      "picture":"http://placehold.it/32x32",
      "age":39,
      "eyeColor":"green",
      "name":"Pearlie Lott",
      "gender":"female",
      "company":"KOG",
      "email":"pearlielott@kog.com",
      "phone":"+1 (852) 567-2605",
      "address":"357 Eldert Street, Benson, Montana, 5484",
      "about":"Est officia consectetur reprehenderit fugiat culpa ea commodo aliqua deserunt enim eu. Exercitation adipisicing laboris nisi irure commodo dolor consectetur tempor minim sunt ullamco Lorem occaecat. Irure quis ut Lorem aliquip aute pariatur magna laboris duis veniam qui velit. Pariatur occaecat eu minim adipisicing est do. Occaecat do ipsum ut in enim quis voluptate et. Sit ea irure nulla culpa in eiusmod.\r\n",
      "registered":"2018-08-24T12:46:31 -01:00",
      "latitude":-22.323554,
      "longitude":139.071611,
      "tags":[
         "id",
         "do",
         "amet",
         "magna",
         "est",
         "veniam",
         "voluptate"
      ],
      "friends":[
         {
            "id":0,
            "name":"Tammi Lowe"
         },
         {
            "id":1,
            "name":"Simpson Miles"
         },
         {
            "id":2,
            "name":"Hogan Osborne"
         }
      ],
      "greeting":"Hello, Pearlie Lott! You have 2 unread messages.",
      "favoriteFruit":"banana"
   },
   {
      "_id":"5ce6dc0c2b56a6f3271fc272",
      "index":1,
      "guid":"2a24b446-d11a-4a52-b6c8-86acba1dc65f",
      "isActive":true,
      "balance":"$1,176.58",
      "picture":"http://placehold.it/32x32",
      "age":30,
      "eyeColor":"brown",
      "name":"Bertha Mack",
      "gender":"female",
      "company":"AQUAFIRE",
      "email":"berthamack@aquafire.com",
      "phone":"+1 (804) 504-2151",
      "address":"636 Bouck Court, Cresaptown, Vermont, 5203",
      "about":"Ipsum est exercitation excepteur reprehenderit ipsum. Do velit dolore minim ad. Quis amet dolor dolore exercitation sint Lorem. Exercitation nulla magna ut incididunt enim veniam voluptate Lorem velit adipisicing sunt deserunt sunt aute. Ullamco id anim Lorem dolore do labore excepteur et reprehenderit sit adipisicing sunt esse veniam. Anim laborum labore labore incididunt in labore exercitation ad occaecat amet ea quis veniam ut.\r\n",
      "registered":"2017-12-29T06:00:27 -00:00",
      "latitude":75.542572,
      "longitude":147.312705,
      "tags":[
         "veniam",
         "sunt",
         "commodo",
         "ad",
         "enim",
         "officia",
         "nisi"
      ],
      "friends":[
         {
            "id":0,
            "name":"Riddle Williams"
         },
         {
            "id":1,
            "name":"Tracy Wagner"
         },
         {
            "id":2,
            "name":"Morrow Phillips"
         }
      ],
      "greeting":"Hello, Bertha Mack! You have 8 unread messages.",
      "favoriteFruit":"banana"
   },
   {
      "_id":"5ce6dc0c6d8631fbfdd2afc7",
      "index":2,
      "guid":"66ca5411-4c88-4347-9972-e1016f628098",
      "isActive":false,
      "balance":"$2,732.22",
      "picture":"http://placehold.it/32x32",
      "age":33,
      "eyeColor":"blue",
      "name":"Fox Morgan",
      "gender":"male",
      "company":"PERKLE",
      "email":"foxmorgan@perkle.com",
      "phone":"+1 (985) 401-3450",
      "address":"801 Whitty Lane, Snyderville, Guam, 5253",
      "about":"Ex officia eu Lorem velit ullamco qui cupidatat irure sunt ea ad deserunt. Officia est consequat aute labore occaecat aliquip. Velit commodo cillum incididunt cupidatat ad id veniam aute labore tempor qui culpa voluptate dolor. Occaecat in ea id labore exercitation non tempor occaecat laboris aute irure fugiat dolor mollit. Voluptate non proident officia deserunt ex et ullamco aute eiusmod cupidatat consequat elit id.\r\n",
      "registered":"2015-04-02T06:40:53 -01:00",
      "latitude":-27.612441,
      "longitude":-134.005929,
      "tags":[
         "occaecat",
         "amet",
         "eu",
         "dolore",
         "ad",
         "fugiat",
         "quis"
      ],
      "friends":[
         {
            "id":0,
            "name":"Case Preston"
         },
         {
            "id":1,
            "name":"Pollard Dawson"
         },
         {
            "id":2,
            "name":"Frye Mann"
         }
      ],
      "greeting":"Hello, Fox Morgan! You have 2 unread messages.",
      "favoriteFruit":"apple"
   },
   {
      "_id":"5ce6dc0c0a7fea91e0a1fdf5",
      "index":3,
      "guid":"f895a236-fc0d-4c08-b2f0-9d1638dc256d",
      "isActive":true,
      "balance":"$2,746.32",
      "picture":"http://placehold.it/32x32",
      "age":34,
      "eyeColor":"green",
      "name":"Deleon Tucker",
      "gender":"male",
      "company":"ZANILLA",
      "email":"deleontucker@zanilla.com",
      "phone":"+1 (883) 415-2709",
      "address":"540 Vandam Street, Chical, Wyoming, 5181",
      "about":"Consectetur consectetur sint Lorem non id. Fugiat reprehenderit nulla dolore nisi culpa esse ea. Ad occaecat qui magna proident ex pariatur aliquip adipisicing do aute aute sunt. Aliqua aliqua et exercitation sunt ut adipisicing.\r\n",
      "registered":"2017-10-08T09:05:49 -01:00",
      "latitude":34.893845,
      "longitude":110.699256,
      "tags":[
         "culpa",
         "sunt",
         "sit",
         "ut",
         "eiusmod",
         "laboris",
         "ullamco"
      ],
      "friends":[
         {
            "id":0,
            "name":"Bernadine Pennington"
         },
         {
            "id":1,
            "name":"Latoya Bradshaw"
         },
         {
            "id":2,
            "name":"Iva Caldwell"
         }
      ],
      "greeting":"Hello, Deleon Tucker! You have 7 unread messages.",
      "favoriteFruit":"banana"
   },
   {
      "_id":"5ce6dc0c18bc92716a12a8e4",
      "index":4,
      "guid":"6ed45f42-1a2b-48b2-89ce-5fdb2505343b",
      "isActive":true,
      "balance":"$1,049.96",
      "picture":"http://placehold.it/32x32",
      "age":30,
      "eyeColor":"blue",
      "name":"Schwartz Norman",
      "gender":"male",
      "company":"UPDAT",
      "email":"schwartznorman@updat.com",
      "phone":"+1 (826) 404-3309",
      "address":"925 Harman Street, Cornucopia, Georgia, 5748",
      "about":"Qui Lorem ullamco veniam irure aliquip amet exercitation. Velit nisi id laboris adipisicing in esse adipisicing commodo cillum do exercitation tempor. Consequat tempor dolor minim consequat minim ad do tempor excepteur.\r\n",
      "registered":"2014-08-10T08:34:27 -01:00",
      "latitude":27.35547,
      "longitude":-77.343791,
      "tags":[
         "reprehenderit",
         "nisi",
         "duis",
         "fugiat",
         "id",
         "non",
         "laboris"
      ],
      "friends":[
         {
            "id":0,
            "name":"Dora Combs"
         },
         {
            "id":1,
            "name":"Emerson Wade"
         },
         {
            "id":2,
            "name":"Alma Mccormick"
         }
      ],
      "greeting":"Hello, Schwartz Norman! You have 1 unread messages.",
      "favoriteFruit":"apple"
   },
   {
      "_id":"5ce6dc0cb7ae44eb76c3e5fd",
      "index":5,
      "guid":"0516df27-73db-42a8-b2c3-d34bd976e031",
      "isActive":false,
      "balance":"$3,679.94",
      "picture":"http://placehold.it/32x32",
      "age":32,
      "eyeColor":"brown",
      "name":"Christi Oneal",
      "gender":"female",
      "company":"SUREPLEX",
      "email":"christioneal@sureplex.com",
      "phone":"+1 (985) 408-3098",
      "address":"640 Fayette Street, Dennard, Washington, 7962",
      "about":"Dolore fugiat sit non dolore nostrud mollit enim id sint culpa do reprehenderit ad. Velit occaecat incididunt nostrud aliqua incididunt do cillum occaecat laboris quis duis. Non tempor culpa aliquip est est consectetur ullamco elit. Voluptate et sit do et. Amet sit irure eu ex enim nulla anim deserunt ut. Sit aute ea ut fugiat eu tempor Lorem.\r\n",
      "registered":"2015-05-10T09:24:56 -01:00",
      "latitude":43.343805,
      "longitude":79.535043,
      "tags":[
         "occaecat",
         "laboris",
         "nulla",
         "nisi",
         "dolore",
         "cillum",
         "dolore"
      ],
      "friends":[
         {
            "id":0,
            "name":"Marquez Wiggins"
         },
         {
            "id":1,
            "name":"Mai Fischer"
         },
         {
            "id":2,
            "name":"Newman Davenport"
         }
      ],
      "greeting":"Hello, Christi Oneal! You have 8 unread messages.",
      "favoriteFruit":"strawberry"
   }
]');

    --Act
    ut3_develop.ut.expect( l_actual ).to_equal( l_actual );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end; 
 
  procedure long_json_diff as  
    l_expected json_element_t;
    l_actual   json_element_t;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);
  begin
    -- Arrange
    l_expected   := json_element_t.parse('[
  {
    "_id": "5ce6ec46cb9977b050f15d97",
    "index": 0,
    "guid": "1acb2b6b-15b5-4747-a62f-db477e18df61",
    "isActive": false,
    "balance": "$1,443.80",
    "picture": "http://placehold.it/32x32",
    "age": 33,
    "eyeColor": "brown",
    "name": "Carson Conley",
    "gender": "male",
    "company": "EYEWAX",
    "email": "carsonconley@eyewax.com",
    "phone": "+1 (873) 520-2117",
    "address": "289 Wallabout Street, Cazadero, Nevada, 4802",
    "about": "Lorem aliqua veniam eiusmod exercitation anim sunt esse qui tempor officia amet nulla labore enim. Fugiat eiusmod amet exercitation incididunt mollit pariatur amet et quis et ex amet adipisicing. Elit in commodo tempor adipisicing exercitation Lorem amet cillum sint sint aliquip. Officia enim do irure velit qui officia et reprehenderit qui enim.\r\n",
    "registered": "2018-08-07T05:03:13 -01:00",
    "latitude": -1.973252,
    "longitude": 17.835529,
    "tags": [
      "dolore",
      "occaecat",
      "proident",
      "laborum",
      "nostrud",
      "non",
      "occaecat"
    ],
    "friends": [
      {
        "id": 0,
        "name": "Riggs Cardenas"
      },
      {
        "id": 1,
        "name": "Duncan Schultz"
      },
      {
        "id": 2,
        "name": "Galloway Bond"
      }
    ],
    "greeting": "Hello, Carson Conley! You have 5 unread messages.",
    "favoriteFruit": "strawberry"
  },
  {
    "_id": "5ce6ec469ba57bef5c421021",
    "index": 1,
    "guid": "59be5b73-fffe-4a4f-acea-65c5abbdb53c",
    "isActive": true,
    "balance": "$3,895.35",
    "picture": "http://placehold.it/32x32",
    "age": 21,
    "eyeColor": "brown",
    "name": "Melton Carroll",
    "gender": "male",
    "company": "ISOSPHERE",
    "email": "meltoncarroll@isosphere.com",
    "phone": "+1 (804) 416-2235",
    "address": "114 Windsor Place, Dubois, Oklahoma, 9648",
    "about": "Pariatur ea voluptate aute dolor minim laborum cillum ad reprehenderit. Mollit sint voluptate duis et culpa amet irure laborum. Nulla veniam fugiat sint proident aliquip dolore laboris nisi et. Nisi in do aliqua voluptate cupidatat enim dolor minim minim qui tempor. Eu anim ea mollit sunt esse et est cillum cillum pariatur dolor. Ea anim duis sunt eiusmod sit cillum consectetur aliquip ad et elit culpa irure commodo.\r\n",
    "registered": "2018-10-20T01:38:32 -01:00",
    "latitude": 46.821539,
    "longitude": 19.78817,
    "tags": [
      "sunt",
      "aliquip",
      "commodo",
      "occaecat",
      "mollit",
      "minim",
      "sint"
    ],
    "friends": [
      {
        "id": 0,
        "name": "Tameka Reese"
      },
      {
        "id": 1,
        "name": "Rosemarie Buckley"
      },
      {
        "id": 2,
        "name": "Houston Moran"
      }
    ],
    "greeting": "Hello, Melton Carroll! You have 10 unread messages.",
    "favoriteFruit": "strawberry"
  },
  {
    "_id": "5ce6ec464e6f8751e75ed29f",
    "index": 2,
    "guid": "42e07b71-b769-4078-b226-f79048b75bd2",
    "isActive": false,
    "balance": "$3,366.81",
    "picture": "http://placehold.it/32x32",
    "age": 23,
    "eyeColor": "blue",
    "name": "Kathie Cameron",
    "gender": "female",
    "company": "EVENTIX",
    "email": "kathiecameron@eventix.com",
    "phone": "+1 (949) 416-3458",
    "address": "171 Henderson Walk, Barstow, American Samoa, 3605",
    "about": "Lorem est mollit consequat pariatur elit. Enim adipisicing ipsum sit labore exercitation fugiat qui eu enim. Quis irure Lorem exercitation laborum sunt quis Lorem pariatur officia veniam aute officia mollit quis.\r\n",
    "registered": "2015-07-15T08:40:18 -01:00",
    "latitude": -12.947501,
    "longitude": 51.221756,
    "tags": [
      "voluptate",
      "officia",
      "laborum",
      "nulla",
      "anim",
      "mollit",
      "adipisicing"
    ],
    "friends": [
      {
        "id": 0,
        "name": "Noelle Leonard"
      },
      {
        "id": 1,
        "name": "Sally Barr"
      },
      {
        "id": 2,
        "name": "Rosie Rutledge"
      }
    ],
    "greeting": "Hello, Kathie Cameron! You have 10 unread messages.",
    "favoriteFruit": "strawberry"
  },
  {
    "_id": "5ce6ec4632328a654d592cb6",
    "index": 3,
    "guid": "6b9124a9-fbde-4c60-8dac-e296f5daa3c4",
    "isActive": true,
    "balance": "$2,374.96",
    "picture": "http://placehold.it/32x32",
    "age": 32,
    "eyeColor": "brown",
    "name": "Ebony Carver",
    "gender": "female",
    "company": "EVENTEX",
    "email": "ebonycarver@eventex.com",
    "phone": "+1 (816) 535-3332",
    "address": "452 Lott Street, Iberia, South Carolina, 1635",
    "about": "Ea cupidatat occaecat in Lorem adipisicing quis sunt. Occaecat sit Lorem eiusmod et. Velit nostrud cupidatat do exercitation. Officia esse excepteur labore aliqua fugiat dolor duis. Ullamco qui ipsum eu do nostrud et laboris magna dolor cillum. Dolore eiusmod do occaecat dolore.\r\n",
    "registered": "2017-04-12T09:20:02 -01:00",
    "latitude": 65.70655,
    "longitude": 150.667286,
    "tags": [
      "do",
      "laboris",
      "exercitation",
      "quis",
      "laboris",
      "amet",
      "sint"
    ],
    "friends": [
      {
        "id": 0,
        "name": "Rowena Holloway"
      },
      {
        "id": 1,
        "name": "Lee Chang"
      },
      {
        "id": 2,
        "name": "Delaney Kennedy"
      }
    ],
    "greeting": "Hello, Ebony Carver! You have 10 unread messages.",
    "favoriteFruit": "apple"
  },
  {
    "_id": "5ce6ec46d9dbfbf9b184cee7",
    "index": 4,
    "guid": "9dece65b-6b48-4960-880b-7795ff63c81c",
    "isActive": false,
    "balance": "$2,927.54",
    "picture": "http://placehold.it/32x32",
    "age": 27,
    "eyeColor": "green",
    "name": "Mae Payne",
    "gender": "female",
    "company": "ZEPITOPE",
    "email": "maepayne@zepitope.com",
    "phone": "+1 (904) 531-2930",
    "address": "575 Amity Street, Eden, Iowa, 4017",
    "about": "Voluptate ex enim aliqua ea et proident ipsum est anim nostrud. Duis aliquip voluptate voluptate non aliquip. Elit commodo Lorem aliqua sit elit consectetur reprehenderit in aute minim. Dolor non incididunt do tempor aliquip esse non magna anim eiusmod ut id id.\r\n",
    "registered": "2016-08-29T06:23:00 -01:00",
    "latitude": -60.325313,
    "longitude": 88.598722,
    "tags": [
      "est",
      "incididunt",
      "officia",
      "sunt",
      "eu",
      "ut",
      "deserunt"
    ],
    "friends": [
      {
        "id": 0,
        "name": "Taylor Walton"
      },
      {
        "id": 1,
        "name": "Celina Mcdonald"
      },
      {
        "id": 2,
        "name": "Berry Rivers"
      }
    ],
    "greeting": "Hello, Mae Payne! You have 4 unread messages.",
    "favoriteFruit": "strawberry"
  }
]');
    l_actual := json_element_t.parse('[
  {
    "_id": "5ce6ec6660565269b16cf836",
    "index": 0,
    "guid": "c222eda5-d925-4163-89e3-4b0e50d5e297",
    "isActive": false,
    "balance": "$3,626.25",
    "picture": "http://placehold.it/32x32",
    "age": 28,
    "eyeColor": "green",
    "name": "Leigh Munoz",
    "gender": "female",
    "company": "OATFARM",
    "email": "leighmunoz@oatfarm.com",
    "phone": "+1 (969) 545-2708",
    "address": "218 Mersereau Court, Homeworth, Connecticut, 4423",
    "about": "Eiusmod exercitation incididunt ea incididunt anim voluptate. Duis laboris ut Lorem pariatur tempor voluptate occaecat laboris. Enim duis excepteur cillum ullamco pariatur sint. Dolor labore qui ullamco deserunt do consectetur labore velit occaecat officia incididunt Lorem dolore. Pariatur dolor voluptate ex adipisicing labore quis aliquip aliquip. Culpa tempor proident nisi occaecat aliqua mollit ullamco nisi cillum ipsum exercitation quis excepteur. Consequat officia ex ipsum id consequat deserunt sunt id nostrud magna.\r\n",
    "registered": "2018-10-08T10:24:07 -01:00",
    "latitude": -42.796797,
    "longitude": -14.220273,
    "tags": [
      "ex",
      "elit",
      "consectetur",
      "ipsum",
      "aute",
      "ipsum",
      "Lorem"
    ],
    "friends": [
      {
        "id": 0,
        "name": "Selena Dunn"
      },
      {
        "id": 1,
        "name": "Wilda Haynes"
      },
      {
        "id": 2,
        "name": "Calderon Long"
      }
    ],
    "greeting": "Hello, Leigh Munoz! You have 6 unread messages.",
    "favoriteFruit": "strawberry"
  },
  {
    "_id": "5ce6ec66383ddbf3c400e3ed",
    "index": 1,
    "guid": "2e778803-50d3-411f-b34d-47d0f19d03f7",
    "isActive": false,
    "balance": "$2,299.28",
    "picture": "http://placehold.it/32x32",
    "age": 23,
    "eyeColor": "blue",
    "name": "Velez Drake",
    "gender": "male",
    "company": "GENMY",
    "email": "velezdrake@genmy.com",
    "phone": "+1 (870) 564-2219",
    "address": "526 Erskine Loop, Websterville, Nebraska, 1970",
    "about": "Consectetur Lorem do ex est dolor. Consectetur do tempor amet elit. Amet dolore cupidatat Lorem sunt reprehenderit.\r\n",
    "registered": "2017-11-24T04:42:37 -00:00",
    "latitude": -45.78579,
    "longitude": 142.062878,
    "tags": [
      "do",
      "esse",
      "nisi",
      "sunt",
      "et",
      "nisi",
      "nostrud"
    ],
    "friends": [
      {
        "id": 0,
        "name": "Bessie Schmidt"
      },
      {
        "id": 1,
        "name": "Harriett Lyons"
      },
      {
        "id": 2,
        "name": "Jerry Gonzales"
      }
    ],
    "greeting": "Hello, Velez Drake! You have 1 unread messages.",
    "favoriteFruit": "apple"
  },
  {
    "_id": "5ce6ec660a8b5f95ed543305",
    "index": 2,
    "guid": "bb0eaa88-f7fd-4b72-8538-8c0b4595bcec",
    "isActive": true,
    "balance": "$3,085.28",
    "picture": "http://placehold.it/32x32",
    "age": 36,
    "eyeColor": "green",
    "name": "Gallegos Dominguez",
    "gender": "male",
    "company": "QOT",
    "email": "gallegosdominguez@qot.com",
    "phone": "+1 (947) 581-3675",
    "address": "375 Temple Court, Beaulieu, Minnesota, 3880",
    "about": "Qui consequat est aliquip esse minim Lorem qui quis. Enim consequat anim culpa consequat ex incididunt ad incididunt est id excepteur nulla culpa. Aliqua enim enim exercitation anim velit occaecat voluptate qui minim ut ullamco fugiat. Anim voluptate nulla minim labore dolore eu veniam. Exercitation sint eiusmod aute aliqua magna aliqua pariatur Lorem velit pariatur ex duis.\r\n",
    "registered": "2019-03-11T12:36:55 -00:00",
    "latitude": -1.619328,
    "longitude": -160.580052,
    "tags": [
      "ipsum",
      "reprehenderit",
      "id",
      "aliqua",
      "ad",
      "do",
      "sunt"
    ],
    "friends": [
      {
        "id": 0,
        "name": "Justice Bruce"
      },
      {
        "id": 1,
        "name": "Alta Clements"
      },
      {
        "id": 2,
        "name": "Amy Hobbs"
      }
    ],
    "greeting": "Hello, Gallegos Dominguez! You have 10 unread messages.",
    "favoriteFruit": "strawberry"
  },
  {
    "_id": "5ce6ec6600fb7aaee2d1243e",
    "index": 3,
    "guid": "4a4363b5-9d65-4b22-9b58-a5c8c1c5bd5d",
    "isActive": false,
    "balance": "$3,152.70",
    "picture": "http://placehold.it/32x32",
    "age": 37,
    "eyeColor": "green",
    "name": "Bobbie Baldwin",
    "gender": "female",
    "company": "IDEGO",
    "email": "bobbiebaldwin@idego.com",
    "phone": "+1 (937) 501-3123",
    "address": "271 Coles Street, Deltaville, Massachusetts, 349",
    "about": "Dolor labore quis Lorem eiusmod duis adipisicing ut. Aute aute aliquip exercitation eiusmod veniam ullamco irure sit est. Ut Lorem incididunt do sint laborum cillum Lorem commodo duis. Dolor nulla ad consectetur non cillum. Est excepteur esse mollit elit laborum ullamco exercitation sit esse. Reprehenderit occaecat ad ad reprehenderit adipisicing non Lorem ipsum fugiat culpa. Do quis non exercitation ea magna elit non.\r\n",
    "registered": "2014-06-25T07:44:03 -01:00",
    "latitude": -70.045195,
    "longitude": 117.328462,
    "tags": [
      "anim",
      "excepteur",
      "aliqua",
      "mollit",
      "non",
      "in",
      "adipisicing"
    ],
    "friends": [
      {
        "id": 0,
        "name": "Lora Little"
      },
      {
        "id": 1,
        "name": "Stanton Pollard"
      },
      {
        "id": 2,
        "name": "Bernice Knowles"
      }
    ],
    "greeting": "Hello, Bobbie Baldwin! You have 5 unread messages.",
    "favoriteFruit": "apple"
  },
  {
    "_id": "5ce6ec660585cbb589b34fc8",
    "index": 4,
    "guid": "18547241-6fd0-466d-9f79-21aeb0485294",
    "isActive": false,
    "balance": "$3,853.86",
    "picture": "http://placehold.it/32x32",
    "age": 32,
    "eyeColor": "blue",
    "name": "Erika Benton",
    "gender": "female",
    "company": "SURETECH",
    "email": "erikabenton@suretech.com",
    "phone": "+1 (833) 472-2277",
    "address": "893 Jamison Lane, Grayhawk, Illinois, 1820",
    "about": "Ullamco nisi quis esse fugiat eu proident nisi cupidatat reprehenderit nostrud nulla laborum duis. Duis quis ipsum ad voluptate enim. Et excepteur irure proident adipisicing enim eu veniam aliquip nostrud amet sit est. Non laborum reprehenderit qui ullamco occaecat elit sunt ea nostrud reprehenderit incididunt sunt.\r\n",
    "registered": "2018-01-19T11:58:53 -00:00",
    "latitude": -44.595301,
    "longitude": 100.938225,
    "tags": [
      "cupidatat",
      "aliqua",
      "nostrud",
      "nostrud",
      "ipsum",
      "ipsum",
      "commodo"
    ],
    "friends": [
      {
        "id": 0,
        "name": "Addie Benjamin"
      },
      {
        "id": 1,
        "name": "Brock Nolan"
      },
      {
        "id": 2,
        "name": "Betty Suarez"
      }
    ],
    "greeting": "Hello, Erika Benton! You have 5 unread messages.",
    "favoriteFruit": "apple"
  },
  {
    "_id": "5ce6ec66ff15753596332021",
    "index": 5,
    "guid": "f865dabb-4871-4f29-9c56-17361d254f39",
    "isActive": true,
    "balance": "$3,474.90",
    "picture": "http://placehold.it/32x32",
    "age": 32,
    "eyeColor": "blue",
    "name": "Rice Owens",
    "gender": "male",
    "company": "ACIUM",
    "email": "riceowens@acium.com",
    "phone": "+1 (975) 576-3718",
    "address": "400 Halleck Street, Lafferty, District Of Columbia, 495",
    "about": "Cupidatat laborum mollit non eu aute amet consectetur aliqua officia consectetur consequat. Tempor labore pariatur Lorem sint quis laborum est dolore et. Est ipsum incididunt eiusmod enim nostrud laboris duis est enim proident do laborum id culpa.\r\n",
    "registered": "2018-05-06T02:43:06 -01:00",
    "latitude": 2.843708,
    "longitude": -3.301217,
    "tags": [
      "laboris",
      "velit",
      "dolore",
      "sunt",
      "ad",
      "aliqua",
      "duis"
    ],
    "friends": [
      {
        "id": 0,
        "name": "Ramirez King"
      },
      {
        "id": 1,
        "name": "Jeannie Boyer"
      },
      {
        "id": 2,
        "name": "Deloris Jensen"
      }
    ],
    "greeting": "Hello, Rice Owens! You have 9 unread messages.",
    "favoriteFruit": "banana"
  }
]');

    --Act
    ut3_develop.ut.expect( l_actual ).to_equal( l_expected );
    --Assert
    l_expected_message := q'[%Extra   property: object on path: $[5]
%Actual value: "5ce6ec46cb9977b050f15d97" was expected to be: "5ce6ec6660565269b16cf836" on path: $[0]."_id"
%Actual value: "5ce6ec469ba57bef5c421021" was expected to be: "5ce6ec66383ddbf3c400e3ed" on path: $[1]."_id"
%Actual value: "5ce6ec4632328a654d592cb6" was expected to be: "5ce6ec6600fb7aaee2d1243e" on path: $[3]."_id"
%Actual value: "5ce6ec464e6f8751e75ed29f" was expected to be: "5ce6ec660a8b5f95ed543305" on path: $[2]."_id"
%Actual value: "5ce6ec46d9dbfbf9b184cee7" was expected to be: "5ce6ec660585cbb589b34fc8" on path: $[4]."_id"
%Actual value: "59be5b73-fffe-4a4f-acea-65c5abbdb53c" was expected to be: "2e778803-50d3-411f-b34d-47d0f19d03f7" on path: $[1]."guid"
%Actual value: "9dece65b-6b48-4960-880b-7795ff63c81c" was expected to be: "18547241-6fd0-466d-9f79-21aeb0485294" on path: $[4]."guid"
%Actual value: "42e07b71-b769-4078-b226-f79048b75bd2" was expected to be: "bb0eaa88-f7fd-4b72-8538-8c0b4595bcec" on path: $[2]."guid"
%Actual value: "6b9124a9-fbde-4c60-8dac-e296f5daa3c4" was expected to be: "4a4363b5-9d65-4b22-9b58-a5c8c1c5bd5d" on path: $[3]."guid"
%Actual value: "1acb2b6b-15b5-4747-a62f-db477e18df61" was expected to be: "c222eda5-d925-4163-89e3-4b0e50d5e297" on path: $[0]."guid"
%Actual value: FALSE was expected to be: TRUE on path: $[2]."isActive"
%Actual value: TRUE was expected to be: FALSE on path: $[3]."isActive"
%Actual value: TRUE was expected to be: FALSE on path: $[1]."isActive"
%Actual value: "$3,895.35" was expected to be: "$2,299.28" on path: $[1]."balance"
%Actual value: "$1,443.80" was expected to be: "$3,626.25" on path: $[0]."balance"
%Actual value: "$3,366.81" was expected to be: "$3,085.28" on path: $[2]."balance"
%Actual value: "$2,927.54" was expected to be: "$3,853.86" on path: $[4]."balance"
%Actual value: "$2,374.96" was expected to be: "$3,152.70" on path: $[3]."balance"
%Actual value: 23 was expected to be: 36 on path: $[2]."age"%]';
 
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
    ut.expect(l_actual_message).to_be_like('%Diff: 133 differences found, showing first 20%');
    ut.expect(l_actual_message).to_be_like('%1 missing properties%');
    ut.expect(l_actual_message).to_be_like('%132 unequal values%');
  end;
 
  procedure check_json_objects is
    l_expected json_object_t;
    l_actual   json_object_t;
  begin
    l_expected := json_object_t('{ "name" : "Bond", "proffesion" : "spy", "drink" : "martini"}');
    l_actual   := json_object_t('{ "proffesion" : "spy","name" : "Bond", "drink" : "martini"}');
    ut3_develop.ut.expect( l_actual ).to_equal( l_expected );
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;
  
  procedure check_json_arrays is
    l_expected json_array_t;
    l_actual   json_array_t;
  begin
    l_expected := json_array_t('[  {"name" : "Bond", "proffesion" : "spy", "drink" : "martini"} , {"name" : "Kloss", "proffesion" : "spy", "drink" : "beer"} ]');
    l_actual   := json_array_t('[  {"name" : "Bond", "proffesion" : "spy", "drink" : "martini"} , {"name" : "Kloss", "proffesion" : "spy", "drink" : "beer"} ]');
    ut3_develop.ut.expect( l_actual ).to_equal( l_expected );
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

 
end;
/
