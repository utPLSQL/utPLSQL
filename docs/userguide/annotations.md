# Annotations

Annotations provide a way to configure tests and suites in a declarative way similar to modern OOP languages.
The annotation list is based on moder testing framework such as jUnit 5, RSpec.

Annotations allow to configure test infrastructure in a declarative way without anything stored in tables or config files. The framework runner scans the schema for all the suitable annotated packages, automatically configures suites, forms hierarchy from then and executes them.

Annotations are case-insensitive. But it is recommended to use the lower-case standard as described in the documentation.

Annotation on procedure level must be placed directly before the procedure name.

Annotation `-- %suite` should be placed at the beginning of package specification. It is not required but highly recommended as a practice.

# Example of annotated test package

```sql
create or replace package test_pkg is

  -- %suite(Name of suite)
  -- %suitepath(all.globaltests)

  -- %beforeall
  procedure globalsetup;

  -- %afterall
  procedure global_teardown;

  /* Such comments are allowed */

  -- %test
  -- %displayname(Name of test1)
  procedure test1;

  -- %test(Name of test2)
  -- %beforetest(setup_test1)
  -- %aftertest(teardown_test1)
  procedure test2;

  -- %test
  -- %displayname(Name of test3)
  -- %disabled
  procedure test3;
  
  -- %test(Name of test4)
  -- %rollback(manual)
  procedure test4;

  procedure setup_test1;

  procedure teardown_test1;

  -- %beforeeach
  procedure setup;

  -- %aftereach
  procedure teardown;

end test_pkg;
```

#Annotations description

| Annotation |Level| Description |
| --- | --- | --- |
| `%suite(<description>)` | Package | Marks package to be a suite of tests This way all testing packages might be found in a schema. Optional schema discription can by provided, similar to `%displayname` annotation. |
| `%suitepath(<path>)` | Package | Similar to java package. The annotation allows logical grouping of suites into hierarchies. |
| `%displayname(<description>)` | Package/procedure | Human-familiar description of the suite/test. Syntax is based on jUnit annotation: `%displayname(Name of the suite/test)` |
| `%test(<description>)` | Procedure | Denotes that a method is a test method.  Optional test description can by provided, similar to `%displayname` annotation. |
| `%beforeall` | Procedure | Denotes that the annotated procedure should be executed once before all elements of the current suite. |
| `%afterall` | Procedure | Denotes that the annotated procedure should be executed once after all elements of the current suite. |
| `%beforeeach` | Procedure | Denotes that the annotated procedure should be executed before each `%test` method in the current suite. |
| `%aftereach` | Procedure | Denotes that the annotated procedure should be executed after each `%test` method in the current suite. |
| `%beforetest(<procedure_name>)` | Procedure | Denotes that mentioned procedure should be executed before the annotated `%test` procedure. |
| `%aftertest(<procedure_name>)` | Procedure | Denotes that mentioned procedure should be executed after the annotated `%test` procedure. |
| `%rollback(<type>)` | Package/procedure | Configure transaction control behaviour (type). Supported values: `auto`(default) - rollback to savepoint (before the test/suite setup) is issued after each test/suite teardown; `manual` - rollback is never issued automatically. Property can be overridden for child element (test in suite) |
| `%disabled` | Package/procedure | Used to disable a suite or a test |
