# Running tests

The utPLSQL framework provides two main entry points to run unit tests from within the database: 

- `ut.run` procedures and functions
- `ut_runner.run` procedures

These two entry points differ in purpose and behavior.
Most of the time you will want to use `ut.run` as `ut_runner` is designed for API integration and does not output the results to the screen directly.

# utPLSQL-sql-cli

If you are considering running your tests from a command line or from a CI server like Jenkins/Teamcity, the best way is to use the [utPLSQL-sql-cli](https://github.com/utPLSQL/utPLSQL-sql-cli).
You may download the latest release of the command line client automatically using the command below (Unix).

```bash
#!/bin/bash
# Get the url to latest release "zip" file
DOWNLOAD_URL=$(curl --silent https://api.github.com/repos/utPLSQL/utPLSQL-sql-cli/releases/latest | awk '/zipball_url/ { print $2 }' | sed -r 's/"|,//g')
# Download the latest release "zip" file
curl -Lk "${DOWNLOAD_URL}" -o utplsql-sql-cli.zip
# Extract downloaded "zip" file
unzip -q utplsql-sql-cli.zip
```

# ut.run

The `ut` package contains overloaded `run` procedures and functions.
The `run` API is designed to be called directly by a developer when using an IDE/SQL console to execute unit tests.
The main benefit of using this API is it's simplicity.
A single line call is enough to execute a set of tests from one or more schemes.

The **procedures** execute the specified tests and produce output to DBMS_OUTPUT using the specified reporter.
The **functions** can only be used in SELECT statements. They execute the specified tests and produce outputs as a pipelined data stream to be consumed by a select statement.

## ut.run procedures

The examples below illustrate different ways and options to invoke `ut.run` procedures.

```sql
alter session set current_schema=hr;
begin
  ut.run();
end;
```
Executes all tests in current schema (_HR_).


```sql
begin
  ut.run('HR');
end;
```
Executes all tests in specified schema (_HR_).


```sql
begin
  ut.run('hr:com.my_org.my_project');
end;
```

Executes all tests from all packages that are on the _com.my_org.my_project_ suitepath.
Check the [annotations documentation](annotations.md) to find out about suitepaths and how they can be used to organize test packages for your project.


```sql
begin
  ut.run('hr.test_apply_bonus');
end;
```
Executes all tests from package _hr.test_apply_bonus_. 


```sql
begin
  ut.run('hr.test_apply_bonus.bonus_cannot_be_negative');
end;
```
Executes single test procedure _hr.test_apply_bonus.bonus_cannot_be_negative_.


```sql
begin
  ut.run(ut_varchar2_list('hr.test_apply_bonus','cust'));
end;
```
Executes all tests from package _hr.test_apply_bonus_ and all tests from schema _cust_.

Using a list of items to execute allows you to execute a fine-grained set of tests.


**Note:**

`ut_documentation_reporter` is the default reporter for all APIs defined for running unit tests.

The `ut.run` procedures and functions accept `a_reporter` attribute that defines the reporter to be used in the run.
You can execute any set of tests with any of the predefined reporters.

```sql
begin
  ut.run('hr.test_apply_bonus', ut_xunit_reporter());
end;
```
Executes all tests from package _HR.TEST_APPLY_BONUS_ and provide outputs to DBMS_OUTPUT using the XUnit reporter. 


For details on build-in reporters look at [reporters documentation](reporters.md).

## ut.run functions

The `ut.run` functions provide exactly the same functionality as the `ut.run` procedures. 
You may use the same sets of parameters with both functions and procedures. 
The only difference is the output of the results.
Functions provide output as a pipelined stream and therefore need to be executed as select statements.

Example.
```sql
select * from table(ut.run('hr.test_apply_bonus', ut_xunit_reporter()));
```

# ut_runner.run procedures

The `ut_runner` package provides an API for integrating utPLSQL with other products. Maven, Jenkins, SQL Develper, PL/SQL Developer, TOAD and others can leverage this API to call utPLSQL.

The main difference compared to the `ut.run` API is that `ut_runner.run` does not print output to the screen.

`ut_runner.run` accepts multiple reporters. Each reporter pipes to a separate output (uniquely identified by output_id).
Outputs of multiple reporters can be consumed in parallel. This allows for live reporting of test execution progress with threads and several database sessions.

The concept is pretty simple.

- in the main thread (session), define the reporters to be used. Each reporter has it's output_id and so you need to extract and store those output_ids.
- as a separate thread, start `ut_runner.run` and pass reporters with previously defined output_ids.
- for each reporter start a separate thread and read outputs from the `ut_output_buffer.get_lines` table function by providing the output_id defined in the main thread.
  
