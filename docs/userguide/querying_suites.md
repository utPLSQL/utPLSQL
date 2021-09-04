![version](https://img.shields.io/badge/version-v3.1.11.3491--develop-blue.svg)

# Qyerying for test suites


## Obtaining information about suites 

utPLSQL framework provides ability to read inforamtion about unit test suites that exist in a schema.

Pipelined table function `ut_runner.get_suites_info(a_owner, a_package_name)` allows you to retrieve information about:

- all suites that exist in a given user/schema
- individual test suite pacakage

Querying the data from function provides the follwing details:

- `object_owner`     - the owner of test suite packages
- `object_name`      - the name of test suite package
- `item_name`        - the name of suite/test
- `item_description` - the description of suite/suite item
- `item_type`        - the type of item (UT_SUITE/UT_SUITE_CONTEXT/UT_TEST/UT_LOGICAL_SUITE)
- `item_line_no`     - line_number where annotation identifying the item exists
- `path`             - suitepath of the item
- `disabled_flag`    - (0/1) indicator if item is disabled by --%disabled annotation
- `tags`     - tags associated with suites

To get list of all test suites in current schema 
```sql
select * from table(ut_runner.get_suites_info()) where item_type = 'UT_SUITE';
```

To get list of all tests for test suite `TEST_STUFF` in current user schema  
```sql
select * from table(ut_runner.get_suites_info(USER, 'TEST_STUFF')) where item_type = 'UT_TEST';
```

To get a full information about suite `TEST_STUFF` including suite description, all contexts and tests in a suite  
```sql
select * from table(ut_runner.get_suites_info(USER, 'TEST_STUFF')) where item_type = 'UT_TEST';
```

## Checking if schema contains tests

Function `ut_runner.has_suites(a_owner)` returns boolean value indicating if given schema contains test suites.

Example:
```sql
begin
  if ut_runner.has_suites(USER) then
    dbms_output.put_line( 'User '||USER||' owns test suites' );
  else
    dbms_output.put_line( 'User '||USER||' does not own test suites' );
  end if;
end;
```

## Checking if package is a test suite

Function `ut_runner.is_suite(a_owner, a_package_name) ` returns boolean value indicating if given package is a test suites.

Example:
```sql
begin
  if ut_runner.is_suite(USER,'TEST_STUFF') then
    dbms_output.put_line( 'Package '||USER||'.TEST_STUFF is a test suite' );
  else
    dbms_output.put_line( 'Package '||USER||'.TEST_STUFF is not a test suite' );
  end if;
end;
```

## Checking if procedure is a test within a suite

Function `ut_runner.is_test(a_owner, a_package_name, a_procedure_name) ` returns boolean value indicating if given package is a test suites.

Example:
```sql
begin
  if ut_runner.is_test(USER,'TEST_STUFF','A_TEST_TO_CHECK_STUFF') then
    dbms_output.put_line( 'Procedure '||USER||'.TEST_STUFF.A_TEST_TO_CHECK_STUFF is a test' );
  else
    dbms_output.put_line( 'Procedure '||USER||'.TEST_STUFF.A_TEST_TO_CHECK_STUFF is not a test' );
  end if;
end;
```

