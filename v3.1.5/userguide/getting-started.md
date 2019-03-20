![version](https://img.shields.io/badge/version-v3.1.5.2712-blue.svg)

# Getting started with TDD and utPLSQL

utPLSQL is designed in a way that allows you to follow 
[Test Driven Development (TDD)](https://en.wikipedia.org/wiki/Test-driven_development) software development process.

Below is an example of building a simple function with TDD.

# Gather requirements

We have a requirement to build a function that will return a substring of a string that is passed to the function.

The function should accept three parameters:

- input_string
- start_position
- end_position

# Create a test 

We will start from the bare minimum and move step by step, executing tests every time we make minimal progress.
This way, we assure we don't jump ahead too much and produce code that is untested or untestable.

## Create test package

```sql
create or replace package test_betwnstr as

  --%suite(Between string function)

end;
/
```

Execute all tests: `begin ut.run(); end;`

Test results:
```
Between string function
 
Finished in .451423 seconds
0 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```

## Define specification for the test

```sql
create or replace package test_betwnstr as

  --%suite(Between string function)

  --%test(Returns substring from start position to end position)
  procedure basic_usage;

end;
/
```

Execute test package: `begin ut.run('test_betwnstr'); end;`

Test results:
```
Between string function
  Returns substring from start position to end position (FAILED - 1)
 
Failures:
 
  1) basic_usage
      ORA-04067: not executed, package body "UT3_USER.TEST_BETWNSTR" does not exist
      ORA-06508: PL/SQL: could not find program unit being called: "UT3_USER.TEST_BETWNSTR"
      ORA-06512: at line 6
Finished in .509673 seconds
1 tests, 0 failed, 1 errored, 0 disabled, 0 warning(s)
```

Well our test is failing as the package specification requires a body.

## Define body of first test

```sql
create or replace package body test_betwnstr as

  procedure basic_usage is
  begin
    ut.expect( betwnstr( '1234567', 2, 5 ) ).to_equal('2345');
  end;

end;
/
```

Execute test package: `begin ut.run('test_betwnstr'); end;`

Test results:
```
Between string function
  Returns substring from start position to end position (FAILED - 1)
 
Failures:
 
  1) basic_usage
      ORA-04063: package body "UT3_USER.TEST_BETWNSTR" has errors
      ORA-06508: PL/SQL: could not find program unit being called: "UT3_USER.TEST_BETWNSTR"
      ORA-06512: at line 6
Finished in .415851 seconds
1 tests, 0 failed, 1 errored, 0 disabled, 0 warning(s)
```

Our test is failing as the test suite package body is invalid.
Looks like we need to define the function we want to test.

# Implement code to fulfill the requirement

## Define tested function 

```sql
create or replace function betwnstr( a_string varchar2, a_start_pos integer, a_end_pos integer ) return varchar2
is
begin
  return substr( a_string, a_start_pos, a_end_pos - a_start_pos );
end;
/
```

Execute test package: `begin ut.run('test_betwnstr'); end;`

Test results:
```
Between string function
  Returns substring from start position to end position (FAILED - 1)
 
Failures:
 
  1) basic_usage
      Actual: '234' (varchar2) was expected to equal: '2345' (varchar2) 
      at ""UT3_USER.TEST_BETWNSTR"", line 5 
       
Finished in .375178 seconds
1 tests, 1 failed, 0 errored, 0 disabled, 0 warning(s)
```

So now we see that our test works but the function does not return the expected results.
Let us fix this and continue from here.

## Fix the tested function

The function returned a string one character short, so we need to add 1 to the substr parameter.

```sql
create or replace function betwnstr( a_string varchar2, a_start_pos integer, a_end_pos integer ) return varchar2 
is
begin
  return substr( a_string, a_start_pos, a_end_pos - a_start_pos + 1 );
end;
/
```

Execute test package: `begin ut.run('test_betwnstr'); end;`

Test results:
```
Between string function
  Returns substring from start position to end position
 
Finished in .006077 seconds
1 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```

So our test is now passing, great!

# Refactor

Once our tests are passing, we can safely refactor (restructure) the code as we have a safety harness 
in place to ensure that after the restructuring and cleanup of the code, everything is still working.

One thing worth mentioning is that refactoring of tests is as important as refactoring of code. Maintainability of both is equally important.

# Further requirements

It seems like our work is done. We have a function that returns a substring from start position to end position.
As we move through the process of adding tests, it's very important to think about edge cases.

Here is a list of edge cases for our function:

- start position zero
- input string is null
- start position is null
- end position is null
- start position is negative
- start position is bigger than end position
- start position is negative
- end position is negative

We should define expected behavior for each of these edge cases.
Once defined we can start implementing tests for those behaviors and adjust the tested function to meet the requirements specified in the tests.

## Add test for additional requirement

A new requirement was added: 
  Start position zero - should be treated as start position one

```sql
create or replace package test_betwnstr as

  --%suite(Between string function)

  --%test(Returns substring from start position to end position)
  procedure basic_usage;

  --%test(Returns substring when start position is zero)
  procedure zero_start_position;

end;
/

create or replace package body test_betwnstr as

  procedure basic_usage is
  begin
    ut.expect( betwnstr( '1234567', 2, 5 ) ).to_equal('2345');
  end;

  procedure zero_start_position is
  begin
    ut.expect( betwnstr( '1234567', 0, 5 ) ).to_equal('12345');
  end;

end;
/
```

Execute test package: `begin ut.run('test_betwnstr'); end;`

Test results:
```
Between string function
  Returns substring from start position to end position
  Returns substring when start position is zero (FAILED - 1)
 
Failures:
 
  1) zero_start_position
      Actual: '123456' (varchar2) was expected to equal: '12345' (varchar2) 
      at ""UT3_USER.TEST_BETWNSTR"", line 10 
       
Finished in .232584 seconds
2 tests, 1 failed, 0 errored, 0 disabled, 0 warning(s)
```

Looks like our function does not work as expected for zero start position.

## Implementing the requirement

Let's fix our function so that the new requirement is met

```sql
create or replace function betwnstr( a_string varchar2, a_start_pos integer, a_end_pos integer ) return varchar2 
is
begin
  if a_start_pos = 0 then
    return substr( a_string, a_start_pos, a_end_pos - a_start_pos );
  else
    return substr( a_string, a_start_pos, a_end_pos - a_start_pos + 1);
  end if;
end;
/
```

Execute test package: `begin ut.run('test_betwnstr'); end;`

Test results:
```
Between string function
  Returns substring from start position to end position
  Returns substring when start position is zero
 
Finished in .012718 seconds
2 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```

Great! We have made some visible progress.

## Refactoring

When all tests are passing we can proceed with a safe cleanup of our code.

The function works well, but we use the `return` twice, which is not the best coding practice.

An alternative implementation could be cleaner.
```sql
create or replace function betwnstr( a_string varchar2, a_start_pos integer, a_end_pos integer ) return varchar2
is
begin
  return substr( a_string, a_start_pos, a_end_pos - greatest( a_start_pos, 1 ) + 1 );
end;
/
```

As we refactor we should probably run our tests as often as we compile code, so we know not only that the code compiles, but also works as expected.

```
Between string function
  Returns substring from start position to end position
  Returns substring when start position is zero
 
Finished in .013739 seconds
2 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```

# Remaining requirements

You may continue on with the remaining edge cases from here.

- identify requirement
- define requirement with test
- run test to check if requirement is met
- implement code to meet requirement
- run test to check if requirement is met
- refactor/cleanup code and tests

Hope you will enjoy it as much as we do.

