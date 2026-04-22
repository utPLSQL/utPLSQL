# Changelog

All notable changes to utPLSQL are documented here.
Releases are available on the [GitHub Releases page](https://github.com/utPLSQL/utPLSQL/releases).

---

## [v3.2.01] - 2026-04-22

## Important
  - Dropped support for Oracle Database versions older than 19c

## New features
  - Add TAP reporter by @WayneNani in [#1305](https://github.com/utPLSQL/utPLSQL/pull/1305)

## Enhancements and bug fixes
  - Added duplicate detection on cursor comparison using `join_by` by @lwasylow in [#1295](https://github.com/utPLSQL/utPLSQL/pull/1295)
  - Fix code causing the object duration Oracle exception on oracle 23.26 by @lwasylow in [#1310](https://github.com/utPLSQL/utPLSQL/pull/1310)
  - Packages with annotation-like comments are not test suites by @jgebal in [#1313](https://github.com/utPLSQL/utPLSQL/pull/1313)
  - Performance improvements to annotation parsing by @lwasylow in [#1312](https://github.com/utPLSQL/utPLSQL/pull/1319)
  - Updated documentation and copyright banners across source files @jgebal in [#1319](https://github.com/utPLSQL/utPLSQL/pull/1319) 

---

## [v3.1.14] - 2024-02-19

## New features

  - Added support for `and` and `or` operators when running tests by tags by @lwasylow in [#1250](https://github.com/utPLSQL/utPLSQL/pull/1250)

## Enhancements

  - Allow for test runs over 4 hours by @jgebal in [#1243](https://github.com/utPLSQL/utPLSQL/pull/1243)
  - Framework performance improvements by @jgebal in [#1249](https://github.com/utPLSQL/utPLSQL/pull/1249)
  - Support multiple expectation failures with teamcity reporter by @jgebal in [#1251](https://github.com/utPLSQL/utPLSQL/pull/1251)
  - Update TFS reporter to correct format by @lwasylow in [#1270](https://github.com/utPLSQL/utPLSQL/pull/1270)

## Bug fixes

  - Address issue where the `not_to(contain)` did not run correctly by @lwasylow in [#1246](https://github.com/utPLSQL/utPLSQL/pull/1246)
  - Fix regex to be NLS_SORT independent by @jgebal in [#1253](https://github.com/utPLSQL/utPLSQL/pull/1253)
  - Fix output length error and output buffer. by @jgebal in [#1255](https://github.com/utPLSQL/utPLSQL/pull/1255)
  - (docs): Update running-unit-tests.md - remove example by @gassenmj in [#1261](https://github.com/utPLSQL/utPLSQL/pull/1261)
  - The line-rate is not recorded for packages and classes in cobertura coverage reporter by @lwasylow in [#1269](https://github.com/utPLSQL/utPLSQL/pull/1269)
  - (docs): Fix nested list issue by @iamrachid in [#1274](https://github.com/utPLSQL/utPLSQL/pull/1274)

---

## [v3.1.13] - 2022-12-11

## New features
  
  - Add ability to run tests by part of a name. Fixed in [#1203](https://github.com/utPLSQL/utPLSQL/pull/1203), resolves [#470](https://github.com/utPLSQL/utPLSQL/issues/470)

## Enhancements

  - Added documentation section on creating a custom reporter. Fixed in [#1225](https://github.com/utPLSQL/utPLSQL/pull/1225), resolves [#710](https://github.com/utPLSQL/utPLSQL/issues/701)
  - Add ability to specify code coverage objects include/exclude masks as regular expressions. Fixed in [#1186](https://github.com/utPLSQL/utPLSQL/issues/1186), resolves [#1053](https://github.com/utPLSQL/utPLSQL/issues/1053)

## Bug fixes

  - Comparing collection that have long type names. Fixed in [#1238](https://github.com/utPLSQL/utPLSQL/issues/1238), resolves [#1235](https://github.com/utPLSQL/utPLSQL/issues/1235). 
  - Code coverage reporting on code with long lines. Fixed in [#1240](https://github.com/utPLSQL/utPLSQL/issues/1240), resolves [#1232](https://github.com/utPLSQL/utPLSQL/issues/1232), [#1087](https://github.com/utPLSQL/utPLSQL/issues/1087). 
  - Code coverage reporting does not exclude tests. Fixed in [#1226](https://github.com/utPLSQL/utPLSQL/issues/1226), resolves [#1222](https://github.com/utPLSQL/utPLSQL/issues/1222). 
  - Uninstall script buffer overflow. Fixed in [#1221](https://github.com/utPLSQL/utPLSQL/issues/1221), resolves [#1220](https://github.com/utPLSQL/utPLSQL/issues/1220). 

## Internal improvements

  - Improved process of generating utPLSQL documentation. Implemented in [689bbd0](https://github.com/utPLSQL/utPLSQL/commit/689bbd0e365ed919315c29727bc10fbfc0dadce8), resolves [#1237](https://github.com/utPLSQL/utPLSQL/issues/1237).
  - Removed username env variables for internal development. Implemented in [#1201](https://github.com/utPLSQL/utPLSQL/issues/1221), resolves [#1200](https://github.com/utPLSQL/utPLSQL/issues/1200).
  - Test execution data of utPLSQL project not showing on SonarCloud. Implemented in [#1199](https://github.com/utPLSQL/utPLSQL/issues/1199), resolves [#1198](https://github.com/utPLSQL/utPLSQL/issues/1198).

---

## [v3.1.12] - 2022-02-25

## New features
 - Added support for description in the `--%disabled` annotation. See [documentation](https://github.com/utPLSQL/utPLSQL/blob/4515e0b5a3b4b0de0c2198db3235ef8614bff4d8/docs/userguide/annotations.md#disabled). Implemented in: [#1183](https://github.com/utPLSQL/utPLSQL/pull/1183), resolves [#610](https://github.com/utPLSQL/utPLSQL/issues/610).
 - Added support for native `JSON` datatype on Oracle `21c`. Implemented in [#1181](https://github.com/utPLSQL/utPLSQL/pull/1181), resolves [#1114](https://github.com/utPLSQL/utPLSQL/issues/1114).
 - Added new mather `to_be_within( distance|pct ).of_(expoected)`. See [documentation](https://github.com/utPLSQL/utPLSQL/blob/fd7ef9c14111a48e03fff7851f990c7192539170/docs/userguide/expectations.md#to_be_within-of). Implemented in [#1076](https://github.com/utPLSQL/utPLSQL/pull/1076), resolves [#77](https://github.com/utPLSQL/utPLSQL/issues/77).

## Enhancements

- Improved performance of SQL used to retrieve Coverage sources. Implemented in [#1187](https://github.com/utPLSQL/utPLSQL/pull/1187), resolves [#1169](https://github.com/utPLSQL/utPLSQL/issues/1169).
- Added ability for utPLSQL to gather coverage on code invoking DBMS_STATS package. Implemented in [#1184](https://github.com/utPLSQL/utPLSQL/pull/1184), resolves [#1097](https://github.com/utPLSQL/utPLSQL/issues/1097), [#1094](https://github.com/utPLSQL/utPLSQL/issues/1094).
- Fixed typos and improved documentation. Implemented in [#1173](https://github.com/utPLSQL/utPLSQL/pull/1173), [#1171](https://github.com/utPLSQL/utPLSQL/pull/1171)

## Bug fixes

- Actual and Expected are now correctly reported when comparing `JSON` data. Implemented in [#1181](https://github.com/utPLSQL/utPLSQL/pull/1181), resolves [#1113](https://github.com/utPLSQL/utPLSQL/issues/1113).
- Packages with removed annotations are now correctly recognized as non-utPLSQL packages. Implemented in [#1180](https://github.com/utPLSQL/utPLSQL/pull/1180), resolves [#1177](https://github.com/utPLSQL/utPLSQL/issues/1177).
- Fixed issues with comparison of nested object structures. Implemented in [#1179](https://github.com/utPLSQL/utPLSQL/pull/1179), resolves [#1082](https://github.com/utPLSQL/utPLSQL/issues/1082), [#1083](https://github.com/utPLSQL/utPLSQL/issues/1083), [#1098](https://github.com/utPLSQL/utPLSQL/issues/1098).

## Internal improvements

- Moved build and test process for utPLSQL from Travis to GithubActions. Implemented in [#1175](https://github.com/utPLSQL/utPLSQL/pull/1175)

---

## [v3.1.11] - 2021-11-17

## Enhancements

- utPLSQL can now be used to generate coverage reports for external tools. See [documentation](https://github.com/utPLSQL/utPLSQL/blob/955de5c2dc527a98a6f5dc0dd8bd8d81a44c459f/docs/userguide/coverage.md#reporting-coverage-outside-of-utplsql)
  Implemented in: [#1079](https://github.com/utPLSQL/utPLSQL/pull/1079), resolves [#1025](https://github.com/utPLSQL/utPLSQL/issues/1025)
- Enhanced UT_COVERAGE_COBERTURA_REPORTER to better support TFS and GitLab. Implemented in [#1137](https://github.com/utPLSQL/utPLSQL/pull/1137) and [#1140](https://github.com/utPLSQL/utPLSQL/pull/1140), resolves [#1107](https://github.com/utPLSQL/utPLSQL/issues/1107)
- Added support for installation on Oracle 21c - removed dependency on DBMS_OBFUSCATION_TOOLKIT. Implemented in [#1112](https://github.com/utPLSQL/utPLSQL/pull/1112), resolves [#1111](https://github.com/utPLSQL/utPLSQL/issues/1111) and [#1127](https://github.com/utPLSQL/utPLSQL/issues/1127)
- Added support for running utPLSQL framework in parallel-enabled database. Implemented in [#1160](https://github.com/utPLSQL/utPLSQL/pull/1160), resolves [#1134](https://github.com/utPLSQL/utPLSQL/issues/1134)

## Bug fixes

- Suite structure is built properly even with other than English TNS settings. Implemented in [#1061](https://github.com/utPLSQL/utPLSQL/pull/1061), resolves [#1060](https://github.com/utPLSQL/utPLSQL/issues/1060)
- Fixed XML content reporting (CDATA) in UT_REALTIME_REPORTER used by SQLDeveloper plugin. Implemented in [#1075](https://github.com/utPLSQL/utPLSQL/pull/1075), resolves [#1073](https://github.com/utPLSQL/utPLSQL/issues/1073)
- Fixed XML content reporting (CDATA) in JUnit reporter - regression. Implemented in [#1085](https://github.com/utPLSQL/utPLSQL/pull/1085), resolves [#1084](https://github.com/utPLSQL/utPLSQL/issues/1084)
- Fixed issue with utPLSQL failing to run coverage reporting when trigger has overlapping name with procedure/function/package/type. Implemented in [#1091](https://github.com/utPLSQL/utPLSQL/pull/1091), resolves [#1086](https://github.com/utPLSQL/utPLSQL/issues/1086)
- Fixed issue with parsing utPLSQL suites with DDL trigger when usign AUTHID clause. Implemented in [#1093](https://github.com/utPLSQL/utPLSQL/pull/1093), resolves [#1088](https://github.com/utPLSQL/utPLSQL/issues/1088)

## Internal improvements

- Improved how privilege checks are handled by framework installation. Implemented in [#1056](https://github.com/utPLSQL/utPLSQL/pull/1056), resolves [#1050](https://github.com/utPLSQL/utPLSQL/issues/1050)
- Restructured installation instructions to make it more readable. Implemented in [#1063](https://github.com/utPLSQL/utPLSQL/pull/1063), resolves [#1062](https://github.com/utPLSQL/utPLSQL/issues/1062)
- Updated database requirements in documentation. Implemented in [#1065](https://github.com/utPLSQL/utPLSQL/pull/1065), resolves [#1064](https://github.com/utPLSQL/utPLSQL/issues/1064)
- Removed duplicated call to install profiler tables. Implemented in [#1164](https://github.com/utPLSQL/utPLSQL/pull/1164), resolves [#1149](https://github.com/utPLSQL/utPLSQL/issues/1149)
- Fixed failing internal framework tests on Oracle 21c.  Implemented in [#1158](https://github.com/utPLSQL/utPLSQL/pull/1158), resolves [#1151](https://github.com/utPLSQL/utPLSQL/issues/1151)
- Fixed confusing typo in documentation. Resolves [#1154](https://github.com/utPLSQL/utPLSQL/issues/1154)
- Moved build process from travis-ci.org to travis-ci.com. Implemented in [#1152](https://github.com/utPLSQL/utPLSQL/pull/1152)
- Added an example of reporter reporting all expectations, not only the failing ones. Implemented in [#1092](https://github.com/utPLSQL/utPLSQL/pull/1092)

---

## [v3.1.10] - 2020-02-23

## Enhancements

- utPLSQL test runner is now validating arguments of `--%throws` annotations at runtime [#721](https://github.com/utPLSQL/utPLSQL/issues/721) [#1033](https://github.com/utPLSQL/utPLSQL/issues/1033)
- Documented limitations of insignificant spaces comparison in compound data [#880](https://github.com/utPLSQL/utPLSQL/issues/880)
- utPLSQL will now detect empty annotation cache for schema even with DLL trigger enabled [#975](https://github.com/utPLSQL/utPLSQL/issues/975)
- Order of procedures and annotation now determines default order of tests in suite [#1036](https://github.com/utPLSQL/utPLSQL/issues/1036)    

## Bug fixes

- Nested contexts are now properly identified [#1034](https://github.com/utPLSQL/utPLSQL/issues/1034)
- TeamCity test reporter is now including error message [#1045](https://github.com/utPLSQL/utPLSQL/issues/1045)

## Internal improvements

- All self-tests for utPLSQL framework can now be executed using test-owner schema [#969](https://github.com/utPLSQL/utPLSQL/issues/969)
- Misleading rollback warning is no longer showing when running self-tests for utPLSQL [#982](https://github.com/utPLSQL/utPLSQL/issues/982)

---

## [v3.1.9] - 2019-11-10

## New features

- Added ability to define [nested contexts](https://github.com/utPLSQL/utPLSQL/blob/v3.1.9/docs/userguide/annotations.md#context) within test suite [#938](https://github.com/utPLSQL/utPLSQL/issues/938)
- Added ability to [exclude tests/suites by tags](https://github.com/utPLSQL/utPLSQL/blob/v3.1.9/docs/userguide/annotations.md#excluding-testssuites-by-tags) when invoking a test-run [#1007](https://github.com/utPLSQL/utPLSQL/issues/1007) [#983](https://github.com/utPLSQL/utPLSQL/issues/983)
- Added new annotation [`--%name`](https://github.com/utPLSQL/utPLSQL/blob/v3.1.9/docs/userguide/annotations.md#name) to allow for providing custom name for contexts [#1016](https://github.com/utPLSQL/utPLSQL/issues/1016)

## Important changes

The value of `--%context` annotation is no longer representing context `name`.
This value is now context description (displayname).
With this change, the `--%context` annotation is now aligned with `--%test` and `--%suite` annotation syntax.

New annotation `--%name` was introduced to facilitate naming of contexts.

## Enhancements

- Improved documentation for running tests
- Improved documentation for tags [#1003](https://github.com/utPLSQL/utPLSQL/issues/1003)
- Improved documentation for annotations

## Bug fixes

- Fixed bug with bad stacktrace showing in failing/erroring test [#1000](https://github.com/utPLSQL/utPLSQL/issues/1000)
- Fixed issue with lack of validation for context name [#966](https://github.com/utPLSQL/utPLSQL/issues/966)
- Fixed problem with install script privilege check for installation with DDL trigger [#992](https://github.com/utPLSQL/utPLSQL/issues/992)
- Fixed issue with some common column names causing cursor comparison to fail [#997](https://github.com/utPLSQL/utPLSQL/issues/997)
- Fixed issue with invocation of standalone expectations on cursor [#998](https://github.com/utPLSQL/utPLSQL/issues/998)

## Internal improvements

- Fixed runability of utplsql self-tests [#968](https://github.com/utPLSQL/utPLSQL/issues/968)

---

## [v3.1.8] - 2019-09-03

## New features

- Added support for [session context](https://github.com/utPLSQL/utPLSQL/blob/v3.1.8/docs/userguide/annotations.md#sys_context) to provide test and suite information during test run [#963](https://github.com/utPLSQL/utPLSQL/issues/963) [#781](https://github.com/utPLSQL/utPLSQL/issues/781)
- Added ability to [invoke expectations without running framework](https://github.com/utPLSQL/utPLSQL/blob/v3.1.8/docs/userguide/expectations.md#running-expectations-outside-utplsql-framework) [#956](https://github.com/utPLSQL/utPLSQL/issues/956) [#963](https://github.com/utPLSQL/utPLSQL/issues/963)
- Failing expectations are now reported with call stack [#967](https://github.com/utPLSQL/utPLSQL/issues/967) [#963](https://github.com/utPLSQL/utPLSQL/issues/963)

## Enhancements

- Improved framework table private data protection [#922](https://github.com/utPLSQL/utPLSQL/issues/922) [#954](https://github.com/utPLSQL/utPLSQL/issues/954)
- Improved install process. It is now unified for installation with both public and private synonyms [#957](https://github.com/utPLSQL/utPLSQL/issues/957) [#954](https://github.com/utPLSQL/utPLSQL/issues/954)
- Improved reporting of warnings for integration with SQLDeveloper [#964](https://github.com/utPLSQL/utPLSQL/issues/964)
- Improved query to retrieve coverage sources [#981](https://github.com/utPLSQL/utPLSQL/issues/981) [#970](https://github.com/utPLSQL/utPLSQL/issues/970)
- Improved security around malicious utPLSQL owner name [#920](https://github.com/utPLSQL/utPLSQL/issues/920)

## Bug fixes

- Fixed cursor comparison on Oracle 11.2 [#947](https://github.com/utPLSQL/utPLSQL/issues/947)
- Fixed issue with retrieving suite data [#977](https://github.com/utPLSQL/utPLSQL/issues/977) [#974](https://github.com/utPLSQL/utPLSQL/issues/974) [#978](https://github.com/utPLSQL/utPLSQL/issues/978)
- Application context is now reset in session after test run [#951](https://github.com/utPLSQL/utPLSQL/issues/951)

---

## [v3.1.7] - 2019-06-18

## New features

- Added support for [comparing `json`](https://github.com/utPLSQL/utPLSQL/blob/v3.1.7/docs/userguide/expectations.md#comparing-json-objects) in Oracle 12.2 and above [#924](https://github.com/utPLSQL/utPLSQL/issues/924)
- Introduced [`tag` annotation](https://github.com/utPLSQL/utPLSQL/blob/v3.1.7/docs/userguide/annotations.md#tags) to enable tagging of tests and suites [#66](https://github.com/utPLSQL/utPLSQL/issues/66)
- Added support for [random order](https://github.com/utPLSQL/utPLSQL/blob/v3.1.7/docs/userguide/running-unit-tests.md#random-order) of test execution [#422](https://github.com/utPLSQL/utPLSQL/issues/422)

## Enhancements

- Added optional [install with DDL trigger](https://github.com/utPLSQL/utPLSQL/blob/v3.1.7/docs/userguide/install.md#installation-with-ddl-trigger) to speed up framework start [#901](https://github.com/utPLSQL/utPLSQL/issues/901)
- Removed dependency on `dbms_utility.name_resolve` [#569](https://github.com/utPLSQL/utPLSQL/issues/569) [#885](https://github.com/utPLSQL/utPLSQL/issues/885)
- New output buffer table structures improving performance and addressing timeout issues [#915](https://github.com/utPLSQL/utPLSQL/issues/915)

## Bug fixes

- Fixed `ut_realtime_reporter` missing warnings in test and suite output structures [#936](https://github.com/utPLSQL/utPLSQL/issues/936)
- Fixed output_buffer purging error [#934](https://github.com/utPLSQL/utPLSQL/issues/934)
- Fixed `join_by / exclude / include` invalid syntax on collection in anydata compare [#912](https://github.com/utPLSQL/utPLSQL/issues/912)
- Fixed `ut_junit_reporter`  producing invalid output on failing tests with long failure message [#927](https://github.com/utPLSQL/utPLSQL/issues/927)
- Fixed `ut_sonar_test_reporter`  producing invalid output on failing tests with long failure message [#925](https://github.com/utPLSQL/utPLSQL/issues/925)
- Fixed `ut_coverage_cobertura_reporter` producing wrong line breaks which breaks the xml validation against DTD [#917](https://github.com/utPLSQL/utPLSQL/issues/917)
- Fixed `exclude` option for ref cursor where column order was not resolved correctly [#911](https://github.com/utPLSQL/utPLSQL/issues/911)
- Fixed `unordered` option for ref cursor with null values [#914](https://github.com/utPLSQL/utPLSQL/issues/914)
- Fixed number precision when selecting from dual [#907](https://github.com/utPLSQL/utPLSQL/issues/907)
- Fixed ref cursor errors with generated column names [#902](https://github.com/utPLSQL/utPLSQL/issues/902)
- Fixed `ORA-00907` when comparing ref cursors with BINARY_ columns [#899](https://github.com/utPLSQL/utPLSQL/issues/899)
- Fixed wrong results when comparing CLOBs with `to_be_like` in Oracle Database 11.2.0.4 due to Oracle Bug 14402514 [#891](https://github.com/utPLSQL/utPLSQL/issues/891)
- Fixed performance issue with code coverage report on huge PL/SQL code base [#882](https://github.com/utPLSQL/utPLSQL/issues/882)

## Documentation improvements

- Added install instructions for DDL trigger [#874](https://github.com/utPLSQL/utPLSQL/issues/874)

## Internal enhancements

- Fixed SQL vulnerability on all input parameters used in dynamic SQL and PL/SQL [#921](https://github.com/utPLSQL/utPLSQL/issues/921)
- Fixed message id in output buffer [#916](https://github.com/utPLSQL/utPLSQL/issues/916)
- Included 19c database in self testing [#909](https://github.com/utPLSQL/utPLSQL/issues/909)
- Introduced testing with multiple schemas and different grants [#893](https://github.com/utPLSQL/utPLSQL/issues/893)
- Fixed installation script warnings [#879](https://github.com/utPLSQL/utPLSQL/issues/879)

---

## [v3.1.6] - 2019-03-24

Bugfix release for `v3.1.5`

## Bug fixes

- Fixed a bug in release `3.1.5` where `to_equal` matcher was failing due to privileges when comparing non sql diffable types [#870](https://github.com/utPLSQL/utPLSQL/issues/870)

## Improvements
- Reduced number of information displaying about user defined type. We will now display only type name instead of full structure [#866](https://github.com/utPLSQL/utPLSQL/issues/866)

---

## [v3.1.5] - 2019-03-20

Bugfix release for `v3.1.4`

## Bug fixes

- Fixed a bug in release `3.1.4` where `to_be_empty` matcher was failing due to privileges [#864](https://github.com/utPLSQL/utPLSQL/issues/864)

---

## [v3.1.4] - 2019-03-19

**This release contains a bug that is fixed by release 3.1.5**
Please use release 3.1.5 rather than this release.

## New features

- Added `to_contain` matcher for collections and cursors [#79](https://github.com/utPLSQL/utPLSQL/issues/79)
- Added `unordered_columns` (`uc`) option for cursor comparison to ignore the order of the columns [#779](https://github.com/utPLSQL/utPLSQL/issues/779)
- Added `ut_debug_reporter` for debug logging [#480](https://github.com/utPLSQL/utPLSQL/issues/480)
- Added `ut_realtime_reporter` for utPLSQL-SQLDeveloper extension [#795](https://github.com/utPLSQL/utPLSQL/issues/795)

## Important Changes

- Due to improvements of the cursor comparison, it is now necessary to use `ut.set_nls()` before creating the cursor and `ut.reset_nls()` after the __expectation__ when comparing dates. [More info in the docs](https://github.com/utPLSQL/utPLSQL/blob/v3.1.4/docs/userguide/expectations.md#comparing-cursor-data-containing-date-fields)

## Enhancements

- Improved performance of cursor comparison [#780](https://github.com/utPLSQL/utPLSQL/issues/780)
- Added support for installation on databases with block size < 8KB [#848](https://github.com/utPLSQL/utPLSQL/issues/848)
- Added initial timeout to `ut_output_buffer` [#840](https://github.com/utPLSQL/utPLSQL/issues/840)
- Enhanced performance of `get_reporters_list` function [#814](https://github.com/utPLSQL/utPLSQL/issues/814)
- Moved calls of `dbms_lock.sleep` to `dbms_session` for newer DB versions [#806](https://github.com/utPLSQL/utPLSQL/issues/806)
- utPLSQL coverage will now work without re-install after DB-upgrade from 12.1 to 12.2 [#803](https://github.com/utPLSQL/utPLSQL/issues/803)

## Bug fixes

- Fixed problem with REGEXP in annotation parsing with NLS CANADIAN FRENCH [#844](https://github.com/utPLSQL/utPLSQL/issues/844)
- Fixed issue with Rollback to savepoint failing on distributed transaction [#839](https://github.com/utPLSQL/utPLSQL/issues/839)
- Fixed reporting of differences when comparing collections scalar values [#835](https://github.com/utPLSQL/utPLSQL/issues/835)
- Fixed issue with test run failing due to too many transaction invalidators [#834](https://github.com/utPLSQL/utPLSQL/issues/834)
- Fixed randomly occurring error during cursor comparison [#827](https://github.com/utPLSQL/utPLSQL/issues/827)
- utPLSQL install script will now support special characters in passwords [#804](https://github.com/utPLSQL/utPLSQL/issues/804)

## Documentation improvements

- Fixed documentation examples for context annotation [#851](https://github.com/utPLSQL/utPLSQL/issues/851)
- Added description on how to check version of utPLSQL [#822](https://github.com/utPLSQL/utPLSQL/issues/822)

## Internal enhancements

- Implemented Sonar analysis on DBA Views [#850](https://github.com/utPLSQL/utPLSQL/issues/850)
- Finished migration from old-tests [#475](https://github.com/utPLSQL/utPLSQL/issues/475)
- Fixed shell scripts to support multiple unix dialects (especially for macOS) [#796](https://github.com/utPLSQL/utPLSQL/issues/796)
- Added info on project support from Redgate [#841](https://github.com/utPLSQL/utPLSQL/issues/841)
- Added `code_of_conduct` [#836](https://github.com/utPLSQL/utPLSQL/issues/836)
- Added issue templates [#842](https://github.com/utPLSQL/utPLSQL/issues/842)
- Added utPLSQL logo [#845](https://github.com/utPLSQL/utPLSQL/issues/845)

---

## [v3.1.3] - 2018-11-20

## New features

- added function  `ut_runner.is_test` [#788](https://github.com/utPLSQL/utPLSQL/issues/788)
- added function  `ut_runner.is_suite` [#787](https://github.com/utPLSQL/utPLSQL/issues/787)
- added function  `ut_runner.has_suites` [#786](https://github.com/utPLSQL/utPLSQL/issues/786)
- added ability to disable automatic rollback for a test-run [#784](https://github.com/utPLSQL/utPLSQL/issues/784)
- when invoked with package name, utPLSQL will now run only tests from specified package even if package has child packages by suitepath [#776](https://github.com/utPLSQL/utPLSQL/issues/776)

## Enhancements

- Improved performance of schema-scanning and utPLSQL startup [#778](https://github.com/utPLSQL/utPLSQL/issues/778)
- Improved performance of output-buffer [#777](https://github.com/utPLSQL/utPLSQL/issues/777)
- Improved documentation to mention ability to pass client encoding for HTML & XML reports [#775](https://github.com/utPLSQL/utPLSQL/issues/775)
- Improved documentation for cursor comparison to mention challenges with TIMESTAMP bind variables

## Bug-fixes

- utPLSQL code coverage will now work properly with long object names [#716](https://github.com/utPLSQL/utPLSQL/issues/716)
- utPLSQL installation will now also work properly, when user performing the install has `ANY` grants [#737](https://github.com/utPLSQL/utPLSQL/issues/737)
- fixed documentation bug for `--%context` with `--%displayname` [#726](https://github.com/utPLSQL/utPLSQL/issues/726)
- fixed Teamcity reporter issues with missing escape for some characters and long messages [#747](https://github.com/utPLSQL/utPLSQL/issues/747)
- fixed issue with sonar test results reporter when contexts are used [#749](https://github.com/utPLSQL/utPLSQL/issues/749)
- fixed issue with ORA-07455 getting thrown on cursor comparison [#752](https://github.com/utPLSQL/utPLSQL/issues/752)
- fixed issue with wrong failure message for unordered data [#764](https://github.com/utPLSQL/utPLSQL/issues/764)
- fixed missing privilege issue for unordered/join-by cursor data comparison [#765](https://github.com/utPLSQL/utPLSQL/issues/765) [#770](https://github.com/utPLSQL/utPLSQL/issues/770)

## Internal enhancements

- added suite-level cache to allow for faster retrieval of suite contents and enable implementation of additional features [#783](https://github.com/utPLSQL/utPLSQL/issues/783)

---

## [v3.1.2] - 2018-07-22

## New features

- Added ability to join and compare cursor content by specific columns (PK/UK) [#453](https://github.com/utPLSQL/utPLSQL/issues/453)
- Added support for comma separated list of suite paths/packages when calling `ut.run` [#479](https://github.com/utPLSQL/utPLSQL/issues/479)
- Added ability to run a test package that got invalidated due to dependency invalidation [#489](https://github.com/utPLSQL/utPLSQL/issues/489)
- Added support for package level constants and predefined exceptions in `--%throws` annotation [#685](https://github.com/utPLSQL/utPLSQL/issues/685)
- Added support for standalone `--%beforeall`, `--%beforeeach`, `--%afterall`, `--%aftereach` annotations with list of procedures to execute [#649](https://github.com/utPLSQL/utPLSQL/issues/649)
- Added support for list of procedure names in before/after annotations [#649](https://github.com/utPLSQL/utPLSQL/issues/649)
- Added support for BLOB/CLOB in `is_empty()` matcher [#707](https://github.com/utPLSQL/utPLSQL/issues/707)

## Enhancements

- utPLSQL will now provide additional warnings, when unsupported annotations are found in a unit test suite package [#624](https://github.com/utPLSQL/utPLSQL/issues/624)
- utPLSQL will now produce valid XML in UT_JUNIT_REPORTER when dbms_output or test results contain `<![CDATA[` text [#643](https://github.com/utPLSQL/utPLSQL/issues/643)
- improved installation process for non-DBA users [#658](https://github.com/utPLSQL/utPLSQL/issues/658)
- added `uninstall_all.sql` script that completely removes utPLSQL objects [#673](https://github.com/utPLSQL/utPLSQL/issues/673)
- Changed the way contexts are named [#674](https://github.com/utPLSQL/utPLSQL/issues/674)
- Added ability to pass client encoding information for XML/HTML reporting (requires utPLSQL-cli 3.1.1) [#676](https://github.com/utPLSQL/utPLSQL/issues/676)
- Exposed base objects for expectations, so that IDE like DataGrip can provide auto-complete [#675](https://github.com/utPLSQL/utPLSQL/issues/675)
- Both context-name as well as procedure inside context can now be passed as parameter to `ut.run()` [#679](https://github.com/utPLSQL/utPLSQL/issues/679)
- Added validation of privileges before installation of utPLSQL [#693](https://github.com/utPLSQL/utPLSQL/issues/693)

## Bug-fixes

- UT_JUNIT_REPORTER does not report tests when procedure names are not all lower-case [#659](https://github.com/utPLSQL/utPLSQL/issues/659) [#696](https://github.com/utPLSQL/utPLSQL/issues/696)
- Fixed utPLSQL installation order to avoid warnings/failures on install [#657](https://github.com/utPLSQL/utPLSQL/issues/657)
- Fixed uninstall process for utPLSQL [#673](https://github.com/utPLSQL/utPLSQL/issues/673)
- Fixed syntax errors in HTML coverage report [#681](https://github.com/utPLSQL/utPLSQL/issues/681) [#682](https://github.com/utPLSQL/utPLSQL/issues/682)
- Fixed install requirements documentation [#687](https://github.com/utPLSQL/utPLSQL/issues/687)
- Fixed capturing of DBMS_OUTPUT buffer at the start of test run [#686](https://github.com/utPLSQL/utPLSQL/issues/686)

## Internal enhancements
- Added continuous testing of XML/HTML reports format [#684](https://github.com/utPLSQL/utPLSQL/issues/684)
- Added sonarcloud branch-based and PR code analysis [#708](https://github.com/utPLSQL/utPLSQL/issues/708)
- Added ability to trigger builds on sub-projects [#501](https://github.com/utPLSQL/utPLSQL/issues/501)

---

## [v3.1.1] - 2018-04-29

Bugfix release for `v3.1.0`

## Bug-fixes:

- [#653](https://github.com/utPLSQL/utPLSQL/issues/653) Block coverage reporting doesn't work on schema other than framework owner
- [#652](https://github.com/utPLSQL/utPLSQL/issues/652) Reporter threads timeout and do not produce outputs when running with `utplsql-cli` and idle time exceeds 1 minute.

---

## [v3.1.0] - 2018-04-25

**Starting with this release, `utPLSQL-sql-cli` is no longer supported.**
**Use [`utPLSQL-cli` release 3.1.0](https://github.com/utPLSQL/utPLSQL-cli/releases) or above to interact with this and upcoming versions of utPLSQL.**

## Enhancements

### Reporting
* Added support for extended block coverage on Oracle 12.2 and above. Coverage reporters will now indicate partly covered lines (where applicable by coverage format).
* Added new `ut_tfs_junit_reporter` for MS Team Foundation Server to support old JUnit xml format
* Added new [coverage reporter](https://github.com/utPLSQL/utPLSQL/blob/develop/docs/userguide/coverage.md) `ut_coverage_cobertura_reporter`
* Fixed compatibility issues with `ut_xunit_reporter`. The reporter now conforms to the format specification.
* Added `ut_junit_reporter` as a base for `ut_xunit_reporter`. The `ut_xunit_reporter` remains active for backward compatibility but is considered depreciated
* Added reporting of differences when comparing cursors, oracle object and table types
* Aligned `ut_documentation_reporter` to display tests annotated`--%disabled` as `DISABLED`
* Added support for reporters that don't provide output to the API (reporters saving data to DB)
* Improved API so that it's possible to support custom reporters from `utPLSQL-java-api` without code changes

### Annotations
* added [`throws` annotation](https://github.com/utPLSQL/utPLSQL/blob/develop/docs/userguide/annotations.md#throws) to simplify writing tests for code that throws an exception
* added [`context`](https://github.com/utPLSQL/utPLSQL/blob/develop/docs/userguide/annotations.md#context) to enable grouping of tests into sub-suite in a test suite package
* added warnings on invalid/misplaced annotations
* added support for multiple declarations of before/after procedures
* added propagation of rollback type defined on parent suite within suitepath

### Expectations
* Added [`have_count` matcher](https://github.com/utPLSQL/utPLSQL/blob/develop/docs/userguide/expectations.md#have_count) for checking cursor rows/collection elements count
* Added [`include()` and `exclude()` extensions](https://github.com/utPLSQL/utPLSQL/blob/develop/docs/userguide/advanced_data_comparison.md#excluding-elements-from-data-comparison) to cursor and object/collection data comparison
* Added [`diff` functionality](https://github.com/utPLSQL/utPLSQL/blob/develop/docs/userguide/expectations.md#diff-functionality-for-compound-data-types) for cursor, object and collection data 
* When comparing cursors, column data-type is now also checked for equality
* [#548](https://github.com/utPLSQL/utPLSQL/issues/548) - Changed behavior of execution of `ut.expect()` on closed cursor.
* Added support for cursors with implicitly named columns

### General improvements
* Output buffer for reporting is now reporter-agnostic.
* cli is no longer not interacting with output buffer but uses reporters to retrieve data instead.
* Added ability to mark expectation syntax as deprecated and report warnings on deprecation
* Added ability to get a list of annotations for a schema
* Refactoring of annotation parsing 
* Refactoring of suite building
* Migrated part of old script-based tests to new utPLSQL v3 tests
* Documentation fixes and improvements
* Reporters now provide a method to get description
* Test execution continues even when encountered `Existing state of packages was discarded/invalidated` exceptions (`ORA-04068`/`ORA-04061`). The whole suite will execute, test result reports will be available and the exception will be re-thrown to the user after the run was finished. ([#504](https://github.com/utPLSQL/utPLSQL/issues/504))

## Bug-fixes:

* [#511](https://github.com/utPLSQL/utPLSQL/issues/511) Coverage schema had to be explicitly provided, even when using `a_include_objects`
* [#514](https://github.com/utPLSQL/utPLSQL/issues/514) / [#516](https://github.com/utPLSQL/utPLSQL/issues/516) utPLSQL fails to run, when one of suite packages has no newline between `--%suite` and procedure-specific annotations.
* [#539](https://github.com/utPLSQL/utPLSQL/issues/539) Fixed false-negative code coverage reporting on labelled `end loop ` elements
* [#547](https://github.com/utPLSQL/utPLSQL/issues/547) Fixed issue with invalid suite grouping when running `xunit_reporter`
* [#562](https://github.com/utPLSQL/utPLSQL/issues/562) Code coverage was always showing first report gathered in a session
* [#572](https://github.com/utPLSQL/utPLSQL/issues/572) Wrong format of time in XUnit_reporter when running on German locale (using comma as decimal separator)
* [#601](https://github.com/utPLSQL/utPLSQL/issues/601) Fixed issue with wrong exception getting thrown when suite failed and there was a pending distributed transaction
* [#568](https://github.com/utPLSQL/utPLSQL/issues/568) Fixed file-mapper issue where two files were mapped into the same object and caused `ORA-00001: unique constraint (UTP3.UT_COVERAGE_SOURCES_TMP_PK) violated`

---

## [v3.0.4] - 2017-11-03

Bugfixes:
* [#509](https://github.com/utPLSQL/utPLSQL/issues/509) ([#506](https://github.com/utPLSQL/utPLSQL/issues/506)) Savepoint name is now generated from sys_guid to avoid issues on Windows-based Oracle instances
* [#500](https://github.com/utPLSQL/utPLSQL/issues/500) ([#499](https://github.com/utPLSQL/utPLSQL/issues/499)/[#487](https://github.com/utPLSQL/utPLSQL/issues/487)) Fixed XML/HTML special characters in reporters and unified handling of failure reporting across reporters

Documentation:
* [#503](https://github.com/utPLSQL/utPLSQL/issues/503) Fixed link to contributing guide in the doc
* [#502](https://github.com/utPLSQL/utPLSQL/issues/502) Added example of handling exceptions to documentation
* [#486](https://github.com/utPLSQL/utPLSQL/issues/486) ([#485](https://github.com/utPLSQL/utPLSQL/issues/485)) Added example for custom expectation-fail message in docs

Enhancements:
* [#497](https://github.com/utPLSQL/utPLSQL/issues/497) ([#478](https://github.com/utPLSQL/utPLSQL/issues/478)) Removed overloaded procedures `ut_runner.run`
* [#496](https://github.com/utPLSQL/utPLSQL/issues/496) ([#441](https://github.com/utPLSQL/utPLSQL/issues/441)) utPLSQL will not not open new transaction when running tests
* [#495](https://github.com/utPLSQL/utPLSQL/issues/495) ([#482](https://github.com/utPLSQL/utPLSQL/issues/482)) Added buffering of dbms_output before the run
* [#494](https://github.com/utPLSQL/utPLSQL/issues/494) Removed `ut_expectation` sub-types
* [#492](https://github.com/utPLSQL/utPLSQL/issues/492) Restructured annotations and added caching to improve framework start-up time

---

## [v3.0.3] - 2017-08-30

### New features
- [#242](https://github.com/utPLSQL/utPLSQL/issues/242) Added ability to exclude columns/attributes for cursor/object/collection comparison. Xpath can be used for column/attribute exclusion
- [#428](https://github.com/utPLSQL/utPLSQL/issues/428) Added reporting to `module`, `action`, `client_info` fields of the `v$session`. 
- [#408](https://github.com/utPLSQL/utPLSQL/issues/408) Calling `ut_runner.run` procedures can now raise exception if any test failed
- [#430](https://github.com/utPLSQL/utPLSQL/issues/430) Added ability to check version compatibility `ut_runner.version_compatibility_check`

### Improvements and fixes
- [#469](https://github.com/utPLSQL/utPLSQL/issues/469) Fixed bug with framework executing multiple packages with similar names when using suitepaths
- [#462](https://github.com/utPLSQL/utPLSQL/issues/462) Cursor comparison now supports cursors on Global Temporary Table
- [#461](https://github.com/utPLSQL/utPLSQL/issues/461) Increased allowed chars for annotation name to 250
- [#445](https://github.com/utPLSQL/utPLSQL/issues/445) Cursor comparison now supports cursors with more than 1000 rows
- [#431](https://github.com/utPLSQL/utPLSQL/issues/431) `dba_` views are now used (if available), increasing performance of the framework
- [#430](https://github.com/utPLSQL/utPLSQL/issues/430) Changed how version number reporting in functions `ut_runner.version`, `ut_run.version`
- [#364](https://github.com/utPLSQL/utPLSQL/issues/364) Improved warning message when implicit commit occurs
- [#413](https://github.com/utPLSQL/utPLSQL/issues/413) Fixed Sonar Unit Test reporting for test suites with suitepth
- [#435](https://github.com/utPLSQL/utPLSQL/issues/435) Fixed problem with identifying annotations when windows newline is used in package sources

### Documentation fixes
- [#467](https://github.com/utPLSQL/utPLSQL/issues/467) Moved CONTRIBUTING.md to project root and updated content
- [#434](https://github.com/utPLSQL/utPLSQL/issues/434) Fixed coverage format documentation
- [#439](https://github.com/utPLSQL/utPLSQL/issues/439) Small documentation fixes

### Internal improvements
- [#450](https://github.com/utPLSQL/utPLSQL/issues/450) Added self-testing using released version of utPLSQL
- [#438](https://github.com/utPLSQL/utPLSQL/issues/438) Sonar reporting disabled for PRs
- [#424](https://github.com/utPLSQL/utPLSQL/issues/424) Moved to project-owned Docker images created by scripts from [utPLSQL/docker-scripts](https://github.com/utPLSQL/docker-scripts) project
- [#212](https://github.com/utPLSQL/utPLSQL/issues/212) Added source_path and test_path parameters for coverage reporters
- [#420](https://github.com/utPLSQL/utPLSQL/issues/420) Changed the way `ut_file_mapper` handles default parameters
- [#417](https://github.com/utPLSQL/utPLSQL/issues/417) Improved performance and stability of access to internal framework tables
- [#425](https://github.com/utPLSQL/utPLSQL/issues/425) Updated myStats library to v3
- [#402](https://github.com/utPLSQL/utPLSQL/issues/402) `ut_output_buffer` is now abstracted from caller

---

## [v3.0.2] - 2017-07-18

### Documentation
- [#399](https://github.com/utPLSQL/utPLSQL/issues/399) Documentation now refers to [migration](https://github.com/utPLSQL/utPLSQL-v2-v3-migration) project
- [#386](https://github.com/utPLSQL/utPLSQL/issues/386) Documentation now refers to a valid object name: `ut_file_mapping`
- [#362](https://github.com/utPLSQL/utPLSQL/issues/362) Install and Uninstall scripts are now much more readable
- [#361](https://github.com/utPLSQL/utPLSQL/issues/361) Install guide now provides snippet on how to download latest release on Windows

### Installation
- [#396](https://github.com/utPLSQL/utPLSQL/issues/396) Added override user/password/tablespace for install_headless
- [#384](https://github.com/utPLSQL/utPLSQL/issues/384) Installation is now smooth even if profiler tables already exist

### Internal improvements
- [#388](https://github.com/utPLSQL/utPLSQL/issues/388) Improved reporting from RunTest
- [#363](https://github.com/utPLSQL/utPLSQL/issues/363) Fixed publishing of release documentation history

### Improvements and fixes
- [#407](https://github.com/utPLSQL/utPLSQL/issues/407) Fixed rare issue with `ORA-22813: operand value exceeds system limits`
- [#403](https://github.com/utPLSQL/utPLSQL/issues/403) Stack trace is now properly parsed on all machines
- [#397](https://github.com/utPLSQL/utPLSQL/issues/397) The `--%disabled` annotation on suite level is now reporting all tests as disabled
- [#395](https://github.com/utPLSQL/utPLSQL/issues/395) Coverage reporting is now properly filtering test packages on that use suitepath
- [#390](https://github.com/utPLSQL/utPLSQL/issues/390) Line of code for failed expectation is now also shown for unit tests owned by other users
- [#380](https://github.com/utPLSQL/utPLSQL/issues/380) Line no of failed test is now properly reported when using `ut.fail`
- [#375](https://github.com/utPLSQL/utPLSQL/issues/375) Annotation parameter list can now have spaces before/after brackets
- [#373](https://github.com/utPLSQL/utPLSQL/issues/373) Warnings in documentation reporter are now properly numbered
- [#372](https://github.com/utPLSQL/utPLSQL/issues/372) Documentation reporter is now providing a timing information for each test
- [#370](https://github.com/utPLSQL/utPLSQL/issues/370) by xUnit reporter now displays name of the package/procedure if suite/test has no description
- [#369](https://github.com/utPLSQL/utPLSQL/issues/369) Fixed errors with multi-byte characters in conversion from/to clob

---

## [v3.0.1] - 2017-06-14

Issues solved in the release:
* [#346](https://github.com/utPLSQL/utPLSQL/issues/346) ORA-22921: length of input buffer is smaller than amount requested
* [#337](https://github.com/utPLSQL/utPLSQL/issues/337) Suite/test description gets cut after the inner closing bracket
* [#336](https://github.com/utPLSQL/utPLSQL/issues/336) Suite/test description gets cut after comma
* [#334](https://github.com/utPLSQL/utPLSQL/issues/334) Bad/misleading failure message when comparing different datatypes
* [#331](https://github.com/utPLSQL/utPLSQL/issues/331) running tests in a user containing '$'
* [#322](https://github.com/utPLSQL/utPLSQL/issues/322) Fix prompts for install of synonyms
* [#326](https://github.com/utPLSQL/utPLSQL/issues/326) Fix to HTML Coverage
* [#332](https://github.com/utPLSQL/utPLSQL/issues/332) fixed failed expectation source code line reporting on12c R2

Other changes:
* [#320](https://github.com/utPLSQL/utPLSQL/issues/320) Fix deployment to gh-pages branch on TAG
* [#340](https://github.com/utPLSQL/utPLSQL/issues/340), [#342](https://github.com/utPLSQL/utPLSQL/issues/342), [#349](https://github.com/utPLSQL/utPLSQL/issues/349) small issues in the documentation
* [#328](https://github.com/utPLSQL/utPLSQL/issues/328) fixing build number in version
* [#353](https://github.com/utPLSQL/utPLSQL/issues/353) Add MD5 checksum to release builds

---

## [v3.0.0] - 2017-05-18

First official release of fully rewritten utPLSQL.
The unit testing framework for Oracle database.

------------------------------------

Key features

- Compatible with and tested on Oracle 11.2, 12.1 and 12.2
- multiple ways to compare data with matchers
- native comparison of complex types (objects/collections/cursors)
- in-depth and consistent reporting of failures and errors for tests
- tests identified and configured by annotations
- hierarchies of test suites configured controlled by annotations
- automatic (configurable) transaction control using annotations
- Build-in [coverage](https://utplsql.github.io/utPLSQL-coverage-html/) reporting
- Integration with [SonarQube](https://sonarqube.com/dashboard?id=utPLSQL%3AutPLSQL%3Adevelop), [Coveralls](https://coveralls.io/github/utPLSQL/utPLSQL), [Jenkins](https://jenkins.io/) and [Teamcity](https://www.jetbrains.com/teamcity) using reporters
- plugin architecture for reporters and matchers
- flexible and simple test invocation
- multi-reporting and test real-time progress test-run from using [utPLSQL-cli](https://github.com/utPLSQL/utPLSQL-cli/)
