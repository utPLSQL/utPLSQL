# How to contribute

The following are the guidelines everyone should use to contribute to utPLSQL.  
Changes are welcome from all members of the Community.  
Not able to contribute code? You can also support the project through [sponsorship](https://www.utplsql.org/sponsorship.html).

# Getting Started

1. Create a [GitHub Account](https://github.com/join).
2. Fork the utPLSQL Repository and setup your local Repository. _See [how to Fork](https://help.github.com/articles/fork-a-repo) article_
     * Each of the steps below are detailed in **Get started with development** section.
     * Clone your Fork to your local machine.
     * Configure "upstream" remote to the [utPLSQL repository](https://github.com/utPLSQL/utPLSQL.git).
3. For each change you want to make:
     * Make sure your forked repository is up to date with upstream before you start coding. See [syncing your local repository](https://help.github.com/articles/syncing-a-fork) with upstream utPLSQL repository.
     * Create a new branch for your change. We use `feature/feature_name` or `bugfix/fixed_issue_name` to identify branch types.
     * Make your change in your new branch.
     * Make sure your change is covered with unit tests.
     * **Verify code compiles and all existing and new unit tests pass.**
         * The quickest way to have a Pull Request not approved, is to submit code that does not compile or pass tests.
     * Commit change to your local repository.
     * Push change to your remote repository.
     * Submit a [Pull Request](https://help.github.com/articles/using-pull-requests) into develop branch.
     * Note: local and remote branches can be deleted after pull request has been merged.

# Coding Standards

* We use snake case for all identifiers in PLSQL code. This separates keywords in names with underscores.  `execute_test`
* All code is lower case.
* Prefixes:
	* Arguments to procedures and functions will start with `a_`, an Example would be procedure `is_valid(a_owner_name varchar2)`
	* Object types and packages will start with `ut_`
	* Local variables `l_`
	* Local constants `c_`
	* Global variables `g_`
	* Global Constants start with `gc_`
	* Types in packages, objects start with `t_`
	* Nested Tables start with `tt_`
* varchar2 lengths are set in characters not bytes
* Every source file carries the Apache license header.
* Don't edit version strings (`v3.x.x.xxxx`) in `source/`, `VERSION` or `BUILD_NO` by hand. CI rewrites them (`.github/scripts/update_project_version.sh`).

# Engineering principles

Every change (PL/SQL, SQL, install scripts, GitHub workflows, tooling) should follow these principles of Extreme Programming (XP):

- **KISS – Keep It Simple, Stupid**: choose the simplest solution that works and is easy to read; no clever constructs where a plain one will do.
- **DRY – Don't Repeat Yourself**: every piece of knowledge has one authoritative place. Reuse existing packages, types and helpers (`ut_utils` first) instead of copying logic. In GitHub workflows, define a value once and reference it.
- **YAGNI – You Aren't Gonna Need It**: implement only what the task needs now. No speculative parameters, options, columns, abstractions or "future" code paths.

Where they apply to PL/SQL and SQL, also follow the **SOLID** principles. Apply only the ones that fit; don't force them onto plain SQL scripts:

- **S – Single Responsibility Principle**: a package, procedure or type has one cohesive purpose and one reason to change. Split packages that mix unrelated concerns; keep procedures short and focused.
- **O – Open/Closed Principle**: extend behavior without modifying working code, for example by adding a new reporter as a subtype of `ut_reporter_base`, or a new matcher as a subtype of `ut_matcher`, instead of adding another branch to a big `if`/`case`.
- **L – Liskov Substitution Principle**: object type subtypes (`under`) must be usable wherever their base type is expected, without changing the expected behavior of the base type's methods.
- **I – Interface Segregation Principle**: keep package specifications small and focused, so callers depend only on what they use. Expose a function in a package spec only if something needs it, and prefer a thin facade over a large catch-all package.
- **D – Dependency Inversion Principle**: depend on package specifications and abstract base types, not on implementation details (package bodies, concrete subtypes, table structures of other modules). Call other modules through their public spec.

Every new functionality should be covered with tests, following the testing pyramid or the testing diamond.

## Refactoring

Before each refactoring step:
- **Check test coverage first.** Make sure existing tests cover the logic being refactored, including its edge cases and error paths. If they don't, add the missing tests and see them pass against the current code before changing it.
- **Find tests that the change would break.** Look for tests that call the procedures, functions or types being moved, merged or removed. Where you can, rewrite those tests to call a higher-level procedure or function that keeps its contract. The tests then check behaviour rather than internal structure, and still pass after the refactoring.

# Code based access control and SQL macros

Some framework packages run with invoker rights (`authid current_user`) and still read and change the framework's cache tables.
They do it through the code based access control (CBAC) role `<utPLSQL schema>_cbac_modify_objects_role`, which [ut3_cbac_modify_objects_role_grants.sql](source/ut3_cbac_modify_objects_role_grants.sql) grants to those packages.
Users calling the framework get no privileges on the tables. The rules below were verified on Oracle 19.20, 21 XE and 23 Free.

## Packages with the CBAC role

- **Grants:** a package that needs the role gets a `grant ... to package` line in the grants script. The objects its SQL uses (tables, types, other packages) are granted to the role in the same script.
- **Qualify framework objects:** in the SQL of these packages, qualify framework objects with the SQL*Plus substitution variable `&&ut3_owner.`, which `install.sql` sets. The code runs as the invoking user, so unqualified names would resolve in that user's schema. When you compile such a body by hand, run `define ut3_owner=ut3_develop` first.
- **Install order:** `install.sql` installs the package specs, then runs the grants script, then installs the bodies. A body that expands a SQL macro needs the role when it compiles; in the other order it fails with `ORA-62565` / `PLS-00201`.
- **Recreating a spec drops the grant:** `create or replace package` removes the package's CBAC role grant, while `create or replace package body` keeps it. After changing such a spec by hand, rerun the grants script as SYS, or run `development/refresh_ut3.sh`.

## SQL macros

- **Table macros only.** utPLSQL is compatible with Oracle 19c (RU 19.20) or later, so table macros are available everywhere it runs.
- **Separate definer rights package:** a macro doesn't compile in an invoker rights package (`PLS-00782`). Macros live in their own `authid definer` packages, such as `ut_annotation_cache_macros` and `ut_suite_cache_macros`.
- **Two grants needed for macro package:** one to the CBAC role in the grants script, and one to the framework users in [create_grants.sql](source/create_grants.sql).
- **Qualify framework objects in the macro text** with `&&ut3_owner.`. The text is expanded into the caller's statement, which runs with invoker rights.
- **Don't use argument values in the macro body.** The body sees an argument's value only when the caller passes a literal; binds and PL/SQL variables arrive as NULL. So the body can't branch on an argument or build SQL from it. Put conditions into the returned text instead, for example `(a_value is null or col > a_value)`.
- **No macro inside a `WITH` clause** (`ORA-64630`). Call the macro from the main query or one of its subqueries. A CTE can be passed as a table argument.
- **No collection columns in a table argument** (`ORA-62558`). Pass a CTE that selects only scalar columns.
- **No `all_objects` in a CTE of a statement that calls a macro.** The statement compiles but fails at run time with `ORA-00942`. Use `all_objects` in the main query instead.
- **Recompile with `alter package ... compile body`.** `dbms_utility.compile_schema` can't recompile a body that expands a macro in static SQL (`ORA-62565`).
- **Test on 19c, 21 XE and 23 Free.** The privilege checks for macros differ between versions.


# Configuring local environment

Your local environment can be of any flavor (Unix/Linux/Windows/Mac).
At minimum, you need to have Oracle database 19c (we use Release Update 19.20 or later) accessible for the project and SYS account access to install and develop utPLSQL.

We use five different database accounts (users) for development process.
* `ut3` - holds latest released version of utPLSQL. This schema holds the testing framework used for self-testing of utPLSQL development.
* `ut3_develop` - holds the version of utPLSQL of your current branch. This is the schema you will be working on.
* `ut3_tester` - holds unit test packages for development of utPLSQL.
* `ut3_user` - used for testing accessibility to schema names with special characters.
* `ut3_tester_helper` - elevated privileges user, used for creating and dropping objects in other schemas during test run.

## Local database in a disposable Docker container

We use, and recommend, a disposable Docker container with Oracle Database Free, built from [gvenzl/oci-oracle-free](https://github.com/gvenzl/oci-oracle-free/tree/main), using image `gvenzl/oracle-free:slim-faststart`.
The container needs no setup and can be thrown away and recreated whenever you need a clean database.
`ORACLE_PASSWORD` sets the SYS password. Use the same value for `ORACLE_PWD` in `development/env.sh`, and connect to `127.0.0.1:1521/FREEPDB1`.

Run the container in background:
```bash
docker run -d --name utplsql-db -p 1521:1521 -e ORACLE_PASSWORD=oracle gvenzl/oracle-free:slim-faststart
```

Stop the container:
```bash
docker stop utplsql-db
```

Restart the container (database content is kept):
```bash
docker restart utplsql-db
```

Recreate the container (database content is lost):
```bash
docker rm -f utplsql-db && docker run -d --name utplsql-db -p 1521:1521 -e ORACLE_PASSWORD=oracle gvenzl/oracle-free:slim-faststart
```

The database is ready to use once `docker logs utplsql-db` shows `DATABASE IS READY TO USE!`.

## Get started with development

To get started with development, follow the below steps.

_If you're using Windows, run the shell scripts using `GIT bash` - Windows-based bash command line._

**Caution**: If you are using jetBrains DataGrip, don't use the integrated console to run the shell scripts (not even with GIT bash configured). It might disconnect from oracle randomly during script-run.

### Clone your fork of utPLSQL git repository

```bash
# clone your fork of utPLSQL
git clone https://github.com/your account/utPLSQL.git utPLSQL

cd utPLSQL

# add main project repo as upstream
git remote add upstream https://github.com/utPLSQL/utPLSQL.git

# fetch all remote repositories
git fetch --all
```

### Prepare environment script

Copy the environment variables template `development/template.env.sh` to `development/env.sh`
```bash
cp development/template.env.sh development/env.sh
chmod u+w development/env.sh
```

You might have to adjust the following lines in `development/env.sh`:
```bash
export SQLCLI=sql # For sqlcl client
#export SQLCLI=sqlplus # For sqlplus client
export CONNECTION_STR=127.0.0.1:1521/FREEPDB1 # Adjust the connect string
export ORACLE_PWD=oracle # Adjust your local SYS password
```

### Download utPLSQL release sources and utplsq-cli

The below script is fetching latest release version from utPLSQL repository. Latest release version is used for self-testing.
```bash
./development/refresh_sources.sh
```

### Setup local database for utPLSQL development

```bash
./development/install.sh
```

### That's it

You now have the following:
- sources from your fork of utPLSQL repository in `utPLSQL` directory
- sources from utPLSQL/utPLSQL repository (branch set by `SELFTESTING_BRANCH` in `development/env.sh`) in `utPLSQL/utPLSQL_latest_release` directory
- binaries of `utplsql-cli` in `utPLSQL/utPLSQL-cli` directory
- database users created
- your current branch of utPLSQL deployed into `ut3_develop` schema
- utPLSQL released version deployed into `ut3` schema

At any time, if you need to refresh your database, the below scripts might be helpful.

## Cleanup of utPLSQL installation in local database

```bash
development/cleanup.sh
```

## Reinstalling utPLSQL development in `ut3_develop` schema

```bash
development/refresh_ut3.sh
```

## Refreshing after release

Whenever a new version of utPLSQL or a new version of utPLSQL-cli is available, use `development/refresh_sources.sh` to refresh files in your local project folders.

## Running unit tests

utPLSQL v3 unit tests are located in the `test` directory

Before you push any changes and create a pull request to the utPLSQL project repository, make sure that all the tests are executing successfully in your local environment.

Every new functionality needs to be documented by unit tests that cover happy-path scenarios as well as edge-cases and exception paths.

> **Important notice:**
> We do our best to keep utPLSQL covered with unit tests.
> Lack of sufficient unit testing is a perfect reason for PR to be rejected.

To run a full suite of unit tests execute:
```bash
. ./development/env.sh
./test/install_and_run_tests.sh
```

You can review the results of tests as well as see information about code coverage in `./coverage.html` file.


## Modules

Below diagram gives a high-level overview of utPLSQL v3 modules and their dependencies.
Dependencies to `ut_util` are not shown as most of modules are depending on it.

![utPLSQL V3 Modules](development/utPSLQLv3-modules.png)


## Build Environment

We are using a combination of private and publicly available docker images to test utPLSQL. The following versions of Oracle Database are used for testing:

* 19c-Standard Edition (private image)
* 21-free
* 23-free

The Free varsions are publicly available and you can set up your local development environment to use one of from [here](https://github.com/gvenzl/oci-oracle-free)

These [private image]((https://github.com/utPLSQL/docker-scripts) is a slimmed version of [the official Oracle database dockerfiles](https://github.com/oracle/docker-images/tree/master/OracleDatabase) . Due to licensing restrictions, the image cannot be public.

You can build your own and use it locally, or push to a private docker repository.
The build steps are simple if you already have some experience using Docker. You can find detailed information about how to build your own image with a running database in: [example of creating an image with pre-built DB](https://github.com/oracle/docker-images/blob/master/OracleDatabase/samples/prebuiltdb/README.md)

> If you are new to Docker, you can start by reading the [Getting Started With Docker](https://docs.docker.com/get-started/) docs.

## New to GIT

If you are new to GIT here are some links to help you with understanding how it works.    

- [GIT Documentation](http://git-scm.com/doc)
- [Atlassian Git Tutorial](https://www.atlassian.com/git/tutorial/git-basics)
- [What are other resources for learning Git and GitHub](https://help.github.com/articles/what-are-other-good-resources-for-learning-git-and-github)
