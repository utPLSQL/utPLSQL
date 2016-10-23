# Annotations

Annotations provide a way to configure tests and suites in a declarative way similar to modern OOP languages.

# Example
Let's say we have the test package like this:
```
create or replace package test_pkg is

  -- %suite(Name of suite)
  -- %suitepackage(all.globaltests)
  -- %suitetype(critical)

  -- %suitesetup
  procedure globalsetup;

  -- %suiteteardown
  procedure global_teardown;

  /* Such comments are allowed */

  -- %test(Name of test1)
  -- %testtype(smoke)
  procedure test1;

  -- %test(Name of test2)
  -- %testsetup(setup_test1)
  -- %testteardown(teardown_test1)
  procedure test2;

  -- %test(Name of test3)
  -- %testtype(smoke)
  procedure test3;

  procedure setup_test1;

  procedure teardown_test1;

  -- %setup
  procedure setup;

  -- %teardown
  procedure teardown;

end test_pkg;
```

#Annotations meaning

Annotation | Meaning
------------ | -------------
%suite | Marks package to be a suite with it procedures as tests. This way all testing packages might be found in the schema. Parameter of the annotation is the Suite name
%suitepackage | Similar to java package. The example suite should be put as an element of the "globaltests" suite which is an element of the "all" suite. This allows one to execute "glovaltests" suite which would recursively run all the child suites including this one.
%suitetype | The way for suite to have something like a type. One might collect suites based on the subject of tests (a system module for example). There might be critical tests to run every time and more covering but slow tests. This technique allows to configure something like "fast" testing.
%setup | Marks procedure as a default setup procedure for the suite.
%teardown | Marks procedure as a default teardown procedure for the suite.
%test | Marks procedure as a test. Parameter is a name of the test
%testtype | Another way to tag tests to filter afterwards
%testsetup | Marks that special setup procedure has to be run before the test instead of the default one
%testteardown | Marks that special teardown procedure has to be run before the test instead of the default one
%suitesetup | Procedure with executes once at the beginning of the suite and doesn't executes before each test
%suiteteardown | Procedure with executes once after the execution of the last test in the suite.

Annotations allow us to configure test infrastructure in a declarative way without anything stored in tables or config files. Suite manager would scan the schema for all the suitable packages, automatically configure suites and execute them. This can be simplified to the situation when you just ran suite manager over a schema for the defined types of tests and reporters and everything goes automatically. This is going to be convenient to be executed from CI tools using standard reporting formats.

