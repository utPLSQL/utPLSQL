# Coverage
utPLSQL comes with build-in coverage reporting engine. The code coverage reporting is based off DBMS_PROFILER package. Code coverage is gathered for the following source types:
* package bodies
* type bodies
* triggers
* stored procedures
* stored functions

Note:

> The package specifications and type specifications are explicitly excluded from code coverage analysis.This limitation is introduced to avoid false-negatives. Most of the package specifications don't contain executable code. The only exception is initialization of global constants and variables in package specification.Since, most of package specifications are not executable at all, there is no information available on the number of lines covered and those would eb reported as 0% covered, which is not desired.

To obtain information about code coverage of your Unit Tests, all you need to do is run your unit tests with one of build-in code coverage reporters.
Following code coverage reporters are supplied with utPLSQL:
* `ut_coverage_html_reporter` - generates a HTML coverage report providing summary and detailed information on code coverage. The html reporter is based on open-source [simplecov-html](https://github.com/colszowka/simplecov-html) reporter for Ruby. It includes source code of the code that was covered (if possible)  
* `ut_coveralls_reporter` - generates a JSON coverage report providing detailed information on code coverage with line numbers. This coverage report is designed to be consumed by cloud services like [coveralls](https://coveralls.io) 
* `ut_coverage_sonar_reporter`  - generates a JSON coverage report providing detailed information on code coverage with line numbers. This coverage report is designed to be consumed by local services like [sonarqube](https://about.sonarqube.com/)

##Security model
Code coverage is using DBMS_PROFILER to gather information about execution of code under test and therefore follows the [DBMS_PROFILER's Security Model](https://docs.oracle.com/database/121/ARPLS/d_profil.htm#ARPLS67465)
In order to be able to gather coverage information, user executing unit tests needs to be either:
* Owner of the code that is tested
* Have the following privileges to be able to gather coverage on code owned by other users:
    * `create any procedure` system privilege
    * `execute` privilege on the code that is tested (not only the unit tests) or `execute any procedure` system privilege
    
If you have `execute` privilege on the code that are tested, but do not have `create any procedure` system privilege, the code that is tested will be reported as not covered (coverage = 0%).
If you have `execute` privilege only on the unit tests, but do not have `execute` privilege on the code that is tested, the code will not be reported by coverage - as if it did not exist in the database.
If the code that is testes is complied as NATIVE, the code coverage will not be reported as well.

##Running unite tests with coverage
Using code coverage functionality is as easy as using any other [reporter](reporters.md) for utPLSQL project. All you need to do is run your tests from your preferred SQL tool and save the outcomes of reporter to a file.
All you need to do, is pass the constructor of the reporter to your `ut.run`

Example:
```sql
begin
  ut.run(ut_coverage_html_reporter());
end;
/
```
Executes all unit tests in current schema, gather information about code coverage and output the html text into DBMS_OUTPUT.
The `ut_coverage_html_reporter` will produce a interactive HTML report. You may see a sample of code coverage for utPLSQL project [here](https://utplsql.github.io/utPLSQL-coverage-html/)

The report provides a summary information with list of source code that was expected to be covered.

![Coverage Summary page](../images/coverage_html_summary.png)

The report allow to navigate to every source and inspect line by line coverage.

![Coverage Details page](../images/coverage_html_details.png)


##Coverage reporting options
By default the database schema/schemes containing the tests that were executed during the run, are fully reported by coverage reporter.
All valid unit tests are excluded from the report regardless if they were invoked or not. This way the coverage report is not affected by presence of tests and contains only the tested code.

The default behavior of coverage reporters can be altered, depending on your needs.

###Including/excluding objects in coverage reports
The most basic options are the include/exclude objects lists.
You may specify both include and exclude objects lists to specify which objects are to be included in the report and which are to be excluded.
Both of those options are meant to be used to narrow down the scope of unit test runs, that is broad by default.

Example:
```sql
exec ut.run('ut3_user.test_award_bonus', ut_coverage_html_reporter(a_include_object_list=>ut_varchar2_list('ut3_user.award_bonus')));
```
Executes test `test_award_bonus` and gather coverage only on object `ut3_user.award_bonus`

Alternatively you could run:
```sql
exec ut.run('ut3_user.test_award_bonus', ut_coverage_html_reporter(a_exclude_object_list=>ut_varchar2_list('ut3_user.betwnstr')));
```
Executes test `test_award_bonus` and gather on all objects in schema `ut3_user` except valid unit test objects and object `betwnstr` that schema.

You can also combine the parameters and both will be applied.
 
###Defining different schema name(s)
In some architectures, you might end up in a situation, where your unit tests exist in a different schema than the tested code.
This is not the default or recommended approach but is supporter by utPLSQL.
In such scenarios, you would probably have a separate database schema to hold unit tests and a separate schema/schemes to hold the tested code.
Since by default, coverage reporting is done on the schema/schemes that the invoked tests are on, the code will not be included in coverage report as it is in a different schema than the invoked tests. 

In this situation you need to provide list of schema names that the tested code is in. This option overrides the default schema names for coverage.

Example:
```sql
exec ut.run('ut3_user.test_award_bonus', ut_coverage_html_reporter(a_schema_names=>ut_varchar2_list('usr')));
```
Executes test `test_award_bonus` in schema `ut3_user` and gather coverage for that execution on all non `unit-test` objects from schema `usr`.

You can combine schema names with include/exclude parameters and all will be applied.
The `a_schema_names` parameter takes precedence however, so if include list contains objects from other schemes, that will not be considered.  
 
Example:
```sql
begin
  ut.run(
    'ut3_user.test_award_bonus', 
    ut_coverage_html_reporter(
      a_schema_names => ut_varchar2_list('usr'), 
      a_include_object_list => ut_varchar2_list('usr.award_bonus'),
      a_exclude_object_list => ut_varchar2_list('usr.betwnstr')
    )
  );
end;
```
Executes test `test_award_bonus` in schema `ut3_user` and gather coverage for that execution on `award_bonus` object from schema `usr`. The exclude list is of no relevance as it is not overlapping with include list.

###Working with projects and project files
Both `sonar` and `coveralls` are utilities that are more project-oriented than database-centric. They report statistics and coverage for project files in version control system.
Nowadays, most of database projects are moving away from database-centric approach towards project/product-centric approach.
Coverage reporting of utPLSQL allows you to perform code coverage analysis for your project files.
This feature is supported by all build-in coverage reporting formats.

When using this invocation syntax, coverage is only reported for the provided files, so using project files as input for coverage is also a way of limiting the scope of coverage analysis.
This syntax also allows usage of `a_include_object_list` and `a_exclude_object_list` as optional parameters to filter the scope of analysis. 


**Reporting using externally provided file mapping**
One of ways to perform coverage reporting on your project files is to provide to the coverage reporter a list of file path/names along with mapping to corresponding object name and object type.

Example:
```sql
begin
  ut.run(
    'usr', 
    ut_coverage_html_reporter(
      a_file_mappings=>ut_coverage_file_mappings(
        ut_coverage_file_mapping(
          file_name    => 'sources/hr/award_bonus.prc',
          object_owner => 'usr',
          object_name  => 'award_bonus',
          object_type  => 'procedure'                        
        ),
        ut_coverage_file_mapping(
          file_name    => 'sources/hr/betwnstr.fnc',
          object_owner => 'usr',
          object_name  => 'betwnstr',
          object_type  => 'function'                        
        )
      )
    )
  );
end;
```

Executes all tests in schema `usr` and reports coverage for that execution on procedure `award_bonus` and function `betwnstr`. The coverage report is mapped-back to file-system object names with paths.

**Reporting using regex file mapping rule**
If file names and paths in your project follow a well established naming conventions, 
then you can use the predefined rule for mapping file names to object names or you can define your own rule and pass it to the coverage reporter at runtime.

Example of running with predefined regex mapping rule.
```sql
begin
  ut.run(
    'usr', 
    ut_coverage_html_reporter(
      a_file_paths => ut_varchar2_list('sources/hr/award_bonus.prc','sources/hr/betwnstr.fnc')
    )
  );
end;
```

The predefined rule is based on the following default values for parameters:
* `a_regex_pattern => '.*(\\|\/)((\w+)\.)?(\w+)\.(\w{3})'` 
* `a_object_owner_subexpression => 3`
* `a_object_name_subexpression => 4`
* `a_object_type_subexpression => 5`
* `a_file_to_object_type_mapping` - defined in table below

The predefined file extension to object type mappings

| file extension | object type |
| -------------- | ----------- | 
| tpb | type body | 
| pkb | package body | 
| bdy | package body | 
| trg | trigger | 
| fnc | function | 
| prc | procedure | 

Since package specification and type specifications are not considered by coverage, the file extensions for those objects  are not included in the mapping.

Examples of filename paths that will be mapped correctly using predefined rules.
* `[...]directory[/subdirectory[/...]]/object_name.(tpb|pkb|trg|fnc|prc)`
* `[...]directory[/subdirectory[/...]]/schema_name.object_name.(tpb|pkb|trg|fnc|prc)`
* `[...]directory[\subdirectory[\...]]\object_name.(tpb|pkb|trg|fnc|prc)`
* `[...]directory[\subdirectory[\...]]\schema_name.object_name.(tpb|pkb|trg|fnc|prc)`

If file names in your project structure are not prefixed with schema name (like above), the coverage report will look for objects to match the file names in the `current schema` of the connection that was used to execute tests with coverage.
If for whatever reasons you use a user and current schema that is different then schem that holds your project code, you should use `a_schema_name` parameter to inform coverage reporter about database schema to be used for object lookup.

Example:
```sql
begin
  ut.run(
    'usr', 
    ut_coverage_html_reporter(
      a_schema_name => 'hr',
      a_file_paths  => ut_varchar2_list('sources/hr/award_bonus.prc','sources/hr/betwnstr.fnc')
    )
  );
end;
```

If your project structure is different, you may define your own mapping rule using regex.

Example:
```sql
begin
  ut.run(
    'usr', 
    ut_coverage_html_reporter(
      a_file_paths  => ut_varchar2_list('sources/hr/procedures/award_bonus.sql','sources/hr/functions/betwnstr.sql'),
      a_regex_pattern => '.*(\\|\/)(\w+)\.(\w+)\.(\w{3})',
      a_object_owner_subexpression => 2,
      a_object_type_subexpression => 3,
      a_object_name_subexpression => 4,
      a_file_to_object_type_mapping => ut_key_value_pairs(
        ut_key_value_pair('functions', 'function'),
        ut_key_value_pair('procedures', 'procedure')
    )
  );
end;
```
 
