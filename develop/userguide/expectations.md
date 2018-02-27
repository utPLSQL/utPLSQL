# Expectation concepts 
Validation of the code under test (the tested logic of procedure/function etc.) is performed by comparing the actual data against the expected data.
utPLSQL uses a combination of expectation and matcher to perform the check on the data.

Example of a unit test procedure body.
```sql
begin
  ut.expect( 'the tested value', 'optional custom failure message' ).to_( equal('the expected value') );
end;
```

Expectation is a set of the expected value(s), actual values(s) and the matcher(s) to run on those values.
You can also add a custom failure message for an expectation.

Matcher defines the comparison operation to be performed on expected and actual values.
Pseudo-code:
```sql
  ut.expect( a_actual {data-type} [, a_message {varchar2}] ).to_( {matcher} );
  ut.expect( a_actual {data-type} [, a_message {varchar2}] ).not_to( {matcher} );
```

All matchers have shortcuts like below, sou you don't need to surround matcher with brackets, unless you want to pass it as parameter to the expectation.
```sql
  ut.expect( a_actual {data-type} ).to_{matcher};
  ut.expect( a_actual {data-type} ).not_to_{matcher};
```

## Providing a custom failure message
You can provide a custom failure message as second argument for the expectation.
````sql
  -- Pseudocode
  ut.expect( a_actual {data-type}, a_message {varchar2} ).to_{matcher};
  -- Example
  ut.expect( 'supercat', 'checked superhero-animal was not a dog' ).to_( equal('superdog') );
````

If the message is provided, it is being added to the normal failure message returned by the matcher.

This is mostly useful when your expectations accept dynamic content, as you can provide additional context to make failing test results more readable.

### Dynamic tests example
You have a bunch of tables and an archive functionality for them and you want to test if the things you put into live-tables are removed from live-tables and present in archive-tables.

````sql
procedure test_data_existance( i_tableName varchar2 ) 
  as
    v_count_real integer;
    v_count_archive integer;
  begin
    
    execute immediate 'select count(*) from ' || i_tablename || '' into v_count_real;
    execute immediate 'select count(*) from ' || i_tablename || '_ARCHIVE' into v_count_archive;

    ut.expect( v_count_archive, 'failure checking entry-count of ' || i_tablename || '_archive' ).to_( equal(1) );
    ut.expect( v_count_real, 'failure checking entry-count of ' || i_tablename ).to_( equal(0) );

  end;

 procedure test_archive_data
  as
  begin
    -- Arrange
   -- insert several data into real-tables here

    -- Act
    package_to_test.archive_data();

    -- Assert
    test_data_existance('TABLE_A');
    test_data_existance('TABLE_B');
    test_data_existance('TABLE_C');
    test_data_existance('TABLE_D');
end;
````
A failed output will look like this:
````
Failures:
 
  1) test_archive_data
      "failure checking entry-count of table_a_archive"
      Actual: 2 (number) was expected to equal: 1 (number) 
      at "UT_TEST_PACKAGE.TEST_DATA_EXISTANCE", line 12 ut.expect( v_count_archive, 'failure checking entry-count of ' || i_tablename || '_archive' ).to_( equal(1) );
````

# Expecting exceptions

Testing is not limited to checking for happy-path scenarios. When writing tests, you often want to check that in specific scenarios, an exception is thrown.

Use the `--%throws` annotation, to test for expected exceptions 

Example:
```sql
create or replace function divide(x varchar2, y varchar2) return number is
begin
  return x/y;
end;
/

create or replace package test_divide as
  --%suite(Divide function)

  --%test(Return divided numbers)
  procedure divides_numbers;

  --%test(Throws divisor equal)
  --%throws(-01476)
  procedure raises_divisor_exception;
end;  
/

create or replace package body test_divide is

  procedure divides_numbers is
  begin
    ut3.ut.expect(divide(6,2)).to_equal(3);
  end;
  
  procedure raises_divisor_exception is
    x integer;
  begin
    x := divide(6,0);
  end;

end;
/

exec ut3.ut.run('test_divide');
```

For details see documentation of the [`--%throws` annotation.](annotations.md#throws-annotation)  


# Matchers
utPLSQL provides the following matchers to perform checks on the expected and actual values.  

- `be_between`
- `be_empty`
- `be_false`
- `be_greater_than`
- `be_greater_or_equal`
- `be_less_or_equal`
- `be_less_than`
- `be_like`
- `be_not_null`
- `be_null`
- `be_true`
- `equal`
- `have_count`
- `match`

## be_between
Validates that the actual value is between the lower and upper bound.

Example:
```sql
begin
  ut.expect( a_actual => 3 ).to_be_between( a_lower_bound => 1, a_upper_bound => 3 );
  ut.expect( 3 ).to_be_between( 1, 3 );
  --or
  ut.expect( a_actual => 3 ).to_( be_between( a_lower_bound => 1, a_upper_bound => 3 ) );
  ut.expect( 3 ).to_( be_between( 1, 3 ) );  
end;
```

## be_empty
Unary matcher that validates if the provided dataset is empty.

Can be used with `refcursor` or `table type`

Usage:
```sql
procedure test_if_cursor_is_empty is
  l_cursor sys_refcursor;
begin
  open l_cursor for select * from dual where 1 = 0;
  ut.expect( l_cursor ).to_be_empty();
  --or
  ut.expect( l_cursor ).to_( be_empty() );
end;
```

When used with anydata, it is only valid for collection data types.

## be_false
Unary matcher that validates if the provided value is false.

Usage:
```sql
begin
  ut.expect( ( 1 = 0 ) ).to_be_false();
  --or 
  ut.expect( ( 1 = 0 ) ).to_( be_false() );
end;
```

## be_greater_or_equal
Checks if the actual value is greater or equal than the expected.

Usage:
```sql
begin
  ut.expect( sysdate ).to_be_greater_or_equal( sysdate - 1 );
  --or
  ut.expect( sysdate ).to_( be_greater_or_equal( sysdate - 1 ) );
end;
```

## be_greater_than
Checks if the actual value is greater than the expected.

Usage:
```sql
begin
  ut.expect( 2 ).to_be_greater_than( 1 );
  --or 
  ut.expect( 2 ).to_( be_greater_than( 1 ) );
end;
```

## be_less_or_equal
Checks if the actual value is less or equal than the expected.

Usage:
```sql
begin
  ut.expect( 3 ).to_be_less_or_equal( 3 );
  --or 
  ut.expect( 3 ).to_( be_less_or_equal( 3 ) );
end;
```

## be_less_than
Checks if the actual value is less than the expected.

Usage:
```sql
begin
  ut.expect( 3 ).to_be_less_than( 2 );
  --or 
  ut.expect( 3 ).to_( be_less_than( 2 ) );
end;
```


## be_like
Validates that the actual value is like the expected expression.

Usage:
```sql
begin
  ut.expect( 'Lorem_impsum' ).to_be_like( a_mask => '%rem#_%', a_escape_char => '#' );
  ut.expect( 'Lorem_impsum' ).to_be_like( '%rem#_%', '#' );
  --or 
  ut.expect( 'Lorem_impsum' ).to_( be_like( a_mask => '%rem#_%', a_escape_char => '#' ) );
  ut.expect( 'Lorem_impsum' ).to_( be_like( '%rem#_%', '#' ) );
end;
```

Parameters `a_mask` and `a_escape_char` represent valid parameters of the [Oracle LIKE condition](https://docs.oracle.com/database/121/SQLRF/conditions007.htm#SQLRF52142)


## be_not_null
Unary matcher that validates if the actual value is not null.

Usage:
```sql
begin 
  ut.expect( to_clob('ABC') ).to_be_not_null();
  --or 
  ut.expect( to_clob('ABC') ).to_( be_not_null() );
  --or 
  ut.expect( to_clob('ABC') ).not_to( be_null() );
end;
```

## be_null
Unary matcher that validates if the actual value is null.

Usage:
```sql
begin
  ut.expect( cast(null as varchar2(100)) ).to_be_null();
  --or 
  ut.expect( cast(null as varchar2(100)) ).to_( be_null() );
end;
```

## be_true
Unary matcher that validates if the provided value is true.
- `boolean`

Usage:
```sql
begin 
  ut.expect( ( 1 = 1 ) ).to_be_true();
  --or 
  ut.expect( ( 1 = 1 ) ).to_( be_true() );
end;
```

## have_count
Unary matcher that validates if the provided dataset count is equal to expected value.

Can be used with `refcursor` or `table type`

Usage:
```sql
procedure test_if_cursor_is_empty is
  l_cursor sys_refcursor;
begin
  open l_cursor for select * from dual connect by level <=10;
  ut.expect( l_cursor ).to_have_count(10);
  --or
  ut.expect( l_cursor ).to_( have_count(10) );
end;
```

## match
Validates that the actual value is matching the expected regular expression.

Usage:
```sql
begin 
  ut.expect( a_actual => '123-456-ABcd' ).to_match( a_pattern => '\d{3}-\d{3}-[a-z]', a_modifiers => 'i' );
  ut.expect( 'some value' ).to_match( '^some.*' );
  --or 
  ut.expect( a_actual => '123-456-ABcd' ).to_( match( a_pattern => '\d{3}-\d{3}-[a-z]', a_modifiers => 'i' ) );
  ut.expect( 'some value' ).to_( match( '^some.*' ) );
end;
```

Parameters `a_pattern` and `a_modifiers` represent a valid regexp pattern accepted by [Oracle REGEXP_LIKE condition](https://docs.oracle.com/database/121/SQLRF/conditions007.htm#SQLRF00501)

## equal
The equal matcher is very restrictive. Test using this matcher succeeds only when the compared data-types are exactly the same.
If you are comparing `varchar2` to a `number` will fail even if the text contains the same numeric value as the number.
The matcher will also fail when comparing a `timestamp` to a `timestamp with timezone` data-type etc.
The matcher enables detection data-type changes. 
If you expect your variable to be a number and it is now some other type, the test will fail and give you early indication of a potential problem.

To keep it simple, the `equal` will only succeed if you compare apples to apples.

Example usage
```sql
function get_animal return varchar2 is 
begin
  return 'a dog';
end;
/

create or replace package test_animals_getter is

    --%suite(Animals getter tests)
    
    --%test(get_animal - returns a dog)
    procedure test_variant_1_get_animal;
    --%test(get_animal - returns a dog)
    procedure test_variant_2_get_animal;
    --%test(get_animal - returns a dog)
    procedure test_variant_3_get_animal;
    --%test(get_animal - returns a dog)
    procedure test_variant_4_get_animal;
    --%test(get_animal - returns a dog)
    procedure test_variant_5_get_animal;
end;
/
create or replace package body test_animals_getter is

    --The below tests perform exactly the same check.
    --They use different syntax to achieve the goal. 
    procedure test_variant_1_get_animal is
      l_actual   varchar2(100) := 'a dog';
      l_expected varchar2(100);
    begin
      --Arrange
      l_actual := 'a dog';
      --Act
      l_expected := get_animal();
      --Assert
      ut.expect( l_actual ).to_equal( l_expected );
    end;

    procedure test_variant_2_get_animal is
      l_expected varchar2(100);
    begin
      --Act
      l_expected := get_animal();
      --Assert
      ut.expect( l_expected ).to_equal( 'a dog' );
    end;

    procedure test_variant_3_get_animal is
    begin
      --Act / Assert
      ut.expect( get_animal() ).to_equal( 'a dog' );
    end;

    procedure test_variant_4_get_animal is
    begin
      --Act / Assert
      ut.expect( get_animal() ).to_equal( 'a dog', a_nulls_are_equal => true );
    end;

    procedure test_variant_5_get_animal is
    begin
      --Act / Assert
      ut.expect( get_animal() ).to_( equal( 'a dog' ) );
    end;

    procedure test_variant_6_get_animal is
    begin
      --Act / Assert
      ut.expect( get_animal() ).to_( equal( 'a dog', a_nulls_are_equal => true ) );
    end;
end;
```

**Comparing NULLs is by default!**
The `a_nulls_are_equal` parameter controls the behavior of a `null = null` comparison.


## Comparing objects, cursors, collections of data 

utPLSQL is capable of comparing compound data-types including:
- ref cursors 
- object types
- nested table/varray types

### Notes on comparison of compound data
- Compound data can contain elements of any data-type. This includes blob, clob, object type, nested table, varray or nested-cursor.   
- Cursors, nested table and varray types are compared as **ordered lists of elements**. If order of elements differ, expectation will fail.   
- Comparison of compound data does not currently support data-type check on attribute/column level. This might be changed in the future.
- Comparison of cursor columns containing `DATE` will only compare date part **and ignore time** by default. See [Comparing cursor data containing DATE fields](#comparing-cursor-data-containing-date-fields) to check how to enable date-time comparison in cursors.
- To compare nested table/varray type you need to convert it to `anydata` by using `anydata.convertCollection()`  
- To compare object type you need to convert it to `anydata` by using `anydata.convertObject()`  
- It is possible to compare PL/SQL records and nested tables/varrays/associative arrays of PL/SQL records. To compare this types of data, use cursor comparison feature of utPLSQL and TABLE operator in SQL query
    - On Oracle 11g Release 2 - pipelined table functions are needed (see section [Implicit (Shadow) Types in this artcile](https://oracle-base.com/articles/misc/pipelined-table-functions))
    - On Oracle 12c and above - use [TABLE function on nested tables/varrays/associative arrays of PL/SQL records](https://oracle-base.com/articles/12c/using-the-table-operator-with-locally-defined-types-in-plsql-12cr1) 
   

utPLSQL offers advanced data-comparison options, for comparing compound data-types. The options allow you to:
- define columns/attributes to exclude from comparison
- define columns/attributes to include in comparison
- and more

For details on available options and how to use them, read the [advanced data comparison](advanced_data_comparison.md) guide.   


### Compound data comparison examples

Cursor comparison. 
```sql
create or replace function get_user_tables return sys_refcursor is
  l_result sys_refcursor;
begin
  open l_result for select d.* from user_tables d;
  return l_result;
end;
/

create or replace package test_cursor_example is
  --%suite(example)
  
  --%test(compare cursors)
  procedure test_cursors;
end;
/    
create or replace package body test_cursor_example is    
  procedure test_cursors is
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_expected for select d.* from user_tables d;
    --Act/Assert
    ut.expect( get_user_tables() ).to_equal( l_expected );
  end;
end;
/
begin
  ut.run('test_cursor_example');
end;
/
drop package test_cursor_example;
drop function get_user_tables;
```

Object type comparison.
```sql
create type department as object(name varchar2(30))
/
create or replace function get_dept return department is 
begin
 return department('IT');
end;
/
create or replace package demo_dept as 
  -- %suite(demo)

  --%test(demo of object to object comparison)
  procedure test_department; 
end;
/
create or replace package body demo_dept as 
  procedure test_department is
    v_actual   department;
  begin
    --Act/ Assert
    ut.expect( anydata.convertObject( get_dept() ) ).to_equal( anydata.convertObject( department('HR') ) );
  end;
end;
/
begin
  ut.run('demo_dept');
end;
/

drop package demo_dept;
drop function get_dept;
drop type department;
```

Table type comparison.
```sql
create type department as object(name varchar2(30))
/
create type departments as table of department
/
create or replace function get_depts return departments is 
begin
 return departments( department('IT'), department('HR') );
end;
/
create or replace package demo_depts as 
  -- %suite(demo)

  --%test(demo of collection comparison)
  procedure test_departments; 
end;
/
create or replace package body demo_depts as 
  procedure test_departments is
    v_expected departments;
    v_actual   departments;
  begin
    v_expected := departments(department('HR'), department('IT') );
    ut.expect( anydata.convertCollection( get_depts() ) ).to_equal( anydata.convertCollection( v_expected ) );
  end;
end;
/
begin
  ut.run('demo_depts');
end;
/

drop package demo_dept;
drop type function get_depts;
drop type departments;
drop type department;
```

### Comparing cursor data containing DATE fields 

**Important note**

utPLSQL uses XMLType internally to represent rows of the cursor data. This is by far the most flexible method and allows comparison of cursors containing LONG, CLOB, BLOB, user defined types and even nested cursors.
Due to the way Oracle handles DATE data type when converting from cursor data to XML, utPLSQL has no control over the DATE formatting.
The NLS_DATE_FORMAT setting from the moment the cursor was opened determines the formatting of dates used for cursor data comparison.
By default, Oracle NLS_DATE_FORMAT is timeless, so data of DATE datatype, will be compared ignoring the time component.

You should use procedures `ut.set_nls`, `ut.reset_nls` around cursors that you want to compare in your tests.
This way, the DATE data in cursors will be properly formatted for comparison using date-time format.

The example below makes use of `ut.set_nls`, `ut.reset_nls`, so that the date in `l_expected` and `l_actual` is compared using date-time formatting.  
```sql
create table events ( description varchar2(4000), event_date  date )
/
create or replace function get_events return sys_refcursor is
  l_result sys_refcursor;
begin
  open l_result for select description, event_date from events;
  return l_result;
end;
/

create or replace package test_get_events is
  --%suite(get_events)

  --%beforeall
  procedure setup_events;
  --%test(returns event within date range)
  procedure get_events_for_date_range;
end;
/

create or replace package body test_get_events is

  gc_description constant varchar2(30) := 'Test event';
  gc_event_date  constant date := to_date('2016-09-08 06:51:22','yyyy-mm-dd hh24:mi:ss');
  gc_second      constant number := 1/24/60/60;
  procedure setup_events is
  begin
    insert into events (description, event_date) values (gc_description, gc_event_date);
  end;

  procedure get_events_for_date_range is
    l_actual            sys_refcursor;
    l_expected_bad_date sys_refcursor;
  begin
    --Arrange
    ut.set_nls(); -- Change the NLS settings for date to be ISO date-time 'YYYY-MM-DD HH24:MI:SS' 
    open l_expected_bad_date for select gc_description as description, gc_event_date + gc_second as event_date from dual;
    --Act
    l_actual := get_events();
    ut.reset_nls(); -- Change the NLS settings after cursors were opened
    --Assert
    ut.expect( l_actual ).not_to_equal( l_expected_bad_date );
  end;

  procedure bad_test is
    l_expected_bad_date sys_refcursor;
  begin
    --Arrange
    open l_expected_bad_date for select gc_description as description, gc_event_date + gc_second as event_date from dual;
    --Act / Assert
    ut.expect( get_events() ).not_to_equal( l_expected_bad_date );
  end;

end;
/

begin
  ut.run('test_get_events');
end;
/

drop table events;
drop function get_events;
drop package test_get_events;
```
In the above example:
- The test `get_events_for_date_range` will succeed, as the `l_expected_bad_date` cursor contains different date-time then the cursor returned by `get_events` function call.
- The test `bad_test` will fail, as the column `event_date` will get compared as DATE without TIME.


# Negating a matcher
Expectations provide a very convenient way to perform a check on a negated matcher.

Syntax to check for matcher evaluating to true:
```sql
begin 
  ut.expect( a_actual {data-type} ).to_{matcher};
  ut.expect( a_actual {data-type} ).to_( {matcher} );
end;
```

Syntax to check for matcher evaluating to false:
```sql
begin
  ut.expect( a_actual {data-type} ).not_to_{matcher};
  ut.expect( a_actual {data-type} ).not_to( {matcher} );
end;
```

If a matcher evaluated to NULL, then both `to_` and `not_to` will cause the expectation to report failure.

Example:
```sql
begin
  ut.expect( null ).to_( be_true() );
  ut.expect( null ).not_to( be_true() );
end;
```
Since NULL is neither *true* nor *false*, both expectations will report failure.

# Supported data types

The matrix below illustrates the data types supported by different matchers.

|                               | be_between | be_empty | be_false | be_greater_than | be_greater_or_equal | be_less_or_equal | be_less_than | be_like | be_not_null | be_null | be_true | equal | have_count | match |
|:------------------------------|:----------:|:--------:|:--------:|:---------------:|:-------------------:|:----------------:|:------------:|:-------:|:-----------:|:-------:|:-------:|:-----:|:----------:|:-----:|
| anydata( collection, object ) |            |    X     |          |                 |                     |                  |              |         |     X       |   X     |         |   X   |      X     |       |
| blob                          |            |          |          |                 |                     |                  |              |         |     X       |   X     |         |   X   |            |       |
| boolean                       |            |          |    X     |                 |                     |                  |              |         |     X       |   X     |    X    |   X   |            |       |
| clob                          |            |          |          |                 |                     |                  |              |   X     |     X       |   X     |         |   X   |            |   X   |
| date                          |    X       |          |          |       X         |         X           |      X           |     X        |         |     X       |   X     |         |   X   |            |       |
| number                        |    X       |          |          |       X         |         X           |      X           |     X        |         |     X       |   X     |         |   X   |            |       |
| refcursor                     |            |    X     |          |                 |                     |                  |              |         |     X       |   X     |         |   X   |      X     |       |
| timestamp                     |    X       |          |          |       X         |         X           |      X           |     X        |         |     X       |   X     |         |   X   |            |       |
| timestamp with timezone       |    X       |          |          |       X         |         X           |      X           |     X        |         |     X       |   X     |         |   X   |            |       |
| timestamp with local timezone |    X       |          |          |       X         |         X           |      X           |     X        |         |     X       |   X     |         |   X   |            |       |
| varchar2                      |    X       |          |          |                 |                     |                  |              |   X     |     X       |   X     |         |   X   |            |   X   |
| interval year to month        |    X       |          |          |       X         |         X           |      X           |     X        |         |     X       |   X     |         |   X   |            |       |
| interval day to second        |    X       |          |          |       X         |         X           |      X           |     X        |         |     X       |   X     |         |   X   |            |       |




