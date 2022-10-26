![version](https://img.shields.io/badge/version-v3.1.13.4064--develop-blue.svg)

Annotations are used to configure tests and suites in a declarative way similar to modern OOP languages. This way, test configuration is stored along with the test logic inside the test package.
No additional configuration files or tables are needed for test cases. The annotation names are based on popular testing frameworks such as JUnit.
The framework runner searches for all the suitable annotated packages, automatically configures suites, forms the suite hierarchy, executes it and reports results in specified formats.

Annotation is defined by:

- single line comment `--` (double hyphen)
- followed directly by a `%` (percent)
- followed by annotation name 
- followed by optional annotation text placed in single brackets. 

All text between first opening bracket and last closing bracket in annotation line is considered to be annotation text

For example  `--%suite(The name of my test suite)` represents `suite` annotation with `The name of my test suite` as annotation text.  

utPLSQL interprets the whole line of annotation and will treat text from the first opening bracket in the line to the last closing bracket in that line as annotation text 

In below example we have a `suite` annotation with `Stuff) -- we should name this ( correctly ` as the annotation text

`--%suite(Stuff) -- we should name this ( correctly )`

Do not place comments within annotation line to avoid unexpected behaviors.

**Note:**
>Annotations are interpreted only in the package specification and are case-insensitive. We strongly recommend using lower-case annotations as described in this documentation.

There are two distinct types of annotations, identified by their location in package.
- package annotations
- procedure annotations

### Procedure level annotations

Annotation placed directly before a procedure (`--%test`, `--%beforeall`, `--%beforeeach` etc.).
There **can not** be any empty lines or comments between annotation line and procedure line.
There can be many annotations for a procedure. 

Valid procedure annotations example:
```sql linenums="1"
package test_package is
  --%suite

   
  --%test()
  --%disabled
  procedure my_first_procedure;

  $if dbms_db_version.version >= 12 $then --This is ok - annotation before procedure 
  --%test() 
  procedure my_first_procedure;
  $end

  --A comment goes before annotations
  --%test()
  procedure my_first_procedure;
end;
```

Invalid procedure annotations examples:
```sql linenums="1"
package test_package is
  --%suite
   
  --%test()   --This is wrong as there is an empty line between procedure and annotation

  procedure my_first_procedure;
   
  --%test()
  --This is wrong as there is a comment line between procedure and annotation
  procedure proc1;

  --%test() --This is wrong as there is a compiler directive between procedure and annotation
  $if dbms_db_version.version >= 12 $then  
  procedure proc_12;
  $end

  --%test()  
  -- procedure another_proc; 
  /* The above is wrong as the procedure is commented out 
     and annotation is not procedure annotation anymore */

end;
```

### Package level annotations  
 
Those annotations placed at any place in package except directly before procedure (`--%suite`, `--%suitepath` etc.).
We strongly recommend putting package level annotations at the very top of package except for the `--%context` annotations (described below)  

Valid package annotations example:
```sql linenums="1"
package test_package is

  --%suite

  --%suitepath(org.utplsql.example) 
 
  --%beforeall(some_package.some_procedure)
  
  --%context
  
  --%test()
  procedure my_first_procedure;
  --%endcontext
end;
```

Invalid  package annotations examples:
```sql linenums="1"
package test_package is
  --%suite               --This is wrong as suite annotation is not a procedure annotation
  procedure irrelevant;
   
  --%context  --This is wrong as there is no empty line between package level annotation and procedure level annotation
  --%test()   
  procedure my_first_procedure;

end;
```

## Supported annotations

| Annotation                                                 | Level             | Description                                                                                                                                                                                                                                                                                                                  |
|------------------------------------------------------------|-------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `--%suite( <description> )`                                | Package           | Mandatory. Marks package as a test suite. Optional suite description can be provided (see `displayname`).                                                                                                                                                                                                                    |
| `--%suitepath( <path> )`                                   | Package           | Similar to java package. The annotation allows logical grouping of suites into hierarchies.                                                                                                                                                                                                                                  |
| `--%displayname( <description> )`                          | Package/procedure | Human-readable and meaningful description of a context/suite/test. Overrides the `<description>` provided with `suite`/`test`/`context` annotation. This annotation is redundant and might be removed in future releases.                                                                                                    |
| `--%test( <description> )`                                 | Procedure         | Denotes that the annotated procedure is a unit test procedure.  Optional test description can be provided (see `displayname`).                                                                                                                                                                                               |
| `--%throws( <exception>[,...] )`                           | Procedure         | Denotes that the annotated test procedure must throw one of the exceptions provided. Supported forms of exceptions are: numeric literals, numeric constant names, exception constant names, predefined Oracle exception names.                                                                                               |
| `--%beforeall`                                             | Procedure         | Denotes that the annotated procedure should be executed once before all elements of the suite.                                                                                                                                                                                                                               |
| `--%beforeall( [[<owner>.]<package>.]<procedure>[,...] )`  | Package           | Denotes that the mentioned procedure(s) should be executed once before all elements of the suite.                                                                                                                                                                                                                            |
| `--%afterall`                                              | Procedure         | Denotes that the annotated procedure should be executed once after all elements of the suite.                                                                                                                                                                                                                                |
| `--%afterall( [[<owner>.]<package>.]<procedure>[,...] )`   | Package           | Denotes that the mentioned procedure(s) should be executed once after all elements of the suite.                                                                                                                                                                                                                             |
| `--%beforeeach`                                            | Procedure         | Denotes that the annotated procedure should be executed before each `%test` procedure in the suite.                                                                                                                                                                                                                          |
| `--%beforeeach( [[<owner>.]<package>.]<procedure>[,...] )` | Package           | Denotes that the mentioned procedure(s) should be executed before each `%test` procedure in the suite.                                                                                                                                                                                                                       |
| `--%aftereach`                                             | Procedure         | Denotes that the annotated procedure should be executed after each `%test` procedure in the suite.                                                                                                                                                                                                                           |
| `--%aftereach( [[<owner>.]<package>.]<procedure>[,...] )`  | Package           | Denotes that the mentioned procedure(s) should be executed after each `%test` procedure in the suite.                                                                                                                                                                                                                        |
| `--%beforetest( [[<owner>.]<package>.]<procedure>[,...] )` | Procedure         | Denotes that mentioned procedure(s) should be executed before the annotated `%test` procedure.                                                                                                                                                                                                                               |
| `--%aftertest( [[<owner>.]<package>.]<procedure>[,...] )`  | Procedure         | Denotes that mentioned procedure(s) should be executed after the annotated `%test` procedure.                                                                                                                                                                                                                                |
| `--%rollback( <type> )`                                    | Package/procedure | Defines transaction control. Supported values: `auto`(default) - a savepoint is created before invocation of each "before block" is and a rollback to specific savepoint is issued after each "after" block; `manual` - rollback is never issued automatically. Property can be overridden for child element (test in suite) |
| `--%disabled( <reason> )`                                  | Package/procedure | Used to disable a suite, whole context or a test. Disabled suites/contexts/tests do not get executed, they are however marked and reported as disabled in a test run. The reason that will be displayed next to disabled tests is decided based on hierarchy suites -> context -> test                                       |
| `--%context( <description> )`                              | Package           | Denotes start of a named context (sub-suite) in a suite package an optional description for context can be provided.                                                                                                                                                                                                         |
| `--%name( <name> )`                                        | Package           | Denotes name for a context. Must be placed after the context annotation and before start of nested context.                                                                                                                                                                                                                  |
| `--%endcontext`                                            | Package           | Denotes end of a nested context (sub-suite) in a suite package                                                                                                                                                                                                                                                               |
| `--%tags`                                                  | Package/procedure | Used to label a test or a suite for purpose of identification                                                                                                                                                                                                                                                                |

### Suite

The `--%suite` annotation denotes PLSQL package as a unit test suite.
It accepts an optional description that will be visible when running the tests.
When description is not provided, package name is displayed on report.

**Note**
>Package is considered a test-suite only when package specification contains the `--%suite` annotation at the package level.
>
>Some annotations like `--%suite`, `--%test` and `--%displayname` accept parameters. The parameters for annotations need to be placed in brackets.
Values for parameters should be provided without any quotation marks.
If the parameters are placed without brackets or with incomplete brackets, they will be ignored.
>
>Example: `--%suite(The name of suite without closing bracket`
>Example: `--%suite The name of suite without brackets`


Suite package without description.
```sql linenums="1"
create or replace package test_package as
  --%suite
end;
/
```
```sql linenums="1"
exec ut.run('test_package');
```
```
test_package
 
Finished in .002415 seconds
0 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```

Suite package with description.
```sql linenums="1"
create or replace package test_package as
  --%suite(Tests for a package)
end;
/
```
```sql linenums="1"
exec ut.run('test_package');
```
```
Tests for a package
 
Finished in .001646 seconds
0 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```

When multiple `--%suite` annotations are specified in package, the first annotation will be used and a warning message will appear indicating duplicate annotation.
```sql linenums="1"
create or replace package test_package as
  --%suite(Tests for a package)
  --%suite(Bad annotation)
end;
/
```
```sql linenums="1"
exec ut.run('test_package');
```
```
Tests for a package
 
 
Warnings:
 
  1) test_package
      Duplicate annotation "--%suite". Annotation ignored.
      at "TESTS_OWNER.TEST_PACKAGE", line 3
 
Finished in .003318 seconds
0 tests, 0 failed, 0 errored, 0 disabled, 1 warning(s)
```

When `--%suite` annotation is bound to procedure, it is ignored and results in package not getting recognized as test suite.
```sql linenums="1"
create or replace package test_package as
  --%suite(Tests for a package)
  procedure some_proc;
end;
/
```
```sql linenums="1"
exec ut.run('test_package');
```
```
ORA-20204: Suite package TESTS_OWNER.test_package not found
ORA-06512: at "UT3.UT_RUNNER", line 106
ORA-06512: at "UT3.UT", line 115
ORA-06512: at "UT3.UT", line 306
ORA-06512: at "UT3.UT", line 364
ORA-06512: at line 1
```


### Test

The `--%test` annotation denotes procedure withing test suite as a unit test.
It accepts an optional description that will be reported when the test is executed.
When description is not provided, procedure name is displayed on report.


If `--%test` raises an unhandled exception the following will happen:
- the test will be marked as errored and exception stack trace will be captured and reported
- the `--%aftertest`, `--%aftereach` procedures **will be executed** for the errored test
- the `--%afterall` procedures **will be executed**
- test execution will continue uninterrupted for rest of the suite 

Test procedure without description.
```sql linenums="1"
create or replace package test_package as
  --%suite(Tests for a package)
  
  --%test
  procedure some_test;
end;
/
create or replace package body test_package as
  procedure some_test is begin null; end;
end;
/
```
```sql linenums="1"
exec ut.run('test_package');
```
```
Tests for a package
  some_test [.003 sec]
 
Finished in .004109 seconds
1 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```

Test procedure with description.
```sql linenums="1"
create or replace package test_package as
  --%suite(Tests for a package)
  
  --%test(Description of tested behavior)
  procedure some_test;
end;
/
create or replace package body test_package as
  procedure some_test is begin null; end;
end;
/
```

```sql linenums="1"
exec ut.run('test_package');
```
```
Tests for a package
  Description of tested behavior [.005 sec]
 
Finished in .006828 seconds
1 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```

When multiple `--%test` annotations are specified for a procedure, the first annotation will be used and a warning message will appear indicating duplicate annotation.
```sql linenums="1"
create or replace package test_package as
  --%suite(Tests for a package)
  
  --%test(Description of tested behavior)
  --%test(Duplicate description)
  procedure some_test;
end;
/
create or replace package body test_package as
  procedure some_test is begin null; end;
end;
/
```

```sql linenums="1"
exec ut.run('test_package');
```
```
Tests for a package
  Description of tested behavior [.007 sec]
 
 
Warnings:
 
  1) test_package
      Duplicate annotation "--%test". Annotation ignored.
      at "TESTS_OWNER.TEST_PACKAGE.SOME_TEST", line 5
 
Finished in .008815 seconds
1 tests, 0 failed, 0 errored, 0 disabled, 1 warning(s)
```

### Disabled
Marks annotated suite package or test procedure as disabled.
You can provide the reason why the test is disabled that will be displayed in output.

Disabling suite.
```sql linenums="1"
create or replace package test_package as
  --%suite(Tests for a package)
  --%disabled(Reason for disabling suite)
  
  --%test(Description of tested behavior)
  procedure some_test;

  --%test(Description of another behavior)
  procedure other_test;
end;
/
create or replace package body test_package as

  procedure some_test is begin null; end;
  
  procedure other_test is begin null; end;
end;
/
```

```sql linenums="1"
exec ut.run('test_package');
```
```
Tests for a package
  Description of tested behavior [0 sec] (DISABLED - Reason for disabling suite)
  Description of another behavior [0 sec] (DISABLED - Reason for disabling suite)
 
Finished in .001441 seconds
2 tests, 0 failed, 0 errored, 2 disabled, 0 warning(s)
```

Disabling the context(s).
```sql linenums="1"
create or replace package test_package as
  --%suite(Tests for a package)
  
  --%context(Context1)

  --%test(Description of tested behavior)
  procedure some_test;

  --%endcontext

  --%context(Context2)

  --%disabled(Reason for disabling context2)

  --%test(Description of another behavior)
  procedure other_test;

  --%endcontext
end;
/
create or replace package body test_package as
  
  procedure some_test is begin null; end;
  
  procedure other_test is begin null; end;
end;
/
```

```sql linenums="1"
exec ut.run('test_package');
```
```
Tests for a package
  Context1
    Description of tested behavior [.002 sec]
  Context2
    Description of another behavior [0 sec] (DISABLED - Reason for disabling context2)
 
Finished in .005079 seconds
2 tests, 0 failed, 0 errored, 1 disabled, 0 warning(s)
```

Disabling individual test(s).
```sql linenums="1"
create or replace package test_package as
  --%suite(Tests for a package)
  
  --%test(Description of tested behavior)
  procedure some_test;

  --%test(Description of another behavior)
  --%disabled(Reason for disabling test)
  procedure other_test;
end;
/
create or replace package body test_package as
  
  procedure some_test is begin null; end;
  
  procedure other_test is begin null; end;
end;
/
```

```sql linenums="1"
exec ut.run('test_package');
```
```
Tests for a package
  Description of tested behavior [.004 sec]
  Description of another behavior [0 sec] (DISABLED - Reason for disabling test)
 
Finished in .005868 seconds
2 tests, 0 failed, 0 errored, 1 disabled, 0 warning(s)
```

### Beforeall

There are two possible ways  to use the `--%beforeall` annotation.

As a procedure level annotation:
```sql linenums="1"
--%suite(Some test suite)

--%beforeall
procedure to_be_executed_before_all;

--%test
procedure some_test;
```
Marks annotated procedure to be executed before all test procedures in a suite.

As a package level annotation (not associated with any procedure).
```sql linenums="1"
--%suite(Some test suite)

--%beforeall(to_be_executed_before_all, other_package.some_setup)

--%test
procedure some_test;

procedure to_be_executed_before_all;

```
Indicates that the procedure(s) mentioned as the annotation parameter are to be executed before all test procedures in a suite.


If `--%beforeall` raises an exception, suite content cannot be safely executed as the setup was not executed successfully for the suite. 

If `--%beforeall` raises an exception the following will happen:

- the `--%beforeall` procedures that follow the failed one, **will not be executed**
- all `--%test` procedures and their `--%beforeeach`, `--%aftereach`, `--%beforetest` and `--%aftertest` procedures within suite package **will not be executed**
- all `--%test` procedures **will be marked as failed**
- the `--%afterall` procedures **will be executed**
- test execution will continue uninterrupted for other suite packages 

When multiple `--%beforeall` procedures are defined in a suite package, all of them will be executed before invoking any test.

For multiple `--%beforeall` procedures order of execution is defined by annotation position in the package specification.

```sql linenums="1"
create or replace package test_package as
  --%suite(Tests for a package)

  --%test(Description of tested behavior)
  procedure some_test;

  --%test(Description of another behavior)
  procedure other_test;

  --%beforeall
  procedure setup_stuff;
  
end;
/
create or replace package body test_package as
  procedure setup_stuff is
  begin
    dbms_output.put_line('--- SETUP_STUFF invoked ---');
  end;
  
  procedure some_test is begin null; end;
  
  procedure other_test is begin null; end;
end;
/
```

```sql linenums="1"
exec ut.run('test_package');
```

```
Tests for a package
  --- SETUP_STUFF invoked ---
  Description of tested behavior [.004 sec]
  Description of another behavior [.003 sec]
 
Finished in .012292 seconds
2 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```

In the below example a combination pacakge and procedure level `--%beforeall` annotations is used.
The order of execution of the beforeall procedures is determined by the annotation position in package. 
All of the `--%beforeall` procedures get invoked before any test is executed in a suite.  
```sql linenums="1"
  create or replace package test_package as
    --%suite(Tests for a package)
  
    --%beforeall(initial_setup,test_package.another_setup)
  
    --%test(Description of tested behavior)
    procedure some_test;
  
    --%test(Description of another behavior)
    procedure other_test;
     
    --%beforeall
    procedure next_setup;
  
    --%beforeall(one_more_setup)

    procedure another_setup;
    procedure one_more_setup;
    procedure initial_setup;
 
  end;
  /
  create or replace package body test_package as
    procedure one_more_setup is
    begin
      dbms_output.put_line('--- ONE_MORE_SETUP invoked ---');
    end;
    
    procedure next_setup is
    begin
      dbms_output.put_line('--- NEXT_SETUP invoked ---');
    end;
    
    procedure another_setup is
    begin
      dbms_output.put_line('--- ANOTHER_SETUP invoked ---');
    end;
    
    procedure initial_setup is
    begin
      dbms_output.put_line('--- INITIAL_SETUP invoked ---');
    end;
    
    procedure some_test is begin null; end;
    
    procedure other_test is begin null; end;
  end;
  /
```

```sql linenums="1"
 exec ut.run('test_package');
```

```
Tests for a package
  --- INITIAL_SETUP invoked ---
  --- ANOTHER_SETUP invoked ---
  --- NEXT_SETUP invoked ---
  --- ONE_MORE_SETUP invoked ---
  Description of tested behavior [.003 sec]
  Description of another behavior [.002 sec]
 
Finished in .018944 seconds
2 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```

When multiple `--%beforeall` annotations are specified for a procedure, the first annotation will be used and a warning message will appear indicating duplicate annotation.  
When procedure is annotated as both `--%beforeall` and `--%test`, the procedure will become a test and a warning message will appear indicating invalid annotation combination.    
```sql linenums="1"
 create or replace package test_package as
   --%suite(Tests for a package)
 
   --%beforeall
   --%beforeall
   procedure initial_setup;
   
   --%test(Description of tested behavior)
   --%beforeall
   procedure some_test;
 
   --%test(Description of another behavior)
   procedure other_test;
 
 end;
 /
 create or replace package body test_package as

   procedure initial_setup is
   begin
     dbms_output.put_line('--- INITIAL_SETUP invoked ---');
   end;

   procedure some_test is begin null; end;

   procedure other_test is begin null; end;
 end;
 /
```

```sql linenums="1"
 exec ut.run('test_package');
```

```
Tests for a package
  --- INITIAL_SETUP invoked ---
  Description of tested behavior [.003 sec]
  Description of another behavior [.004 sec]
 
 
Warnings:
 
  1) test_package
      Duplicate annotation "--%beforeall". Annotation ignored.
      at "UT3_TESTER.TEST_PACKAGE.INITIAL_SETUP", line 5
  2) test_package
      Annotation "--%beforeall" cannot be used with annotation: "--%test"
      at "UT3_TESTER.TEST_PACKAGE.SOME_TEST", line 9
 
Finished in .012158 seconds
2 tests, 0 failed, 0 errored, 0 disabled, 2 warning(s)
```


### Afterall

There are two possible ways  to use the `--%afterall` annotation.

As a procedure level annotation:
```sql linenums="1"
--%suite(Some test suite)

--%afterall
procedure to_be_executed_after_all;

--%test
procedure some_test;
```
Marks annotated procedure to be executed after all test procedures in a suite.

As a package level annotation (not associated with any procedure).
```sql linenums="1"
--%suite(Some test suite)

--%afterall(to_be_executed_after_all, other_package.some_cleanup)

--%test
procedure some_test;

procedure to_be_executed_after_all;
```

Indicates that the procedure(s) mentioned as the annotation parameter are to be executed after all test procedures in a suite.

If `--%afterall` raises an exception the following will happen:

- a warning will be raised, indicating that `--%afterall` procedure has failed
- execution will continue uninterrupted for rest of the suite 

If `--%afterall` raises an exception, it can have negative impact on other tests, as the environment was not cleaned-up after the tests. 
This however doesn't have direct impact on test execution within current suite, as the tests are already complete by the time `--%afterall` is called. 

When multiple `--%afterall` procedures are defined in a suite, all of them will be executed after invoking all tests from the suite.

For multiple `--%afterall` procedures order of execution is defined by annotation position in the package specification.

All rules defined for `--%beforeall` also apply for `--%afterall` annotation. See [beforeall](#Beforeall) for more details.

```sql linenums="1"
create or replace package test_package as
  --%suite(Tests for a package)

  --%test(Description of tested behavior)
  procedure some_test;

  --%test(Description of another behavior)
  procedure other_test;

  --%afterall
  procedure cleanup_stuff;
  
end;
/
create or replace package body test_package as
  procedure cleanup_stuff is
  begin
    dbms_output.put_line('---CLEANUP_STUFF invoked ---');
  end;
  
  procedure some_test is begin null; end;
  
  procedure other_test is begin null; end;
end;
/
```

```sql linenums="1"
exec ut.run('test_package');
```

```
Tests for a package
  Description of tested behavior [.003 sec]
  Description of another behavior [.005 sec]
  ---CLEANUP_STUFF invoked ---
 
Finished in .014161 seconds
2 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```

### Beforeeach

The procedure annotated as `--%beforeeach` is getting executed before each test in a suite.
That means that the procedure will be executed as many times as there are test in suite package.

There are two possible ways  to use the `--%beforeeach` annotation.

As a procedure level annotation:
```sql linenums="1"
--%suite(Some test suite)

--%beforeeach
procedure to_be_executed_before_each;

--%test
procedure some_test;
```
Marks annotated procedure to be executed before each test procedures in a suite.

As a package level annotation (not associated with any procedure).
```sql linenums="1"
--%suite(Some test suite)

--%beforeeach(to_be_executed_before_each, other_package.some_setup)

--%test
procedure some_test;

procedure to_be_executed_before_each;
```

Indicates that the procedure(s) mentioned as the annotation parameter are to be executed before each test procedure in a suite.


If a test is marked as disabled the `--%beforeeach` procedure is not invoked for that test.

If `--%beforeeach` raises an unhandled exception the following will happen:

- the following `--%beforeeach` as well as all `--%beforetest` for that test **will not be executed**
- the test will be marked as errored and exception stack trace will be captured and reported
- the `--%aftertest`, `--%aftereach` procedures **will be executed** for the errored test
- the `--%afterall` procedures **will be executed**
- test execution will continue uninterrupted for rest of the suite 

As a rule, the `--%beforeeach` execution gets aborted if preceding `--%beforeeach` failed. 

When multiple `--%beforeeach` procedures are defined in a suite, all of them will be executed before invoking each test.

For multiple `--%beforeeach` procedures order of execution is defined by annotation position in the package specification.

```sql linenums="1"
create or replace package test_package as
  --%suite(Tests for a package)

  --%test(Description of tested behavior)
  procedure some_test;

  --%test(Description of another behavior)
  procedure other_test;

  --%beforeeach
  procedure setup_for_test;
  
  --%beforeall
  procedure setup_stuff;
end;
/
create or replace package body test_package as
  procedure setup_stuff is
  begin
    dbms_output.put_line('---SETUP_STUFF invoked ---');
  end;

  procedure setup_for_test is
  begin
    dbms_output.put_line('---SETUP_FOR_TEST invoked ---');
  end;
  
  procedure some_test is 
  begin 
    dbms_output.put_line('---SOME_TEST invoked ---');
  end;
  
  procedure other_test is 
  begin 
    dbms_output.put_line('---OTHER_TEST invoked ---');
  end;
end;
/
```

```sql linenums="1"
exec ut.run('test_package');
```

```
Tests for a package
  ---SETUP_STUFF invoked ---
  Description of tested behavior [.004 sec]
  ---SETUP_FOR_TEST invoked ---
  ---SOME_TEST invoked ---
  Description of another behavior [.006 sec]
  ---SETUP_FOR_TEST invoked ---
  ---OTHER_TEST invoked ---
 
Finished in .014683 seconds
2 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```

See [beforeall](#Beforeall) for more examples.

### Aftereach

Marks annotated procedure to be executed after each test procedure in a suite.

The procedure annotated as `--%aftereach` is getting executed after each test in a suite.
That means that the procedure will be executed as many times as there are test in suite package.

There are two possible ways  to use the `--%aftereach` annotation.

As a procedure level annotation:
```sql linenums="1"
--%suite(Some test suite)

--%aftereach
procedure to_be_executed_after_each;

--%test
procedure some_test;
```
Marks annotated procedure to be executed after each test procedures in a suite.

As a package level annotation (not associated with any procedure).
```sql linenums="1"
--%suite(Some test suite)

--%aftereach(to_be_executed_after_each, other_package.some_setup)

--%test
procedure some_test;

procedure to_be_executed_after_each;
```

Indicates that the procedure(s) mentioned as the annotation parameter are to be executed after each test procedure in a suite.

If a test is marked as disabled the `--%aftereach` procedure is not invoked for that test.

If `--%aftereach` raises an unhandled exception the following will happen:

- the test will be marked as errored and exception stack trace will be captured and reported
- the `--%aftertest`, `--%aftereach` procedures **will be executed** for the errored test
- the `--%afterall` procedures **will be executed**
- test execution will continue uninterrupted for rest of the suite 

When multiple `--%aftereach` procedures are defined in a suite, all of them will be executed after invoking each test.

For multiple `--%aftereach` procedures order of execution is defined by the annotation position in the package specification.

As a rule, the `--%aftereach` gets executed even if the associated `--%beforeeach`, `--%beforetest`, `--%test` or other `--%aftereach` procedures have raised unhandled exceptions. 

```sql linenums="1"
create or replace package test_package as
  --%suite(Tests for a package)

  --%test(Description of tested behavior)
  procedure some_test;

  --%test(Description of another behavior)
  procedure other_test;

  --%aftereach
  procedure cleanup_for_test;
  
  --%afterall
  procedure cleanup_stuff;
end;
/
create or replace package body test_package as
  procedure cleanup_stuff is
  begin
    dbms_output.put_line('---CLEANUP_STUFF invoked ---');
  end;

  procedure cleanup_for_test is
  begin
    dbms_output.put_line('---CLEANUP_FOR_TEST invoked ---');
  end;
  
  procedure some_test is 
  begin 
    dbms_output.put_line('---SOME_TEST invoked ---');
  end;
  
  procedure other_test is 
  begin 
    dbms_output.put_line('---OTHER_TEST invoked ---');
  end;
end;
/
```
```sql linenums="1"
exec ut.run('test_package');
```
```
Tests for a package
  Description of tested behavior [.006 sec]
  ---SOME_TEST invoked ---
  ---CLEANUP_FOR_TEST invoked ---
  Description of another behavior [.006 sec]
  ---OTHER_TEST invoked ---
  ---CLEANUP_FOR_TEST invoked ---
  ---CLEANUP_STUFF invoked ---
 
Finished in .018115 seconds
2 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```

See [beforeall](#Beforeall) for more examples.

### Beforetest

Indicates specific setup procedure(s) to be executed for a test. The procedure(s) can be located either:

- within current package (package name is optional)
- within another package 

The annotation need to be placed alongside `--%test` annotation.

The `--%beforetest` procedures are executed after invoking all `--%beforeeach` for a test.

If a test is marked as disabled the `--%beforetest` procedures are not invoked for that test.

If `--%beforetest` raises an unhandled exception the following will happen:

- the following `--%beforetest` for that test **will not be executed**
- the test will be marked as errored and exception stack trace will be captured and reported
- the `--%aftertest`, `--%aftereach` procedures **will be executed** for the errored test
- the `--%afterall` procedures **will be executed**
- test execution will continue uninterrupted for rest of the suite 

When multiple `--%beforetest` procedures are defined for a test, all of them will be executed before invoking the test.

The order of execution for `--%beforetest` procedures is defined by:

- position of procedure on the list within single annotation
- annotation position

As a rule, the `--%beforetest` execution gets aborted if preceding `--%beforeeach` or `--%beforetest` failed. 

```sql linenums="1"
create or replace package test_package as
  --%suite(Tests for a package)

  --%test(Description of tested behavior)
  --%beforetest(test_package.setup_for_a_test)
  --%beforetest(another_setup_for_a_test)
  procedure some_test;

  --%test(Description of another behavior)
  --%beforetest(test_package.setup_for_a_test, another_setup_for_a_test)
  procedure other_test;

  procedure another_setup_for_a_test;

  procedure setup_for_a_test;
  
end;
/
create or replace package body test_package as
  procedure setup_for_a_test is
  begin
    dbms_output.put_line('---SETUP_FOR_A_TEST invoked ---');
  end;

  procedure another_setup_for_a_test is
  begin
    dbms_output.put_line('---ANOTHER_SETUP_FOR_A_TEST invoked ---');
  end;
  
  procedure some_test is 
  begin 
    dbms_output.put_line('---SOME_TEST invoked ---');
  end;
  
  procedure other_test is 
  begin 
    dbms_output.put_line('---OTHER_TEST invoked ---');
  end;
end;
/
```
```sql linenums="1"
exec ut.run('test_package');
```
```
Tests for a package
  Description of tested behavior [.008 sec]
  ---SETUP_FOR_A_TEST invoked ---
  ---ANOTHER_SETUP_FOR_A_TEST invoked ---
  ---SOME_TEST invoked ---
  Description of another behavior [.005 sec]
  ---SETUP_FOR_A_TEST invoked ---
  ---ANOTHER_SETUP_FOR_A_TEST invoked ---
  ---OTHER_TEST invoked ---
 
Finished in .015185 seconds
2 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```


### Aftertest

Indicates specific cleanup procedure(s) to be executed for a test. The procedure(s) can be located either:

- within current package (package name is optional)
- within another package 

The annotation need to be placed alongside `--%test` annotation.

If a test is marked as disabled the `--%aftertest` procedures are not invoked for that test.

If `--%aftertest` raises an unhandled exception the following will happen:

- the test will be marked as errored and exception stack trace will be captured and reported
- the following `--%aftertest` and all `--%aftereach` procedures **will be executed** for the errored test
- the `--%afterall` procedures **will be executed**
- test execution will continue uninterrupted for rest of the suite 

When multiple `--%aftertest` procedures are defined for a test, all of them will be executed after invoking the test.

The order of execution for `--%aftertest` procedures is defined by:

- position of procedure on the list within single annotation
- annotation position

As a rule, the `--%aftertest` gets executed even if the associated `--%beforeeach`, `--%beforetest`, `--%test` or other `--%aftertest` procedures have raised unhandled exceptions. 

```sql linenums="1"
create or replace package test_package as
  --%suite(Tests for a package)

  --%test(Description of tested behavior)
  --%aftertest(test_package.cleanup_for_a_test)
  --%aftertest(another_cleanup_for_a_test)
  procedure some_test;

  --%test(Description of another behavior)
  --%aftertest(test_package.cleanup_for_a_test, another_cleanup_for_a_test)
  procedure other_test;

  procedure another_cleanup_for_a_test;

  procedure cleanup_for_a_test;
  
end;
/
create or replace package body test_package as
  procedure cleanup_for_a_test is
  begin
    dbms_output.put_line('---CLEANUP_FOR_A_TEST invoked ---');
  end;

  procedure another_cleanup_for_a_test is
  begin
    dbms_output.put_line('---ANOTHER_CLEANUP_FOR_A_TEST invoked ---');
  end;
  
  procedure some_test is 
  begin 
    dbms_output.put_line('---SOME_TEST invoked ---');
  end;
  
  procedure other_test is 
  begin 
    dbms_output.put_line('---OTHER_TEST invoked ---');
  end;
end;
/
```
```sql linenums="1"
exec ut.run('test_package');
```
```
Tests for a package
  Description of tested behavior [.008 sec]
  ---SOME_TEST invoked ---
  ---CLEANUP_FOR_A_TEST invoked ---
  ---ANOTHER_CLEANUP_FOR_A_TEST invoked ---
  Description of another behavior [.006 sec]
  ---OTHER_TEST invoked ---
  ---CLEANUP_FOR_A_TEST invoked ---
  ---ANOTHER_CLEANUP_FOR_A_TEST invoked ---
 
Finished in .016873 seconds
2 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```

### Context

In most of the cases, the code to be tested is consisting of PLSQL packages containing procedures and functions.
When creating test suites, it's quite common to maintain `one to one` relationship between test suite packages and tested code.

When it comes to test procedures themselves, it is best practice to have one test procedure for one tested behavior of the code that is tested.
The relationship between test procedure and tested code will be therefore `many to one` or `many to many` in most of the cases.

With this comes a challenge. How to group tests, related to one tested behavior, so that it is obvious that they relate to the same thing.

This is where utPLSQL contexts come handy. 

Contexts allow for creating sub-suites within a suite package and they allow for grouping of tests that are somehow related.

In essence, context behaves like a suite within a suite. 

Context have following characteristics:

- context starts with the `--%context` annotation and ends with `--%endcontext`. Everything placed between those two annotations belongs to that context
- can have a description provided as parameter for example `--%context(Some interesting stuff)`. 
- can have a name provided with `--%name` annotation. This is different than with `suite` and `test` annotations, where name is taken from `package/procedure` name.
- contexts can be nested, you can place a context inside another context
- when no name is provided for context, the context is named `context_N` where `N` is the number of the context in suite or parent context.
- context name must be unique within it's parent (suite / parent context)
- if context name is not unique within it's parent, context and it's entire content is excluded from execution 
- context name should not contain spaces or special characters
- context name cannot contain a `.` (full stop/period) character
- suite/context can have multiple nested sibling contexts in it 
- contexts can have their own `--%beforeall`, `--%beforeeach`, `--%afterall` and `--%aftereach` procedures
- `--%beforeall`, `--%beforeeach`, `--%afterall` and `--%aftereach` procedures defined at ancestor level, propagate to context
- if `--%endcontext` is missing for a context, the context spans to the end of package specification

The below example illustrates usage of `--%context` for separating tests for individual procedures of package.

Sample tables and code
```sql linenums="1"
create table rooms (
  room_key number primary key,
  name varchar2(100) not null
);

create table room_contents (
  contents_key number primary key,
  room_key     number not null,
  name         varchar2(100) not null,
  create_date  timestamp default current_timestamp not null,
  constraint fk_rooms foreign key (room_key) references rooms (room_key)
);

create or replace package rooms_management is

  procedure remove_rooms_by_name( a_name rooms.name%type );

  procedure add_rooms_content( 
    a_room_name    rooms.name%type,
    a_content_name room_contents.name%type
  );

end;
/

create or replace package body rooms_management is
  procedure remove_rooms_by_name( a_name rooms.name%type ) is
  begin
    if a_name is null then
      raise program_error;
    end if;
    delete from rooms where name like a_name;
  end;
  
  procedure add_rooms_content( 
    a_room_name    rooms.name%type,
    a_content_name room_contents.name%type
  ) is
    l_room_key     rooms.room_key%type;
  begin
   
    select room_key into l_room_key 
      from rooms where name = a_room_name;
    
    insert into room_contents
          (contents_key, room_key, name)
    select nvl(max(contents_key)+1, 1) as contents_key,
           l_room_key,
           a_content_name
      from room_contents;
  end;
end;
/
```

Below test suite defines:

- `--%beforeall` outside of context, that will be executed before all tests
- `--%context(remove_rooms_by_name)` to group tests related to `remove_rooms_by_name` functionality
- `--%context(add_rooms_content)` to group tests related to `add_rooms_content` functionality

```sql linenums="1"
create or replace package test_rooms_management is

  gc_null_value_exception constant integer := -1400;
  --%suite(Rooms management)
  
  --%beforeall
  procedure setup_rooms;

  
  --%context(remove_rooms_by_name)
  --%displayname(Remove rooms by name)
  
    --%test(Removes a room without content in it)
    procedure remove_empty_room;

    --%test(Raises exception when null room name given)
    --%throws(-6501)
    procedure null_room_name;  

  --%endcontext
  
  --%context(add_rooms_content)
  --%displayname(Add content to a room)

    --%test(Fails when room name is not valid)
    --%throws(no_data_found)
    procedure fails_on_room_name_invalid;

    --%test(Fails when content name is null)
    --%throws(test_rooms_management.gc_null_value_exception)
    procedure fails_on_content_null;

    --%test(Adds a content to existing room)
    procedure add_content_success;

  --%endcontext

end;
/

create or replace package body test_rooms_management is

  procedure setup_rooms is
  begin
    insert all
      into rooms values(1, 'Dining Room')
      into rooms values(2, 'Living Room')
      into rooms values(3, 'Bathroom')
    select 1 from dual;

    insert all
      into room_contents values(1, 1, 'Table', sysdate)
      into room_contents values(3, 1, 'Chair', sysdate)
      into room_contents values(4, 2, 'Sofa', sysdate)
      into room_contents values(5, 2, 'Lamp', sysdate)
    select 1 from dual;

    dbms_output.put_line('---SETUP_ROOMS invoked ---');
  end;

  procedure remove_empty_room is
    l_rooms_not_named_b sys_refcursor;
    l_remaining_rooms   sys_refcursor;
  begin
    open l_rooms_not_named_b for select * from rooms where name not like 'B%';

    rooms_management.remove_rooms_by_name('B%');

    open l_remaining_rooms for select * from rooms;
    ut.expect( l_remaining_rooms ).to_equal(l_rooms_not_named_b);
  end;

  procedure room_with_content is
  begin
    rooms_management.remove_rooms_by_name('Living Room');
  end;

  procedure null_room_name is
  begin
    --Act
    rooms_management.remove_rooms_by_name(NULL);
    --Assert done by --%throws annotation
  end;

  procedure fails_on_room_name_invalid is
  begin
    --Act
    rooms_management.add_rooms_content('bad room name','Chair');
    --Assert done by --%throws annotation
  end;

  procedure fails_on_content_null is
  begin
    --Act
    rooms_management.add_rooms_content('Dining Room',null);
    --Assert done by --%throws annotation
  end;

  procedure add_content_success is
    l_expected        room_contents.name%type;
    l_actual          room_contents.name%type;
  begin
    --Arrange
    l_expected := 'Table';

    --Act
    rooms_management.add_rooms_content( 'Dining Room', l_expected );
    --Assert
    select name into l_actual from room_contents
     where contents_key = (select max(contents_key) from room_contents);

    ut.expect( l_actual ).to_equal( l_expected );
  end;

end;
/
```

When the tests are executed
```sql linenums="1"
exec ut.run('test_rooms_management');
```
The following report is displayed
```
Rooms management
  ---SETUP_ROOMS invoked ---
  remove_rooms_by_name
    Removes a room without content in it [.015 sec]
    Raises exception when null room name given [.002 sec]
  add_rooms_content
    Fails when room name is not valid [.003 sec]
    Fails when content name is null [.003 sec]
    Adds a content to existing room [.003 sec]
 
Finished in .035261 seconds
5 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```

Example of nested contexts test suite specification.
*Source - [slide 145](https://www.slideshare.net/Kevlin/structure-and-interpretation-of-test-cases/145?src=clipshare) of Structure and Interpretation of Test Cases by Kevlin Henney*

```sql linenums="1"
create or replace package queue_spec as
  --%suite(Queue specification)

  --%context(A new queue)

    --%test(Is empty)
    procedure is_empty;
    --%test(Preserves positive bounding capacity)
    procedure positive_bounding_capacity;
    --%test(Cannot be created with non positive bounding capacity)
    procedure non_positive_bounding_cap;
  --%endcontext
  --%context(An empty queue)

    --%test(Dequeues an empty value)
    procedure deq_empty_value;
    --%test(Remains empty when null enqueued)
    procedure empty_with_null_enq;
    --%test(Becomes non empty when non null value enqueued)
    procedure non_empty_after_enq;
  --%endcontext
  --%context(A non empty queue)

    --%context(that is not full)

      --%test(Becomes longer when non null value enqueued)
      procedure grow_on_enq_non_null;
      --%test(Becomes full when enqueued up to capacity)
      procedure full_on_enq_to_cap;
    --%endcontext
    --%context(that is full)

      --%test(Ignores further enqueued values)
      procedure full_ignore_enq;
      --%test(Becomes non full when dequeued)
      procedure non_full_on_deq;
    --%endcontext

    --%test(Dequeues values in order enqueued)
    procedure dequeue_ordered;
    --%test(Remains unchanged when null enqueued)
    procedure no_change_on_null_enq;
  --%endcontext
end;
```


When such specification gets executed `ut.run('queue_spec'')` (without body created) you will see the nesting of tests within contexts.
```
Queue specification
  An empty queue
    Dequeues an empty value [.014 sec] (FAILED - 1)
    Remains empty when null enqueued [.004 sec] (FAILED - 2)
    Becomes non empty when non null value enqueued [.005 sec] (FAILED - 3)
  A non empty queue
    that is not full
      Becomes longer when non null value enqueued [.005 sec] (FAILED - 4)
      Becomes full when enqueued up to capacity [.005 sec] (FAILED - 5)
    That is full
      Ignores further enqueued values [.004 sec] (FAILED - 6)
      Becomes non full when dequeued [.005 sec] (FAILED - 7)
    Dequeues values in order enqueued [.006 sec] (FAILED - 8)
    Remains unchanged when null enqueued [.004 sec] (FAILED - 9)
  A new queue
    Is empty [.007 sec] (FAILED - 10)
    Preserves positive bounding capacity [.006 sec] (FAILED - 11)
    Cannot be created with non positive bounding capacity [.005 sec] (FAILED - 12)
Failures:
   1) deq_empty_value
      ORA-04067: not executed, package body "UT3.QUEUE_SPEC" does not exist
      ORA-06508: PL/SQL: could not find program unit being called: "UT3.QUEUE_SPEC"
      ORA-06512: at line 6
...
Finished in .088573 seconds
12 tests, 0 failed, 12 errored, 0 disabled, 0 warning(s)
``` 

Suite nesting allows for organizing tests into human-readable specification of behavior.

### Name
The `--%name` annotation is currently only used only for naming a context.
If a context doesn't have explicit name specified, then the name is given automatically by framework.

The automatic name will be `context_#n` where `n` is a context number within a suite/parent context.

The `--%name` can be useful when you would like to run only a specific context or its items by `suitepath`.

Consider the below example.

```sql linenums="1"
create or replace package queue_spec as
  --%suite(Queue specification)

  --%context(A new queue)

    --%test(Cannot be created with non positive bounding capacity)
    procedure non_positive_bounding_cap;
  --%endcontext
  --%context(An empty queue)

    --%test(Becomes non empty when non null value enqueued)
    procedure non_empty_after_enq;
  --%endcontext
  --%context(A non empty queue)

    --%context(that is not full)

      --%test(Becomes full when enqueued up to capacity)
      procedure full_on_enq_to_cap;
    --%endcontext
    --%context(that is full)

      --%test(Becomes non full when dequeued)
      procedure non_full_on_deq;
    --%endcontext

  --%endcontext
end;
```

In the above code, suitepaths, context names and context descriptions will be as follows.

| suitepath                        | description          | name       |
|----------------------------------|----------------------|------------|
| queue_spec                       | Queue specification  | queue_spec |
| queue_spec.context_#1            | A new queue          | context_#1 |
| queue_spec.context_#2            | An empty queue       | context_#2 |
| queue_spec.context_#3            | A non empty queue    | context_#3 |
| queue_spec.context_#3.context_#1 | that is not full     | context_#1 |
| queue_spec.context_#3.context_#2 | that is full         | context_#2 |

In order to run only the tests for the context `A non empty queue that is not full` you will need to call utPLSQL as below:
```sql linenums="1" 
  exec ut.run(':queue_spec.context_#3.context_#1');
```

You can use `--%name` annotation to explicitly name contexts on suitepath.  
```sql linenums="1"
create or replace package queue_spec as
  --%suite(Queue specification)

  --%context(A new queue)
  --%name(a_new_queue)

    --%test(Cannot be created with non positive bounding capacity)
    procedure non_positive_bounding_cap;
  --%endcontext
  --%context(An empty queue)
  --%name(an_empty_queue)

    --%test(Becomes non empty when non null value enqueued)
    procedure non_empty_after_enq;
  --%endcontext
  --%context(A non empty queue)
  --%name(a_non_empty_queue)

    --%context(that is not full)
    --%name(that_is_not_full)

      --%test(Becomes full when enqueued up to capacity)
      procedure full_on_enq_to_cap;
    --%endcontext
    --%context(that is full)
    --%name(that_is_full)

      --%test(Becomes non full when dequeued)
      procedure non_full_on_deq;
    --%endcontext

  --%endcontext
end;
```

In the above code, suitepaths, context names and context descriptions will be as follows.

| suitepath                                     | description           | name              |
|-----------------------------------------------|-----------------------|-------------------|
| queue_spec                                    | Queue specification   | queue_spec        |
| queue_spec.a_new_queue                        | A new queue           | a_new_queue       |
| queue_spec.an_empty_queue                     | An empty queue        | an_empty_queue    |
| queue_spec.a_non_empty_queue                  | A non empty queue     | a_non_empty_queue |
| queue_spec.a_non_empty_queue.that_is_not_full | that is not full      | that_is_not_full  |
| queue_spec.a_non_empty_queue.that_is_full     | that is full          | that_is_full      |


The `--%name` annotation is only relevant for:

- running subsets of tests by given context suitepath
- some of test reports, like `ut_junit_reporter` that use suitepath or test-suite element names (not descriptions) for reporting   

#### Name naming convention

The value of `--%name` annotation must follow the following naming rules:

- cannot contain spaces
- cannot contain a `.` (full stop/dot)
- is case-insensitive  

### Tags

Tag is a label attached to the test or a suite. It is used for identification and execution of a group of tests / suites that share the same tag.  

It allows for grouping of tests / suites using various categorization and place tests / suites in multiple buckets. Same tests can be grouped with other tests based on the functionality , frequency, type of output etc.

e.g. 

```sql linenums="1"
--%tags(batch,daily,csv)
```

or

```sql linenums="1"
--%tags(online,json)
--%tags(api)
```

Tags are defined as a comma separated list within the `--%tags` annotation. 

When executing a test run with tag filter applied, the framework will find all tests associated with the given tags and execute them. 
The framework applies `OR` logic to all specified tags so any test / suite that matches at least one tag will be included in the test run. 

When a suite/context is tagged, all of its children will automatically inherit the tag and get executed along with the parent. Parent suite tests are not executed, but a suitepath hierarchy is kept.


Sample test suite package with tags.
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

Execution of the test is done by using the parameter `a_tags`

```sql linenums="1"
select * from table(ut.run(a_path => 'ut_sample_test',a_tags => 'api'));
```
The above call will execute all tests from `ut_sample_test` package as the whole suite is tagged with `api`

```sql linenums="1"
select * from table(ut.run(a_tags => 'complex'));
```
The above call will execute only the `ut_sample_test.ut_refcursors1` test, as only the test `ut_refcursors1` is tagged with `complex`

```sql linenums="1"
select * from table(ut.run(a_tags => 'fast'));
```
The above call will execute both `ut_sample_test.ut_refcursors1` and `ut_sample_test.ut_test` tests, as both tests are tagged with `fast`

#### Tag naming convention

Tags must follow the below naming convention:

- tag is case sensitive
- tag can contain special characters like `$#/\?-!` etc.
- tag cannot be an empty string
- tag cannot start with a dash, e.g. `-some-stuff` is **not** a valid tag
- tag cannot contain spaces, e.g. `test of batch`. To create a multi-word tag use underscores or dashes, e.g. `test_of_batch`, `test-of-batch`
- leading and trailing spaces are ignored in tag name, e.g. `--%tags(  tag1  ,   tag2  )` becomes `tag1` and `tag2` tag names


#### Excluding tests/suites by tags

It is possible to exclude parts of test suites with tags.
In order to do so, prefix the tag name to exclude with a `-` (dash) sign when invoking the test run.

Examples (based on above sample test suite)

```sql linenums="1"
select * from table(ut.run(a_tags => 'api,fast,-complex'));
```
The above call will execute all suites/contexts/tests that are marked with any of tags `api` or `fast` except those suites/contexts/tests that are marked as `complex`.  
Given the above example package `ut_sample_test`, only `ut_sample_test.ut_test` will be executed.  



### Suitepath

It is very likely that the application for which you are going to introduce tests consists of many different packages, procedures and functions.
Usually procedures can be logically grouped inside a package, there also might be several logical groups of procedures in a single package and packages might be grouped into modules and modules into subject areas.

As your project grows, the codebase will grow to. utPLSQL allows you to group packages into modules and also allows for nesting modules. 

Let's say you have a complex insurance application that deals with policies, claims and payments. The payment module contains several packages for payment recognition, charging, planning etc. The payment recognition module among others contains a complex `recognize_payment` procedure that associates received money to the policies.

If you want to create tests for your application it is recommended to structure your tests similarly to the logical structure of your application. So you end up with something like:
* Integration tests
  *   Policy tests
  *   Claim tests
  *   Payment tests
    * Payments recognition
    * Payments set off

The `--%suitepath` annotation is used for such grouping. Even though test packages are defined in a flat structure the `--%suitepath` is used by the framework to form them into a hierarchical structure. 

Your payments recognition test package might look like:
```sql linenums="1"
create or replace package test_payment_recognition as

  --%suite(Payment recognition tests)
  --%suitepath(payments)

  --%test(Recognize payment by policy number)
  procedure test_recognize_by_num;

  --%test(Recognize payment by payment purpose)
  procedure test_recognize_by_purpose;

  --%test(Recognize payment by customer)
  procedure test_recognize_by_customer;

end test_payment_recognition;
```

And payments set off test package:
```sql linenums="1"
create or replace package test_payment_set_off as

  --%suite(Payment set off tests)
  --%suitepath(payments)

  --%test(Creates set off)
  procedure test_create_set_off;

  --%test(Cancels set off)
  procedure test_cancel_set_off;

end test_payment_set_off;
```

When you execute tests for your application, the framework constructs a test suite for each test package. Then it combines suites into grouping suites by the `--%suitepath` annotation value so that the fully qualified path to the `recognize_by_num` procedure is `USER:payments.test_payment_recognition.test_recognize_by_num`. If any of its expectations fails then the test is marked as failed, also the `test_payment_recognition` suite, the parent suite `payments` and the whole run is marked as failed.
The test report indicates which expectation has failed on the payments module. The payments recognition submodule is causing the failure as `recognize_by_num` has not met the expectations of the test. Grouping tests into modules and submodules using the `--%suitepath` annotation allows you to logically organize your project's flat structure of packages into functional groups.

An additional advantage of such grouping is the fact that every element level of the grouping can be an actual unit test package containing a common module level setup for all of the submodules. So in addition to the packages mentioned above you could have the following package.
```sql linenums="1"
create or replace package payments as

  --%suite(Payments)

  --%beforeall
  procedure set_common_payments_data;

  --%afterall
  procedure reset_common_paymnets_data;

end payments;
```

When executing tests, `path` for executing tests can be provided in three ways:

* schema - execute all tests in the schema
* [schema]:suite1[.suite2][.suite3]...[.procedure] - execute all tests by `suitepath` in all suites on path suite1[.suite2][.suite3]...[.procedure]. If schema is not provided, then the current schema is used. Example: `:all.rooms_tests`
* [schema.]package[.procedure] - execute all tests in the specified test package. The whole hierarchy of suites in the schema is built before all before/after hooks or part suites for the provided suite package are executed as well. Example: `tests.test_contact.test_last_name_validator` or simply `test_contact.test_last_name_validator` if `tests` is the current schema.


### Rollback

By default, changes performed by every setup, cleanup and test procedure are isolated by savepoints.
This solution is suitable for use-cases where the code that is being tested as well as the unit tests themselves do not use transaction control (commit/rollback) or DDL commands.

In general, your unit tests should not use transaction control as long as the code you are testing is not using it too.
Keeping the transactions uncommitted allows your changes to be isolated and the execution of tests does not impact others who might be using a shared development database.

If you are in a situation where the code you are testing uses transaction control (common case with ETL code), then your tests probably should not use the default automatic transaction control.
In that case use the annotation `--%rollback(manual)` on the suite level to disable automatic transaction control for the entire suite.
If you are using nested suites, you need to make sure that the entire suite all the way to the root is using manual transaction control.

It is possible with utPLSQL to change the transaction control on individual suites or tests that are part of complex suite.
It is strongly recommended not to have mixed transaction control in a suite.
Mixed transaction control settings will not work properly when your suites are using shared setup/cleanup with beforeall, afterall, beforeeach or aftereach annotations.
Your suite will most likely fail with error or warning on execution. Some of the automatic rollbacks will probably fail to execute depending on the configuration you have.

In some cases it is necessary to perform DDL as part of setup or cleanup for the tests.
It is recommended to move such DDL statements to a procedure with `pragma autonomous_transaction` to eliminate implicit commits in the main session that is executing all your tests.
Doing so allows your tests to use the framework's automatic transaction control and releases you from the burden of manual cleanup of data that was created or modified by test execution.

When you are testing code that performs explicit or implicit commits, you may set the test procedure to run as an autonomous transaction with `pragma autonomous_transaction`.
Keep in mind that when your test runs as autonomous transaction it will not see the data prepared in a setup procedure unless the setup procedure committed the changes.

**Note**
> The `--%suitepath` annotation, when used, must be provided with a value of path.
> The path in suitepath cannot contain spaces. Dot (.) identifies individual elements of the path.
>
> Example: `--%suitepath(org.utplsql.core.utils)`
>


### Throws

The `--%throws` annotation allows you to specify a list of exceptions as one of:

- number literals - example `--%throws(-20134)`
- variables of type exception defined in a package specification - example `--%throws(exc_pkg.c_exception_No_variable)`
- variables of type number defined in a package specification - example `--%throws(exc_pkg.c_some_exception)`
- [predefined oracle exceptions](https://docs.oracle.com/cd/E11882_01/timesten.112/e21639/exceptions.htm#CIHFIGFE) - example `--%throws(no_data_found)`

The annotation is ignored, when no valid arguments are provided. Examples of invalid annotations `--%throws()`,`--%throws`, `--%throws(abe, 723pf)`.

If `--%throws` annotation is specified with arguments and no exception is raised, the test is marked as failed.

If `--%throws` annotation is specified with arguments and exception raised is not on the list of provided exceptions, the test is marked as failed.

The framework will raise a warning, when `--%throws` annotation has invalid arguments or when no arguments were provided.

Annotation `--%throws(7894562, operaqk, -=1, -20496, pow74d, posdfk3)` will be interpreted as `--%throws(-20496)`.

Please note that `NO_DATA_FOUND` exception is a special case in Oracle. To capture it use `NO_DATA_FOUND` named exception or `-1403` exception No.
                                                                                                        
Example:
```sql linenums="1"
create or replace package exc_pkg is
  c_e_option1  constant number := -20200;
  c_e_option2  constant varchar2(10) := '-20201';
  c_e_option3  number := -20202;
          
  e_option4 exception;
  pragma exception_init(e_option4, -20203);
          
end;
/

create or replace package example_pgk as

  --%suite(Example Throws Annotation)

  --%test(Throws one of the listed exceptions)
  --%throws(-20145,bad,-20146, -20189 ,-20563)
  procedure raised_one_listed_exception;

  --%test(Throws different exception than expected)
  --%throws(-20144)
  procedure raised_different_exception;

  --%test(Throws different exception than listed)
  --%throws(-20144,-00001,-20145)
  procedure raised_unlisted_exception;

  --%test(Gives failure when an exception is expected and nothing is thrown)
  --%throws(-20459, -20136, -20145)
  procedure nothing_thrown;
  
  --%test(Throws package exception option1)
  --%throws(exc_pkg.c_e_option1)
  procedure raised_option1_exception;
  
  --%test(Throws package exception option2)
  --%throws(exc_pkg.c_e_option2)
  procedure raised_option2_exception;
  
  --%test(Throws package exception option3)
  --%throws(exc_pkg.c_e_option3)
  procedure raised_option3_exception;
  
  --%test(Throws package exception option4)
  --%throws(exc_pkg.e_option4)
  procedure raised_option4_exception;
  
  --%test(Raise name exception)
  --%throws(DUP_VAL_ON_INDEX)
  procedure raise_named_exc;

  --%test(Invalid throws annotation)
  --%throws
  procedure bad_throws_annotation;

end;  
/
create or replace package body example_pgk is
  procedure raised_one_listed_exception is
  begin
      raise_application_error(-20189, 'Test error');
  end;

  procedure raised_different_exception is
  begin
      raise_application_error(-20143, 'Test error');
  end;

  procedure raised_unlisted_exception is
  begin
      raise_application_error(-20143, 'Test error');
  end;

  procedure nothing_thrown is
  begin
      ut.expect(1).to_equal(1);
  end;
  
  procedure raised_option1_exception is
  begin
      raise_application_error(exc_pkg.c_e_option1, 'Test error');
  end;
  
  procedure raised_option2_exception is
  begin
      raise_application_error(exc_pkg.c_e_option2, 'Test error');
  end;
  
  procedure raised_option3_exception is
  begin
      raise_application_error(exc_pkg.c_e_option3, 'Test error');
  end;
  
  procedure raised_option4_exception is
  begin
      raise exc_pkg.e_option4;
  end;
  
  procedure raise_named_exc is
  begin
      raise DUP_VAL_ON_INDEX;
  end;
  
  procedure bad_throws_annotation is
  begin
    null;
  end;
end;
/

exec ut3.ut.run('example_pgk');
```

Running the test will give report:
```
Example Throws Annotation
  Throws one of the listed exceptions [.002 sec]
  Throws different exception than expected [.002 sec] (FAILED - 1)
  Throws different exception than listed [.003 sec] (FAILED - 2)
  Gives failure when an exception is expected and nothing is thrown [.002 sec] (FAILED - 3)
  Throws package exception option1 [.003 sec]
  Throws package exception option2 [.002 sec]
  Throws package exception option3 [.002 sec]
  Throws package exception option4 [.002 sec]
  Raise name exception [.002 sec]
  Invalid throws annotation [.002 sec]
 
Failures:
 
  1) raised_different_exception
      Actual: -20143 was expected to equal: -20144
      ORA-20143: Test error
      ORA-06512: at "UT3.EXAMPLE_PGK", line 9
      ORA-06512: at "UT3.EXAMPLE_PGK", line 9
      ORA-06512: at line 6
       
  2) raised_unlisted_exception
      Actual: -20143 was expected to be one of: (-20144, -1, -20145)
      ORA-20143: Test error
      ORA-06512: at "UT3.EXAMPLE_PGK", line 14
      ORA-06512: at "UT3.EXAMPLE_PGK", line 14
      ORA-06512: at line 6
       
  3) nothing_thrown
      Expected one of exceptions (-20459, -20136, -20145) but nothing was raised.
       
 
Warnings:
 
  1) example_pgk
      Invalid parameter value "bad" for "--%throws" annotation. Parameter ignored.
      at "UT3.EXAMPLE_PGK.RAISED_ONE_LISTED_EXCEPTION", line 6
  2) example_pgk
      "--%throws" annotation requires a parameter. Annotation ignored.
      at "UT3.EXAMPLE_PGK.BAD_THROWS_ANNOTATION", line 42
 
Finished in .025784 seconds
10 tests, 3 failed, 0 errored, 0 disabled, 2 warning(s)
```

## Order of execution

```sql linenums="1"
create or replace package test_employee_pkg is

  --%suite(Employee management)
  --%suitepath(com.my_company.hr)
  --%rollback(auto)

  --%beforeall
  procedure setup_employees;

  --%beforeall
  procedure setup_departments;

  --%afterall
  procedure cleanup_log_table;

  --%context(add_employee)

  --%beforeeach
  procedure setup_for_add_employees;

  --%test(Raises exception when employee already exists)
  --%throws(-20145)
  procedure add_existing_employee;

  --%test(Inserts employee to emp table)
  procedure add_employee;  

  --%endcontext


  --%context(remove_employee)
  
  --%beforeall
  procedure setup_for_remove_employee;
  
  --%test(Removed employee from emp table)
  procedure del_employee;
  
  --%endcontext

  --%test(Test without context)
  --%beforetest(setup_another_test)
  --%aftertest(cleanup_another_test)
  procedure some_test;

  --%test(Name of test)
  --%disabled
  procedure disabled_test;

  --%test(Name of test)
  --%rollback(manual)
  procedure no_transaction_control_test;

  procedure setup_another_test;

  procedure cleanup_another_test;

  --%beforeeach
  procedure set_session_context;

  --%aftereach
  procedure cleanup_session_context;

end test_employee_pkg;
```

When processing the test suite `test_employee_pkg` defined in [Example of annotated test package](#example), the order of execution will be as follows.

```
  create a savepoint 'before-suite'         
    execute setup_employees                 (--%beforeall)
    execute setup_departments               (--%beforeall)

    create a savepoint 'before-context'     
      create savepoint 'before-test'
          execute test_setup                (--%beforeeach)
          execute setup_for_add_employees   (--%beforeeach from context)
          execute add_existing_employee     (--%test)
          execute test_cleanup              (--%aftereach)
      rollback to savepoint 'before-test'
      create savepoint 'before-test'        (--%suite)
          execute test_setup                (--%beforeeach)
          execute setup_for_add_employees   (--%beforeeach from context)
          execute add_employee              (--%test)
          execute test_cleanup              (--%aftereach)
      rollback to savepoint 'before-test'      
    rollback to savepoint 'before-context'  

    create a savepoint 'before-context'
      execute setup_for_remove_employee     (--%beforeall from context)     
      create savepoint 'before-test'
          execute test_setup                (--%beforeeach)
          execute add_existing_employee     (--%test)
          execute test_cleanup              (--%aftereach)
      rollback to savepoint 'before-test'
    rollback to savepoint 'before-context'  

    create savepoint 'before-test'
      execute test_setup                    (--%beforeeach)
      execute some_test                     (--%test)
      execute test_cleanup                  (--%aftereach)
    rollback to savepoint 'before-test'     
                                            
    create savepoint 'before-test'          
      execute test_setup                    (--%beforeeach)
      execute setup_another_test            (--%beforetest)
      execute another_test                  (--%test)
      execute cleanup_another_test          (--%aftertest)
      execute test_cleanup                  (--%beforeeach)
    rollback to savepoint 'before-test'

    mark disabled_test as disabled          (--%test --%disabled)

    execute test_setup                      (--%beforeeach)
    execute no_transaction_control_test     (--%test)
    execute test_cleanup                    (--%aftertest)

    execute global_cleanup                  (--%afterall)
  rollback to savepoint 'before-suite'
```

!!! note
    utPLSQL does not guarantee ordering of tests in suite. On contrary utPLSQL might give random order of tests/contexts in suite.<br>
    Order of execution within multiple occurrences of `before`/`after` procedures is determined by the order of annotations in specific block (context/suite) of package specification.

## sys_context

It is possible to access information about currently running suite.
The information is available by calling `sys_context( 'UT3_INFO', attribute )`.
It can be accessed from any procedure invoked as part of utPLSQL test execution.

!!! note 
    Context name is derived from schema name where utPLSQL is installed.<br>
    The context name in below examples represents the default install schema -> `UT3`<br>
    If you install utPLSQL into another schema the context name will be different.<br>
    For example if utPLSQL is installed into `HR` schema, the context name will be `HR_INFO`

Following attributes are populated:

| Name                    | Scope         | Description                                                                                                                                         |
|-------------------------|---------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| COVERAGE_RUN_ID         | run           | Value of COVERAGE_RUN_ID used by utPLSQL internally for coverage gathering                                                                          | 
| RUN_PATHS               | run           | list of suitepaths / suitenames used as input parameters for call to `ut.run(...)` or `ut_runner.run(...)`                                          |
| SUITE_DESCRIPTION       | run           | the description of test suite that is currently being executed                                                                                      |
| SUITE_PACKAGE           | run           | the owner and name of test suite package that is currently being executed                                                                           |
| SUITE_PATH              | run           | the suitepath for the test suite package that is currently being executed                                                                           |
| SUITE_START_TIME        | run           | the execution start timestamp of test suite package that is currently being executed                                                                |
| CURRENT_EXECUTABLE_NAME | run           | the owner.package.procedure of currently running test suite executable                                                                              |
| CURRENT_EXECUTABLE_TYPE | run           | the type of currently running test suite executable (one of: `beforeall`, `beforeeach`, `beforetest`, `test`, `aftertest`, `aftereach`, `afterall`  |
 | CONTEXT_DESCRIPTION     | suite context | the description of test suite context that is currently being executed                                                                              |  
 | CONTEXT_NAME            | suite context | the name of test suite context that is currently being executed                                                                                     |  
 | CONTEXT_PATH            | suite context | the suitepath for the currently executed test suite context                                                                                         |  
 | CONTEXT_START_TIME      | suite context | the execution start timestamp for the currently executed test suite context                                                                         |  
| TEST_DESCRIPTION        | test*         | the description of test for which the current executable is being invoked                                                                           |
| TEST_NAME               | test*         | the name of test for which the current executable is being invoked                                                                                  |
| TEST_START_TIME         | test*         | the execution start timestamp of test that is currently being executed (the time when first `beforeeach`/`beforetest` was called for that test)     |

!!! note "Scopes"
    - run - context information is available in any element of test run<br>
    - suite context - context information is available in any element nested within a suite context<br> 
    - test* - context information is available when executing following procedure types: test, beforetest, aftertest, beforeeach or aftereach 

 
Example:
```sql linenums="1"
create or replace procedure which_procecure_called_me is
begin
  dbms_output.put_line(
    'Currently running utPLSQL ' ||sys_context( 'ut3_info', 'current_executable_type' )
    ||' ' ||sys_context( 'ut3_info', 'current_executable_name' )
  );
end;
/

create or replace package test_call is

  --%suite

  --%beforeall
  procedure beforeall;
  
  --%beforeeach
  procedure beforeeach;
  
  --%test
  procedure test1;

  --%test
  procedure test2;
  
end;
/

create or replace package body test_call is

  procedure beforeall is
  begin
    which_procecure_called_me();
    dbms_output.put_line('Current test procedure is: '||sys_context('ut3_info','test_name'));
  end;

  procedure beforeeach is
  begin
    which_procecure_called_me();
    dbms_output.put_line('Current test procedure is: '||sys_context('ut3_info','test_name'));
  end;
  
  procedure test1 is
  begin
    which_procecure_called_me();
    ut.expect(sys_context('ut3_info','suite_package')).to_equal(user||'.test_call');
  end;

  procedure test2 is
  begin
    which_procecure_called_me();
    ut.expect(sys_context('ut3_info','test_name')).to_equal(user||'.test_call.test2');
  end;
  
end;
/
```

```sql linenums="1"
exec ut.run('test_call');
```

```
test_call
  Currently running utPLSQL beforeall UT3.test_call.beforeall
  Current test procedure is: 
  test1 [.008 sec]
  Currently running utPLSQL beforeeach UT3.test_call.beforeeach
  Current test procedure is: UT3.test_call.test1
  Currently running utPLSQL test UT3.test_call.test1
  test2 [.004 sec]
  Currently running utPLSQL beforeeach UT3.test_call.beforeeach
  Current test procedure is: UT3.test_call.test2
  Currently running utPLSQL test UT3.test_call.test2
 
Finished in .021295 seconds
2 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```


## Annotation cache

utPLSQL needs to scan the source of package specifications to identify and parse annotations.
To improve framework startup time, especially when dealing with database users owning large amounts of packages, the framework has a built-in persistent cache for annotations.

The annotation cache is checked for staleness and refreshed automatically on every run. The initial startup of utPLSQL for a schema will take longer than consecutive executions.

If you are in a situation where your database is controlled via CI/CD server and is refreshed/wiped before each run of your tests, consider building the annotation cache upfront and taking a snapshot of the database after the cache has been refreshed.

To build the annotation cache without actually invoking any tests, call `ut_runner.rebuild_annotation_cache(a_object_owner)` for every unit test owner for which you want to have the annotation cache prebuilt.
Example:
```sql linenums="1"
exec ut_runner.rebuild_annotation_cache('HR');
```

To purge the annotation cache call `ut_runner.purge_cache(a_object_owner, a_object_type)`.
Both parameters are optional and if not provided, all owners/object_types will be purged. 
Example:
```sql linenums="1"
exec ut_runner.purge_cache('HR', 'PACKAGE');
```

