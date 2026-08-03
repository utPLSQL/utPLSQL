![utPLSQL v3 | Testing Framework for PL/SQL](docs/images/utPLSQL-testing-framework-transparent_120.png)

[![latest-release](https://img.shields.io/github/release/utPLSQL/utPLSQL.svg)](https://github.com/utPLSQL/utPLSQL/releases)
[![license](https://img.shields.io/github/license/utPLSQL/utPLSQL.svg)](https://www.apache.org/licenses/LICENSE-2.0)
[![GitHub Discussions](https://img.shields.io/github/discussions/utPLSQL/utPLSQL)](https://github.com/utPLSQL/utPLSQL/discussions)
[![X](https://img.shields.io/twitter/follow/utPLSQL.svg?style=social&label=Follow)](https://twitter.com/utPLSQL)
[![build](https://github.com/utPLSQL/utPLSQL/actions/workflows/build.yml/badge.svg)](https://github.com/utPLSQL/utPLSQL/actions/workflows/build.yml)
[![QualityGate](https://sonarcloud.io/api/project_badges/measure?project=utPLSQL_utPLSQL&metric=sqale_rating)](https://sonarcloud.io/summary/new_code?id=utPLSQL_utPLSQL)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=utPLSQL_utPLSQL&metric=coverage)](https://sonarcloud.io/summary/new_code?id=utPLSQL_utPLSQL)

utPLSQL is a unit testing framework for Oracle PL/SQL and SQL, following industry standards and best practices of modern testing frameworks like [JUnit](http://junit.org/junit4/) and [RSpec](http://rspec.info/).

## Key Features

- Multiple ways to compare data with [matchers](docs/userguide/expectations.md)
- Native comparison of complex types (objects, collections, cursors)
- In-depth and consistent reporting of failures and errors
- Tests identified and configured by [annotations](docs/userguide/annotations.md)
- Hierarchies of test suites configured with annotations
- Automatic (configurable) transaction control
- Built-in [coverage](docs/userguide/coverage.md) reporting
- Integration with SonarQube, Jenkins and TeamCity via [reporters](docs/userguide/reporters.md)
- Plugin architecture for reporters and matchers
- Flexible and simple test invocation
- Multi-format reporting from the [command line client](https://github.com/utPLSQL/utPLSQL-cli)

## Requirements

- Oracle Database 19c or newer

## Installation

Published releases are available for download on the [utPLSQL GitHub Releases page](https://github.com/utPLSQL/utPLSQL/releases).

To install utPLSQL into a new database schema and grant it to public, execute the script `install_headless.sql`.
This creates a new user `UT3`, grants all required privileges, and creates PUBLIC synonyms.

For all install options see the [Install Guide](docs/userguide/install.md).

## Quick Start

**1. Write a test package**

Annotate a package specification to define a test suite and its tests, then implement each test procedure in the package body:

```sql
create or replace package test_between_string as

  -- %suite(Between string function)

  -- %test(Returns substring from start position to end position)
  procedure normal_case;

  -- %test(Returns null for null input string value)
  procedure null_string;
end;
/

create or replace package body test_between_string as

  procedure normal_case is
  begin
    ut.expect( betwnstr( '1234567', 2, 5 ) ).to_( equal('2345') );
  end;

  procedure null_string is
  begin
    ut.expect( betwnstr( null, 2, 5 ) ).to_( be_null );
  end;

end;
/
```

**2. Run your tests**

```sql
exec ut.run();
```

**3. See the results**

```
Between string function
  Returns substring from start position to end position
  Returns null for null input string value

Finished in .036027 seconds
2 tests, 0 failures
```

For complete working examples see [examples/](examples/).

## Running Tests

From any Oracle-compatible IDE (SQL Developer, TOAD, PL/SQL Developer):

```sql
begin
  ut.run();
end;
/
```
```sql
exec ut.run();
```
```sql
select * from table(ut.run());
```

These commands run all suites in the current schema and report test results to `DBMS_OUTPUT` or as a result set.

## Command Line Client

[utPLSQL-cli](https://github.com/utPLSQL/utPLSQL-cli) lets you run tests without an Oracle Client or IDE. It provides:

- Real-time test reporting
- Simultaneous output of multiple report formats into different files
- Source files and test files mapping for coverage reports

Download the [latest release](https://github.com/utPLSQL/utPLSQL-cli/releases/latest) and see the [CLI readme](https://github.com/utPLSQL/utPLSQL-cli/blob/develop/README.md) for details.

## Documentation

Full documentation is published at [https://www.utplsql.org/utPLSQL/](https://www.utplsql.org/utPLSQL/).

[Cheat-sheets](https://www.cheatography.com/jgebal/lists/utplsql-v3-cheat-sheets/) are available for quick reference.

See the [Changelog](CHANGELOG.md) for the full version history.

Migrating from legacy utPLSQL v2? See the [version 2 to version 3 comparison](docs/compare_version2_to_3.md).

## Contributing

We welcome contributions of all kinds. Please read the [contributing guide](CONTRIBUTING.md) and the [code of conduct](CODE_OF_CONDUCT.md) before getting started.

[GitHub Discussions](https://github.com/utPLSQL/utPLSQL/discussions) is the place to ask questions and connect with the team.

The list of **authors** and **significant contributors** is available on the [About](https://www.utplsql.org/about/) page. For a full list of contributors, see [contributors](https://github.com/utPLSQL/utPLSQL/graphs/contributors?all=1) on GitHub.

