# Exception handling and reporting

The utPLSQL is responsibly for handling exceptions wherever they occure in the test run. Exceptions are pororted as follows:

* A test package without body faced - each `%test` is reported as failed
* A test package with _invalid body_ - each `%test` is reported as failed
* A test package with _invalid spec_ - *`%test`s are skipped*. Only valid specifications are parsed for annotations.
* A test package that is raising an exception in beforeall - each `%test` is reported as failed
* A test package that is raising an exception in afterall - `%test` are reported normally, warnings are displayed in the summary

Example:
```
Remove rooms by name
  Removes a room without content in it
  Does not remove room when it has content
  Raises exception when null room name given
 
Warnings:
 
  1) test_remove_rooms_by_name - Afterall procedure failed: 
       ORA-20001: Test exception
       ORA-06512: at "UT3.TEST_REMOVE_ROOMS_BY_NAME", line 35
       ORA-06512: at line 6
 
Finished in ,044902 seconds
3 tests, 0 failed, 0 errored, 0 ignored. 1 warning(s)
```

* A test package that is raising an exception in `%beforeeach` - each `%test` is reported as failed
* A test package that is raising an exception in `%aftereach` - `%test`s are reported normally, warnings are displayed in the summary

Example:
```
Remove rooms by name
  Removes a room without content in it
  Does not remove room when it has content
  Raises exception when null room name given
 
Warnings:
 
  1) test_remove_rooms_by_name - Aftereach procedure failed:
       ORA-20001: Test exception
       ORA-06512: at "UT3.TEST_REMOVE_ROOMS_BY_NAME", line 31
       ORA-06512: at line 6
 
  2) test_remove_rooms_by_name - Aftereach procedure failed:
       ORA-20001: Test exception
       ORA-06512: at "UT3.TEST_REMOVE_ROOMS_BY_NAME", line 31
       ORA-06512: at line 6
 
  3) test_remove_rooms_by_name - Aftereach procedure failed:
       ORA-20001: Test exception
       ORA-06512: at "UT3.TEST_REMOVE_ROOMS_BY_NAME", line 31
       ORA-06512: at line 6
 
Finished in ,05071 seconds
3 tests, 0 failed, 0 errored, 0 ignored. 3 warning(s)
```

* A test package that is raising an exception in test - the `%test` is reported as failed

Exampple:
```
Remove rooms by name
  Removes a room without content in it (FAILED - 1)
  Does not remove room when it has content
  Raises exception when null room name given
 
Failures:
 
  1) remove_empty_room
        
        error: ORA-20001: Test exception
               ORA-06512: at "UT3.TEST_REMOVE_ROOMS_BY_NAME", line 48
               ORA-06512: at line 6
       
Finished in ,035726 seconds
3 tests, 0 failed, 1 errored, 0 ignored.
```

* A test package that is raising an exception in `%beforetest` - the `%test` is reported as failed

Example:
````
Remove rooms by name
  Removes a room without content in it (FAILED - 1)
  Does not remove room when it has content
  Raises exception when null room name given
 
Failures:
 
  1) remove_empty_room
        
        error: ORA-20001: Test exception
               ORA-06512: at "UT3.TEST_REMOVE_ROOMS_BY_NAME", line 39
               ORA-06512: at line 6
       
Finished in ,039346 seconds
3 tests, 0 failed, 1 errored, 0 ignored.
````

* A test package that is raising an exception in `%aftertest` - the `%test` is reported as failed

Example:
```
Remove rooms by name
  Removes a room without content in it (FAILED - 1)
  Does not remove room when it has content
  Raises exception when null room name given
 
Failures:
 
  1) remove_empty_room
        
        error: ORA-20001: Test exception
               ORA-06512: at "UT3.TEST_REMOVE_ROOMS_BY_NAME", line 42
               ORA-06512: at line 6
       
Finished in ,045523 seconds
3 tests, 0 failed, 1 errored, 0 ignored.
```
