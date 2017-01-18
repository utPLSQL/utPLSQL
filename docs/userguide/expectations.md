# Concept of expectation and matcher 

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

# List of currently build-in matchers
- `match`
- `equal`
- `be_true`
- `be_null`
- `be_not_null`
- `be_like`
- `be_less_than`
- `be_less_or_equal`
- `be_greater_than`
- `be_greater_or_equal`
- `be_false`
- `be_between`

## match
Allows regexp_like validations to be executed against the following datatypes:
- `clob`
- `varchar2`

Usage:
```sql
  ut.expect( a_actual ).to_( match( a_pattern in varchar2, a_modifiers in varchar2 := null) )
```

Parameters `a_pattern` and `a_modifiers` represent a valid regexp pattern accepted by [Oracle regexp_like function](http://docs.oracle.com/database/121/SQLRF/conditions007.htm#SQLRF00501)

## equal

The equal matcher is a very restrictive matcher.
It only returns true, if compared data-types.
That means, that comparing varchar2 to a number will fail even if the varchar2 contains the same number.
This matcher is designed to capture changes of data-type, so that if you expect your variable to be number and is now something else,
 the test will fail and give you early indication of potential problem.

Usage:
```sql
  ut.expect( a_actual ).to_( equal( a_expected {mulitple data-types}, a_nulls_are_equal boolean := null) )
```


The equal matcher accepts a_expected of following data-types.
- `anydata`
- `blob`
- `boolean`
- `clob`
- `date`
- `number`
- `sys_refcursor`
- `timestamp_unconstrained`
- `timestamp_tz_unconstrained`
- `timestamp_ltz_unconstrained`
- `varchar2`
- `yminterval_unconstrained`
- `dsinterval_unconstrained`

The second parameter decides on the behavior of `null=null` comparison (**this comparison by default is true!**)
 

  A test procedure will contain one or more checks to verify the the test performed as expected.   These checks are called assertion.   utPLSQL provides a robust and extensible assertion library. 


TODO: Finish Expectations concepts 
