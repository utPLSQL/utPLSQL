#utPLSQL v3<sub><sup> | Powerful PL/SQL Unit Testing Framework </sup></sub>
[![chat](http://img.shields.io/badge/version_status-pre--alpha-blue.svg)](http://utplsql-slack-invite.herokuapp.com/)
[![build](https://img.shields.io/travis/utPLSQL/utPLSQL/version3.svg?label=version3%20build)](https://travis-ci.org/utPLSQL/utPLSQL)
[![license](http://img.shields.io/badge/license-apache%202.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)
[![chat](http://img.shields.io/badge/chat-slack-blue.svg)](http://utplsql-slack-invite.herokuapp.com/)
[![twitter](https://img.shields.io/twitter/follow/shields_io.svg?style=social&label=Follow)](https://twitter.com/utPLSQL)

----------
Version 3 is a complete rewrite of utPLSQL from scratch.  Version 2 still supports older versions of Oracle that are no longer available.   This has lead to difficult to maintain code.  Yet many developers wanted to take it to the next level.  The community that had developed on GitHub, decided that a new internal architecture was needed, from that version 3 was born.  Currently version 3 is not complete and is not ready for a production environment as the API is not stable and changing.   However it is quickly taking shape.  We welcome new developers to join our community and help utPLSQL grow.

Primary Goals:
 - Easier to maintain 
  - Only supports versions of Oracle under [Extend Support](http://www.oracle.com/us/support/library/lifetime-support-technology-069183.pdf)  (Currently 11.2, and 12.1)
  - API is documented in the code where possible.
 - Robust and vibrant assertion library.
 - Support for Code Coverage
 - Extensible API
 - Published upgrade/conversion path from version 2.
 - Easily called from current PL/SQL development tools
 - More permissive License to allow vendors easier ability to integrate utPLSQL. 

__Version 2 to Version 3 Comparison__

The following table is a work in progress right now, and **will** change.   If you have great idea that you would like to see in version 3 please create an [issue on GitHub](https://github.com/utPLSQL/utPLSQL/issues) or discuss it with us in the [Slack chat rooms](http://utplsql-slack-invite.herokuapp.com/).  


| Feature                   | Version 2     | Version 3              |
| ------------------------- | ------------- | ---------------------- |
| Easy to install           | Yes           | Yes                    |
| Documentation             | Yes           | Sparse - in progress   |
| License                   | GPL v2        | Apache 2.0             |
| **Tests Creation**        |               |                        |
| Declarative test configuration coupled with the source code | No | Yes - Annotations<sup>1</sup>|
| Tests as Packages         | Yes           | Yes                    |
| Multiple Tests in a single Package | Yes  |  Yes                   |
| Different Setup/Teardown <br/> For Each Test in a Single Package | No  | Yes |
| Suite Definition Storage  | Tables        | Package - Annotations<sup>1</sup>  |
| Multiple Suites           | Yes           | Yes                    |
| Automatic Test detection  | No            | Yes - Annotations<sup>1</sup>      |
| Require Prefix on Test packages   | Yes   | No                     |
| Require Prefix on Test procedures | Yes   | No                     |
| Auto Compilation of Tests | Yes           | No (Let us know if you use this) | 
| Assertion Library         | 30 Assertions<sup>2</sup> | Still under development |
| Custom Record Assertions	| requires generated code through **utRecEq** Package | Pass as into ANY_DATA Assertions  | 
| Test Skeleton Generation  | Yes           | On Roadmap             |
| **Test Execution<sup>3</sup>** |          |                        |
| Single Test Execution     |  Yes          | Yes                    | 
| Test Suite Execution      |  Yes          | Yes                    |
| Subset of Suite Execution |  No           | Yes                    |
| Multiple Suite Execution  |  No           | Yes                    |
| Code Coverage             |  No           | On Roadmap             |
| **Test Output**           |               |                        |
| DBMS_OUTPUT               | Yes           | Yes (format changed)   |
| Stored in Table           | Yes           | On Roadmap             |
| JUnit XML Format          | No            | On Roadmap             |
| HTML Format               | Yes           | On Roadmap             |
| File                      | Yes           | On Roadmap             |
| Realtime test execution results | No       | On Roadmap             |
| Custom Output reporter    | Yes           | Yes                    |

<sup>1</sup> Annotations are specially formatted comments in your package specification.  This enables *declarative* test configuration that is coupled with the source code.   See Documentation for more details. 

<sup>2</sup> **utAssert2** package - Contains 59 Assertions - 2 Not implemented = 57, 28 are duplicated only change on outcome_in parameter 57-28 = 29, **utPipe** package - Contains 1 Assertion 29 + 1 = 30

<sup>3</sup> Test execution comparison is in a single call so the results are combined.   We know it was always possible group in any way with multiple calls.  But that may not be desired under CI system where you want a single JUnit XML Output.


__Primary Directories__

* .travis - contains files needed for travis-ci integration
* docsource - source code to the documentation generation 
* examples - contains example unit tests.
* source - contains the code utPLSQL
* lib - 3rd party libraries that are required for source. 
* tests - contains the tests written to test utPLSQL
* tools - contains required developer tools (NaturalDocs)




 

