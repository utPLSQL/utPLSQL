# Annotations

Annotations provide a way to configure tests and suites in a declarative way similar to modern OOP languages.
The annotation list is based on jUnit 5 implementation.

# Example
Let's say we have the test package like this:
```
create or replace package test_pkg is

  -- %suite
  -- %displayname(Name of suite)
  -- %suitepath(all.globaltests)

  -- %beforeall
  procedure globalsetup;

  -- %afterall
  procedure global_teardown;

  /* Such comments are allowed */

  -- %test
  -- %displayname(Name of test1)
  procedure test1;

  -- %test
  -- %displayname(Name of test2)
  -- %beforetest(setup_test1)
  -- %aftertest(teardown_test1)
  procedure test2;

  -- %test
  -- %displayname(Name of test3)
  -- %testtype(smoke)
  procedure test3;

  procedure setup_test1;

  procedure teardown_test1;

  -- %beforeeach
  procedure setup;

  -- %aftereach
  procedure teardown;

end test_pkg;
```

#Annotations meaning

| Annotation |Level| Describtion |
| --- | --- | --- |
| `%suite` | Package | Marks package to be a suite of tests This way all testing packages might be found in a schema. |
| `%suitepath(<path>)` | Package | Similar to java package. The annotation allows logical grouping of suites into hierarcies. |
| `%displayname(<description>)` | Package/procedure | Human-familiar describtion of the suite/test. `%displayname(Name of the suite/test)` |
| `%test` | Procedure | Denotes that a method is a test method. |
| `%beforeall` | Procedure | Denotes that the annotated procedure should be executed before all `%test` methods in the current suite. |
| `%afterall` | Procedure | Denotes that the annotated procedure should be executed after all `%test` methods in the current suite. |
| `%beforeeach` | Procedure | Denotes that the annotated procedure should be executed before each `%test` method in the current suite. |
| `%aftereach` | Procedure | Denotes that the annotated procedure should be executed after each `%test` method in the current suite. |
| `%beforetest(<procedure_name>)` | Procedure | Denotes that mentioned procedure should be executed before the annotated `%test` procedure. |
| `%aftertest(<procedure_name>)` | Procedure | Denotes that mentioned procedure should be executed after the annotated `%test` procedure. |
| `%rollback(<type>)` | Package/procedure | Configure transaction control behaviour (type). Supported values: `auto`(default) - rollback to savepoint (before the test/suite setup) is issued after each test/suite teardown; `manual` - rollback is never issued automatically. Property can be overridden for child element (test in suite) |
| `%disable` | Package/procedure | Used to disable a suite or a test |

Annotations allow us to configure test infrastructure in a declarative way without anything stored in tables or config files. Suite manager would scan the schema for all the suitable packages, automatically configure suites and execute them. This can be simplified to the situation when you just ran suite manager over a schema for the defined types of tests and reporters and everything goes automatically. This is going to be convenient to be executed from CI tools using standard reporting formats.
