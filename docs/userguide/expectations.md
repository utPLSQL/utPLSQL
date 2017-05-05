# Concepts 

Validation of the code under test (the tested logic of procedure/function etc.) is performed by comparing the actual data against the expected data.
To do that we use concept of expectation and a matcher to perform the check on the data.

Example of unit test procedure body with a single expectation.
```sql
begin
  ut.expect( 'the tested value' ).to_equal('the expected value');
end;
```

Expectation is a set of the expected value(s), actual values(s) and the matcher(s) to run on those values.

Matcher is defining the comparison operation to be performed on expected and actual values.
Pseudo-code:
```sql
  ut.expect( a_actual {data-type} ).to_( {matcher} );
  ut.expect( a_actual {data-type} ).not_to( {matcher} );
```

Most of the matchers have shortcuts like:
```sql
  ut.expect( a_actual {data-type} ).to_{matcher};
  ut.expect( a_actual {data-type} ).not_to{matcher};
```


# Matchers
utPLSQL provides following matchers to perform checks on the expected and actual values.  
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
- `match`

## be_between
Validates that the actual value is between the lower and upper bound.

Example:
```sql
begin
  ut.expect( a_actual => 3 ).to_be_between( a_lower_bound => 1, a_upper_bound => 3 );
  ut.expect( 3 ).to_be_between( 1, 3 );
end;
```

## be_empty
Unary matcher that validates if the provided data-set is empty.

Usage:
```sql
procedure test_if_cursor_is_empty is
  l_cursor sys_refcursor;
begin
  open l_cursor for select * from dual where 1 = 0;
  ut.expect( l_cursor ).to_be_empty();
end;
```

When used with anydata, it is only valid for collection data types.

## be_false
Unary matcher that validates if the provided value is false.

Usage:
```sql
begin
  ut.expect( ( 1 = 0 ) ).to_be_false();
end;
```

## be_greater_or_equal
Allows to check if the actual value is greater or equal than the expected.

Usage:
```sql
begin
  ut.expect( sysdate ).to_be_greater_or_equal( sysdate - 1 );
end;
```

## be_greater_than
Allows to check if the actual value is greater than the expected.

Usage:
```sql
begin
  ut.expect( 2 ).to_be_greater_than( 1 );
end;
```

## be_less_or_equal
Allows to check if the actual value is less or equal than the expected.

Usage:
```sql
begin
  ut.expect( 3 ).to_be_less_or_equal( 3 );
end;
```

## be_less_than
Allows to check if the actual value is less than the expected.

Usage:
```sql
begin
  ut.expect( 3 ).to_be_less_than( 2 );
end;
```


## be_like
Validates that the actual value is like the expected expression.

Usage:
```sql
begin
  ut.expect( 'Lorem_impsum' ).to_be_like( a_mask => '%rem\_%', a_escape_char => '\' );
  ut.expect( 'Lorem_impsum' ).to_be_like( '%rem\_%', '\' );
end;
```

Parameters `a_mask` and `a_escape_char` represent a valid parameters of the [Oracle like function](https://docs.oracle.com/database/121/SQLRF/conditions007.htm#SQLRF52142)


## be_not_null
Unary matcher that validates if the actual value is not null.

Usage:
```sql
begin 
  ut.expect( to_clob('ABC') ).to_be_not_null();
end;
```

## be_null
Unary matcher that validates if the actual value is null.

Usage:
```sql
begin
  ut.expect( cast(null as varchar2(100)) ).to_be_null();
end;
```

## be_true
Unary matcher that validates if the provided value is false.
- `boolean`

Usage:
```sql
begin 
  ut.expect( ( 1 = 1 ) ).to_be_true();
end;
```

## equal

The equal matcher is a very restrictive matcher. It only returns true, if compared data-types are the same.
That means, that comparing varchar2 to a number will fail even if the varchar2 contains the same number.
This matcher is designed to capture changes of data-type, so that if you expect your variable to be number and is now something else,
 the test will fail and give you early indication of potential problem.

Usage:
```sql
procedure check_if_cursors_are_equal is
  x sys_refcursor;
  y sys_refcursor;
begin
  ut.expect( 'a dog' ).to_equal( 'a dog' );
  ut.expect( a_actual => y ).to_equal( a_expected => x, a_nulls_are_equal => true );
end;
```
The `a_nulls_are_equal` parameter decides on the behavior of `null=null` comparison (**this comparison by default is true!**)

There are no shortcuts for `not_to_equal`, so use `not_to (equal(...))`

### Comparing cursors

The `equal` matcher accepts additional parameter `a_exclude varchar2` or `a_exclude ut_varchar2_list`, when used to compare `cursor` data. 
Those parameters allow passing a list of column names to exclude from data comparison. The list can be a comma separated `varchar2` list or a `ut_varchar2_list` collection.
The column names accepted by parameter are **case sensitive** and cannot be quoted.
If `a_exclude` parameter is not specified, all columns are included. 
If a column to be excluded does not exist, the column cannot be excluded and it's name is simply ignored.
It is useful when testing cursors containing data that is beyond our control (like default or trigger/procedure generated sysdate values on columns).

```sql
procedure test_cursors_skip_columns is
  x sys_refcursor;
  y sys_refcursor;
begin
  open x for select 'text' ignore_me, d.* from user_tables d;
  open y for select sysdate "ADate", d.* from user_tables d;
  ut.expect( a_actual => y ).to_equal( a_expected => x, a_exclude => 'IGNORE_ME,ADate' );
end;
```

### Comparing cursor data containing DATE fields 

**Important note**
utPLSQL uses XMLType internally to represent rows of the cursor data. This is by far most flexible and allows comparison of cursors containing LONG, CLOB, BLOB, user defined types and even nested cursors.
Due to the way Oracle handles DATE data type when converting from cursor data to XML, utPLSQL has no control over the DATE formatting.
The NLS_DATE_FORMAT setting from the moment the cursor was opened decides ont the formatting of dates used for cursor data comparison.
By default, Oracle NLS_DATE_FORMAT is timeless, so data of DATE datatype, will be compared ignoring the time part of it.

You should use procedures `ut.set_nls`, `ut.reset_nls` around cursors that you want to compare in your tests.
This way, the DATE data in cursors will get properly formatted for comparison using date-time format.

The example below makes use of `ut.set_nls`, `ut.reset_nls`, so that date in `l_expected` and `l_actual` is compared using date-time formatting.  
```sql
create table events (
  description varchar2(4000),
  event_date  date
);

create or replace function get_events(a_date_from date, a_date_to date) return sys_refcursor is
  l_result sys_refcursor;
begin
  open l_result for
    select description, event_date
      from events
     where event_date between a_date_from and a_date_to;
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
  procedure setup_events is
  begin
    insert into events (description, event_date)
    values (gc_description, gc_event_date);
  end;

  procedure get_events_for_date_range is
    l_expected          sys_refcursor;
    l_actual            sys_refcursor;
    l_expected_bad_date sys_refcursor;
    l_second   number := 1/24/60/60;
  begin
    ut.set_nls();
    open l_expected for select gc_description as description, gc_event_date as event_date from dual;
    open l_expected_bad_date for select gc_description as description, gc_event_date + l_second as event_date from dual;
    l_actual := get_events(gc_event_date-1, gc_event_date+1);
    ut.reset_nls();

    ut.expect(l_actual).to_equal(l_expected);                        
    ut.expect(l_actual).not_to( equal(l_expected_bad_date) );                        
  end;

end;
/

begin
  ut.run();
end;
/

drop table events;
drop function get_events;
drop package test_get_events;
```

### Comparing user defined types and collections

The `anydata` data type is used to compare user defined object and collections.
  
Example usage of anydata to compare user defined types.
```sql
create type department as object(name varchar2(30));
/

create type departments as table of department;
/

create or replace package demo_dept as 
  -- %suite(demo)

  --%test(demo of object to object comparison)
  procedure test_department; 
  
  --%test(demo of collection comparison)
  procedure test_departments; 

end;
/

create or replace package body demo_dept as 
  procedure test_department is
    v_expected department;
    v_actual   department;
  begin
    v_expected := department('HR');
    v_actual   := department('IT');
    ut.expect( anydata.convertObject(v_expected) ).to_equal( anydata.convertObject(v_actual) );
  end;
  
  procedure test_department is
    v_expected department;
    v_actual   department;
  begin
    v_expected := departments(department('HR'));
    v_actual   := departments(department('IT'));
    ut.expect( anydata.convertCollection(v_expected) ).to_equal( anydata.convertCollection(v_actual) );
  end;

end;
/
```

This test will fail as the `v_acutal` is not equal `v_expected`. 

## match
Validates that the actual value is matching the expected regular expression.

Usage:
```sql
begin 
  ut.expect( a_actual => '123-456-ABcd' ).to_match( a_pattern => '\d{3}-\d{3}-[a-z]', a_modifiers => 'i' );
  ut.expect( 'some value' ).to_match( '^some.*' );
end;
```

Parameters `a_pattern` and `a_modifiers` represent a valid regexp pattern accepted by [Oracle regexp_like function](https://docs.oracle.com/database/121/SQLRF/conditions007.htm#SQLRF00501)



# Supported data types

Below matrix illustrates the data types supported by different matchers.

|                               | be_between | be_empty | be_false | be_greater_than | be_greater_or_equal | be_less_or_equal | be_less_than | be_like | be_not_null | be_null | be_true | equal | match |
|:------------------------------|:----------:|:--------:|:--------:|:---------------:|:-------------------:|:----------------:|:------------:|:-------:|:-----------:|:-------:|:-------:|:-----:|:-----:|
| anydata                       |            |    X     |          |                 |                     |                  |              |         |     X       |   X     |         |   X   |       |
| blob                          |            |          |          |                 |                     |                  |              |         |     X       |   X     |         |   X   |       |
| boolean                       |            |          |    X     |                 |                     |                  |              |         |     X       |   X     |    X    |   X   |       |
| clob                          |            |          |          |                 |                     |                  |              |   X     |     X       |   X     |         |   X   |   X   |
| date                          |    X       |          |          |       X         |         X           |      X           |     X        |         |     X       |   X     |         |   X   |       |
| number                        |    X       |          |          |       X         |         X           |      X           |     X        |         |     X       |   X     |         |   X   |       |
| refcursor                     |            |    X     |          |                 |                     |                  |              |         |     X       |   X     |         |   X   |       |
| timestamp                     |    X       |          |          |       X         |         X           |      X           |     X        |         |     X       |   X     |         |   X   |       |
| timestamp with timezone       |    X       |          |          |       X         |         X           |      X           |     X        |         |     X       |   X     |         |   X   |       |
| timestamp with local timezone |    X       |          |          |       X         |         X           |      X           |     X        |         |     X       |   X     |         |   X   |       |
| varchar2                      |    X       |          |          |                 |                     |                  |              |   X     |     X       |   X     |         |   X   |   X   |
| interval year to month        |    X       |          |          |       X         |         X           |      X           |     X        |         |     X       |   X     |         |   X   |       |
| interval day to second        |    X       |          |          |       X         |         X           |      X           |     X        |         |     X       |   X     |         |   X   |       |



# Negating the matcher
Expectations provide a very convenient way to check for a negative of the expectation.

Syntax of check for matcher evaluating to true:
```sql
begin 
  ut.expect( a_actual {data-type} ).to_{matcher};
  ut.expect( a_actual {data-type} ).to_{ (matcher} );
end;
```

Syntax of check for matcher evaluating to false:
```sql
begin 
  ut.expect( a_actual {data-type} ).not_to( {matcher} );
  ut.expect( a_actual {data-type} ).not_to_{matcher};
end;
```

If a matcher evaluated to NULL, then both `to_` and `not_to` will cause the expectation to report failure.

Example:
```sql
begin
  ut.expect( null ).to_be_true();
  ut.expect( null ).not_to( be_true() );
end;
```

Since NULL is neither true not it is not true, both expectations will report failure. 


