![version](https://img.shields.io/badge/version-v3.1.14.4105--develop-blue.svg)

utPLSQL framework provides two main entry points to run unit tests from within the database: 

- `ut.run` procedures and functions
- `ut_runner.run` procedures

These two entry points differ in purpose and behavior.
Most of the time you will want to use `ut.run` as `ut_runner.run` is designed for API integration and does not display the results to the screen.

## Running from CI servers and command line

The best way to run your tests from CI server or command line is to use the [utPLSQL-cli](https://github.com/utPLSQL/utPLSQL-cli) command line client.

Amongst many benefits it provides ability to:
* see the progress of test execution for long-running tests - real-time reporting
* use many reporting formats simultaneously and save reports to files (publish)
* map your project source files and test files into database objects 

You may download the latest release of the command line client from [here](https://github.com/utPLSQL/utPLSQL-cli/releases/latest) or do it automatically using the command below (Unix).

```bash
#!/bin/bash
# Get the url to latest release "zip" file
DOWNLOAD_URL=$(curl --silent https://api.github.com/repos/utPLSQL/utPLSQL-cli/releases/latest | awk '/browser_download_url/ { print $2 }' | grep ".zip\"" | sed 's/"//g')
# Download the latest release "zip" file
curl -Lk "${DOWNLOAD_URL}" -o utplsql-cli.zip
# Extract downloaded "zip" file
unzip -q utplsql-cli.zip
```


## ut.run

The `ut` package contains overloaded `run` procedures and functions.
The `run` API is designed to be called directly by a developer when using an IDE/SQL console to execute unit tests.
The main benefit of using this API is it's simplicity.
A single line call is enough to execute a set of tests from one or more schemes.

The **procedures** execute the specified tests and produce output to DBMS_OUTPUT using the specified reporter.
The **functions** can only be used in SELECT statements. They execute the specified tests and produce outputs as a pipelined data stream to be consumed by a select statement.

### ut.run procedures

The examples below illustrate different ways and options to invoke `ut.run` procedures.
You can use a wildcard character `*` to call tests by part of their name or to call tests that are located on paths matched by part of path string.
Wildcard character can be placed anywhere on the path and can occur mutliple times.
Schema name cannot contain a wildcard character whether is in a suitepath call or call by object name.

```sql linenums="1"
alter session set current_schema=hr;
set serveroutput on
begin
  ut.run();
end;
```
Executes all tests in current schema (_HR_).


```sql linenums="1"
set serveroutput on
begin
  ut.run('HR');
end;
```
Executes all tests in specified schema (_HR_).


```sql linenums="1"
set serveroutput on
begin
  ut.run('hr:com.my_org.my_project');
end;
```

Executes all tests from all packages that are on the _com.my_org.my_project_ suitepath.
Check the [annotations documentation](annotations.md) to find out about suitepaths and how they can be used to organize test packages for your project.

```sql linenums="1"
set serveroutput on
begin
  ut.run('hr:com*');
end;
```

Executes all tests in schema `hr` from all packages that are on suitepath starting with `com`.

```sql linenums="1"
set serveroutput on
begin
  ut.run('hr:co*.my_*.my_*');
end;
```

Executes all tests in schema `hr` from all packages that starting with `my_` and all tests starting with `my_*` that are on suitepath starting with `co` .

```sql linenums="1"
set serveroutput on
begin
  ut.run('hr.test_apply_bonus');
end;
```
Executes all tests from package _hr.test_apply_bonus_. 


```sql linenums="1"
set serveroutput on
begin
  ut.run('hr.test_apply_bonus.bonus_cannot_be_negative');
end;
```
Executes single test procedure _hr.test_apply_bonus.bonus_cannot_be_negative_.


```sql linenums="1"
set serveroutput on
begin
  ut.run(ut_varchar2_list('hr.test_apply_bonus','cust'));
end;
```
Executes all tests from package _hr.test_apply_bonus_ and all tests from schema _cust_.

```sql linenums="1"
set serveroutput on
begin
  ut.run(ut_varchar2_list('hr.test_apply_bonus,cust)');
end;
```

Executes all tests from package _hr.test_apply_bonus_ and all tests from schema _cust_.

```sql linenums="1"
set serveroutput on
begin
  ut.run('hr.test_apply_bonus,cust');
end;
```

Executes all tests from package _hr.test_apply_bonus_ and all tests from schema _cust_.

Using a list of items to execute allows you to execute a fine-grained set of tests.

List can be passed as a comma separated list or a list of *ut_varchar2_list objects* or as a list within ut_varchar2_list.

```sql linenums="1"
set serveroutput on
begin
  ut.run('hr.test*');
end;
```
Executes all tests in schema `hr` located in packages starting with name `test`.

```sql linenums="1"
set serveroutput on
begin
  ut.run('hr.test_apply_bonus.bonus_*');
end;
```
Executes test procedures with names starting with `bonus` in package `hr.test_apply_bonus` .


**Note:**

`ut_documentation_reporter` is the default reporter for all APIs defined for running unit tests.

The `ut.run` procedures and functions accept `a_reporter` attribute that defines the reporter to be used in the run.
You can execute any set of tests with any of the predefined reporters.

```sql linenums="1"
set serveroutput on
begin
  ut.run('hr.test_apply_bonus', ut_junit_reporter());
end;
```
Executes all tests from package _HR.TEST_APPLY_BONUS_ and provide outputs to DBMS_OUTPUT using the JUnit reporter. 


For details on build-in reporters look at [reporters documentation](reporters.md).

### ut.run functions

The `ut.run` functions provide exactly the same functionality as the `ut.run` procedures. 
You may use the same sets of parameters with both functions and procedures. 
The only difference is the output of the results.
Functions provide output as a pipelined stream and therefore need to be executed as select statements.

**Note:**
>When running tests with `ut.run` functions, whole test run is executed as autonomous transaction.
At the end of the run, the transaction is automatically rolled-back and all uncommitted changes are reverted.   

Example.
```sql linenums="1"
select * from table(ut.run('hr.test_apply_bonus', ut_junit_reporter()));
```

## ut_runner.run procedures

The `ut_runner` package provides an API for integrating utPLSQL with other products. Maven, Jenkins, SQL Develper, PL/SQL Developer, TOAD and others can leverage this API to call utPLSQL.

The main difference compared to the `ut.run` API is that `ut_runner.run` does not print output to the screen.

`ut_runner.run` accepts multiple reporters. Each reporter pipes to a separate output (uniquely identified by output_id).
Outputs of multiple reporters can be consumed in parallel. This allows for live reporting of test execution progress with threads and several database sessions.

`ut_runner.run` API is used by utPLSQL-cli, utPLSQL-SQLDeveloper extension and utPLSQL-maven-plugin and allows for:
- deciding on the scope of test run (by schema names, object names, suite paths or tags )
- running tests with several concurrent reporters
- real-time reporting of test execution progress
- controlling colored text output to the screen
- controlling scope of code coverage reports
- mapping of database source code to project files
- controlling behavior on test-failures
- controlling client character set for HTML and XML reports
- controlling rollback behavior of test-run
- controlling random order of test execution

Running with multiple reporters.

- in the main thread (session), define the reporters to be used. Each reporter has it's output_id and so you need to extract and store those output_ids.
- as a separate thread, start `ut_runner.run` and pass reporters with previously defined output_ids.
- for each reporter start a separate thread and read outputs from the `reporter.get_lines` table function or from `reporter.get_lines_cursor()` by providing the `reporter_id` defined in the main thread.
- each reporter for each test-run must have a unique `reporter_id`. The `reporter_id` is used between two sessions to identify the data stream 

Example:
```sql linenums="1"
--main test run ( session 1 )
declare
  l_reporter      ut_realtime_reporter := ut_realtime_reporter();
begin
  l_reporter.set_reporter_id( 'd8a79e85915640a6a4e1698fdf90ba74' );
  l_reporter.output_buffer.init();
  ut_runner.run (ut_varchar2_list ('ut3_tester','ut3_user'), ut_reporters( l_reporter ) );
end;
/
```

```sql linenums="1"
--report consumer ( session 2 )
set arraysize 1
set pagesize 0

select * 
  from table(
         ut_realtime_reporter()
           .set_reporter_id('d8a79e85915640a6a4e1698fdf90ba74')
           .get_lines()
  );
```

```sql linenums="1"
--alternative version of report consumer ( session 2 )
set arraysize 1
set pagesize 0

select
    ut_realtime_reporter()
      .set_reporter_id('d8a79e85915640a6a4e1698fdf90ba74')
      .get_lines_cursor()
  from dual;
```

  
## Order of test execution

### Default order

When unit tests are executed without random order, they are ordered by:
- schema name
- suite path or test package name if `--%suitepath` was not specified for that package  
- `--%test` line number in package
 
### Random order

You can force a test run to execute tests in random order by providing one of options to `ut.run`:
- `a_random_test_order` - true/false for procedures and 1/0 for functions
- `a_random_test_order_seed` - positive number in range of 1 .. 1 000 000 000 

When tests are executed with random order, randomization is applied to single level of suitepath hierarchy tree.
This is needed to maintain visibility and accessibility of common setup/cleanup `beforeall`/`afterall` in tests.

Example:
```sql linenums="1"
set serveroutput on
begin
  ut.run('hr.test_apply_bonus', a_random_test_order => true);
end;
```

```sql linenums="1"
select * from table(ut.run('hr.test_apply_bonus', a_random_test_order => 1));
```

When running with random order, the default report (`ut_documentation_reporter`) will include information about the random test run seed.
Example output:
```
...
Finished in .12982 seconds
35 tests, 0 failed, 0 errored, 1 disabled, 0 warning(s)
Tests were executed with random order seed '302980531'.
```

If you want to re-run tests using previously generated seed, you may do so by running them with parameter `a_random_test_order_seed`
Example:
```sql linenums="1"
set serveroutput on
begin
  ut.run('hr.test_apply_bonus', a_random_test_order_seed => 302980531);
end;
```

```sql linenums="1"
select * from table(ut.run('hr.test_apply_bonus', a_random_test_order_seed => 302980531));
```

**Note**
>Random order seed must be a positive number within range of 1 .. 1 000 000 000. 
  
## Run by Tags

In addition to the path, you can filter the tests to be run by specifying tags. Tags are defined in the test / context / suite with the `--%tags`-annotation ([Read more](annotations.md#tags)).  
Multiple tags are separated by comma. 


### Tag Expressions

Tag expressions are boolean expressions created by combining tags with the `!`, `&`, `|` operators. Tag expressions can be grouped using `(` and `)` braces. Grouping tag expressions affects operator precedence.

| Operator | Meaning |
| -------- | --------|
| !        | not     |
| &        | and     |
| \|        | or      |

If you are tagging your tests across multiple dimensions, tag expressions help you to select which tests to execute. When tagging by test type (e.g., micro, integration, end-to-end) and feature (e.g., product, catalog, shipping), the following tag expressions can be useful.


| Tag Expression | Selection |
| -------- | --------|
| product        | all tests for product     |
| catalog \| shipping        | all tests for catalog plus all tests for shipping     |
| catalog & shipping       | all tests that are tagged with both `catalog` and `shipping` tags      |
| product & !end-to-end | all tests tagged `product`, except the tests tagged `end-to-end` |
| (micro \| integration) & (product \| shipping) | all micro or integration tests for product or shipping |


Taking the last expression above `(micro | integration) & (product | shipping)`

| --%tags	|included in run |
| -------- | --------|
| micro	| no |
| integration |	no |
| micro	| no | 
| product	| no |
| shipping	| no |
| micro	| no |
| micro, integration | no |
| product, shipping	| no |
| micro, product	| yes |
| micro, shipping	| yes |
| integration, product |	yes |
| integration, shipping |	yes |
| integration, micro, shipping |	yes |
| integration, micro, product |	yes |
| integration, shipping ,product |	yes |
| micro, shipping ,product |	yes |
| integration, micro, shipping ,product |	yes |


### Sample execution of test with tags.

Execution of the test with tag expressions is done using the parameter `a_tags`.
Given a test package `ut_sample_test` defined below 

```sql linenums="1"
create or replace package ut_sample_test is

   --%suite(Sample Test Suite)
   --%tags(api)

   --%test(Compare Ref Cursors)
   --%tags(complex,fast)
   procedure ut_refcursors1;

   --%test(Run equality test)
   --%tags(simple,fast)
   procedure ut_test;
   
end ut_sample_test;
/

create or replace package body ut_sample_test is

   procedure ut_refcursors1 is
      v_actual   sys_refcursor;
      v_expected sys_refcursor;
   begin
    open v_expected for select 1 as test from dual;
    open v_actual   for select 2 as test from dual;

      ut.expect(v_actual).to_equal(v_expected);
   end;
   
   procedure ut_test is
   begin
       ut.expect(1).to_equal(0);
   end;
   
end ut_sample_test;
/
```

```sql linenums="1"
select * from table(ut.run(a_path => 'ut_sample_test',a_tags => 'api'));
```
The above call will execute all tests from `ut_sample_test` package as the whole suite is tagged with `api`

```sql linenums="1"
select * from table(ut.run(a_tags => 'fast&complex'));
```
The above call will execute only the `ut_sample_test.ut_refcursors1` test, as only the test `ut_refcursors1` is tagged with `complex` and `fast`

```sql linenums="1"
select * from table(ut.run(a_tags => 'fast'));
```
The above call will execute both `ut_sample_test.ut_refcursors1` and `ut_sample_test.ut_test` tests, as both tests are tagged with `fast`

### Excluding tests/suites by tags

It is possible to exclude parts of test suites with tags.
In order to do so, prefix the tag name to exclude with a `!` (exclamation) sign when invoking the test run which is equivalent of `-` (dash) in legacy notation.
Examples (based on above sample test suite)

```sql linenums="1"
select * from table(ut.run(a_tags => '(api|fast)&!complex'));
```

or 

```sql linenums="1"
select * from table(ut.run(a_tags => '(api|fast)&!complex&!test1'));
```

The above call will execute all suites/contexts/tests that are marked with any of tags `api` or `fast` except those suites/contexts/tests that are marked as `complex` and except those suites/contexts/tests that are marked as `test1`. 
Given the above example package `ut_sample_test`, only `ut_sample_test.ut_test` will be executed.  


## Keeping uncommitted data after test-run

utPLSQL by default runs tests in autonomous transaction and performs automatic rollback to assure that tests do not impact one-another and do not have impact on the current session in your IDE.

If you would like to keep your uncommitted data persisted after running tests, you can do so by using `a_force_manual_rollback` flag.
Setting this flag to true has following side-effects:

- test execution is done in current transaction - if while running tests commit or rollback is issued your current session data will get commited too.
- automatic rollback is forced to be disabled in test-run even if it was explicitly enabled by using annotation `--%rollback(manual)

Example invocation:
```sql linenums="1"
set serveroutput on
begin
  ut.run('hr.test_apply_bonus', a_force_manual_rollback => true);
end;
```

**Note:**
>This option is not available when running tests using `ut.run` as a table function.

## Reports character-set encoding

To get properly encoded reports, when running utPLSQL with HTML/XML reports on data containing national characters you need to provide your client character set when calling `ut.run` functions and procedures.

If you run your tests using `utPLSQL-cli`, this is done automatically and no action needs to be taken.

To make sure that the reports will display your national characters properly when running from IDE like SQLDeveloper/TOAD/SQLPlus or sqlcl you need to provide the charaterset manualy to `ut.run`.

Example call with characterset provided:
```sql linenums="1"
begin
  ut.run('hr.test_apply_bonus', ut_junit_reporter(), a_client_character_set => 'Windows-1251');
end;
``` 