# Concepts 

Validation of the code under test (the tested logic of procedure/function etc.) is performed by comparing the actual data against the expected data.
To do that we use concept of expectation and a matcher to perform the check on the data.

It's best to give an example to get an idea what is what
```sql
begin
  ut.expect( 'the tested value' ).to_( equal('the expected value') );
end;
```

Expectation is a set of the expected value(s), actual values(s) and the matcher(s) to run on those values.

Matcher is defining the comparison operation to be performed on expected and actual values. 

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

Usage:
```sql
  ut.expect( a_actual {mulitple data-types} ).to_( be_between( a_lower_bound {mulitple data-types}, a_upper_bound {mulitple data-types}) );
```

## be_empty
Unary matcher that validates if the provided dataset is empty.

Usage:
```sql
  ut.expect( a_actual {mulitple data-types} ).to_( be_empty() );
```

When used with anydata, it is only valid for collection data types.

## be_false
Unary matcher that validates if the provided value is false.

Usage:
```sql
  ut.expect( a_actual buulean ).to_( be_false() );
```

## be_greater_or_equal
Allows to check if the actual value is greater or equal than the expected.

Usage:
```sql
  ut.expect( a_actual {mulitple data-types} ).to_( be_greater_or_equal( a_expected {mulitple data-types}) );
```

## be_greater_than
Allows to check if the actual value is greater than the expected.

Usage:
```sql
  ut.expect( a_actual {mulitple data-types} ).to_( be_greater_than( a_expected {mulitple data-types}) );
```

## be_less_or_equal
Allows to check if the actual value is less or equal than the expected.

Usage:
```sql
  ut.expect( a_actual {mulitple data-types} ).to_( be_less_or_equal( a_expected {mulitple data-types}) );
```

## be_less_than
Allows to check if the actual value is less than the expected.

Usage:
```sql
  ut.expect( a_actual {mulitple data-types} ).to_( be_less_than( a_expected {mulitple data-types}) );
```


## be_like
Validates that the actual value is like the expected expression.

Usage:
```sql
  ut.expect( a_actual {mulitple data-types} ).to_( be_like( a_mask in varchar2, a_escape_char in varchar2 := null) );
```

Parameters `a_mask` and `a_escape_char` represent a valid parameters of the [Oracle like function](https://docs.oracle.com/database/121/SQLRF/conditions007.htm#SQLRF52142)


## be_not_null
Unary matcher that validates if the actual value is not null.

Usage:
```sql
  ut.expect( a_actual {mulitple data-types} ).to_( be_not_null() );
```

## be_null
Unary matcher that validates if the actual value is null.

Usage:
```sql
  ut.expect( a_actual {mulitple data-types} ).to_( be_null() );
```

## be_true
Unary matcher that validates if the provided value is false.
- `boolean`

Usage:
```sql
  ut.expect( a_actual buulean ).to_( be_false() );
```

## equal

The equal matcher is a very restrictive matcher. It only returns true, if compared data-types.
That means, that comparing varchar2 to a number will fail even if the varchar2 contains the same number.
This matcher is designed to capture changes of data-type, so that if you expect your variable to be number and is now something else,
 the test will fail and give you early indication of potential problem.

Usage:
```sql
  ut.expect( a_actual {mulitple data-types} ).to_( equal( a_expected {mulitple data-types}, a_nulls_are_equal boolean := null) );
```
The `a_nulls_are_equal` parameter decides on the behavior of `null=null` comparison (**this comparison by default is true!**)

The `anydata` data type is used to compare user defined object and collections.
  
Example usage of anydata to compare user defined types.
```sql
create type department as object(name varchar2(30));
/
create or replace package demo_dept as 
  -- %suite(demo)

  --%test(demo_dept)
  procedure test_department 
end;
/

create or replace package body demo_dept as 
  procedure test_department is
    v_expected department;
    v_actual   department;
  begin
    v_expected := department('HR');
    ut.expect( anydata.convertObject(v_expected) ).to_( equal( anydata.convertObject(v_actual) ) );
  end;
end;
/
```

This test will fail as the `v_acutal` is not equal `v_expected`. 

## match
Validates that the actual value is matching the expected regular expression.

Usage:
```sql
  ut.expect( a_actual {mulitple data-types} ).to_( match( a_pattern in varchar2, a_modifiers in varchar2 := null) );
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
  ut.expect( a_actual {mulitple data-types} ).to_( {matcher} );
```

Syntax of check for matcher evaluating to false:
```sql
  ut.expect( a_actual {mulitple data-types} ).not_to( {matcher} );
```

If a matcher evaluated to NULL, then both `to_` and `not_to` will cause the expectation to report failure.

Example:
```sql
  ut.expect( null ).to_( be_true() );
  ut.expect( null ).not_to( be_true() );
```

Since NULL is neither true not it is not true, both expectations will report failure. 


