![version](https://img.shields.io/badge/version-v3.1.12.3731--develop-blue.svg)

# Advanced data comparison

utPLSQL expectations incorporates advanced data comparison options when comparing compound data-types:

- refcursor
- object type
- nested table and varray  
- json data-types

Advanced data-comparison options are available for the [`equal`](expectations.md#equal) and  [`contain`](expectations.md#include--contain) matcher.

Syntax

```
  ut.expect( a_actual {data-type} ).to_( equal( a_expected {data-type})[.extendend_option()[.extendend_option()[...]]]);
  ut.expect( a_actual {data-type} ).not_to( equal( a_expected {data-type})[.extendend_option()[.extendend_option()[...]]]) );
  ut.expect( a_actual {data-type} ).to_equal( a_expected {data-type})[.extendend_option()[.extendend_option()[...]]]);
  ut.expect( a_actual {data-type} ).not_to_equal( a_expected {data-type})[.extendend_option()[.extendend_option()[...]]] );
  ut.expect( a_actual {data-type} ).to_( contain( a_expected {data-type})[.extendend_option()[.extendend_option()[...]]]);
  ut.expect( a_actual {data-type} ).not_to( contain( a_expected {data-type})[.extendend_option()[.extendend_option()[...]]]) );
  ut.expect( a_actual {data-type} ).to_contain( a_expected {data-type})[.extendend_option()[.extendend_option()[...]]]);
  ut.expect( a_actual {data-type} ).not_to_contain( a_expected {data-type})[.extendend_option()[.extendend_option()[...]]]);
```

`extended_option` can be one of:

 - `include(a_items varchar2)` - item or comma separated list of items to include
 - `exclude(a_items varchar2)` - item or comma separated list of items to exclude
 - `include(a_items ut_varchar2_list)` - table of items to include 
 - `exclude(a_items ut_varchar2_list)` - table of items to exclude
 - `unordered` - ignore order of data sets when comparing data. Default when comparing data-sets with  `to_contain` 
 - `join_by(a_columns varchar2)` - column or comma separated list of columns to join two cursors by
 - `join_by(a_columns ut_varchar2_list)` - table of columns to join two cursors by
 - `unordered_columns` / `uc` - ignore the ordering of columns / attributes in compared data-sets. Column/attribute names will be used to identify data to be compared and the position will be ignored. 

Each item in the comma separated list can be:
- a column name of cursor to be compared
- an attribute name of object type to be compared   
- an attribute name of object type within a table of objects to be compared
- Include and exclude option will not support implicit colum names that starts with single quota, or in fact any other special characters e.g. <, >, &

Each element in `ut_varchar2_list` nested table can be an item or a comma separated list of items.

When specifying column/attribute names, keep in mind that the names are **case sensitive**. 

## Excluding elements from data comparison

Consider the following examples
```sql
declare
  l_expected sys_refcursor;
  l_actual   sys_refcursor;
begin
  open l_expected for select 'text' ignore_me, d.* from user_tables d;
  open l_actual   for select sysdate "ADate",  d.* from user_tables d;
  ut.expect( l_actual ).to_equal( l_expected ).exclude( 'IGNORE_ME,ADate' );
end;
/
declare
  l_expected sys_refcursor;
  l_actual   sys_refcursor;
begin
  open l_expected for select 'text' ignore_me, d.* from user_tables d where rownum = 1;
  open l_actual   for select sysdate "ADate",  d.* from user_tables d;
  ut.expect( l_actual ).to_contain( l_expected ).exclude( 'IGNORE_ME,ADate' );
end;
/
```
Produces:
```
SUCCESS
  Actual: refcursor [ count = 23 ] was expected to equal: refcursor [ count = 23 ]

SUCCESS
  Actual: refcursor [ count = 23 ] was expected to contain: refcursor [ count = 1 ]
```

Columns 'ignore_me' and "ADate" will get excluded from data comparison.
The actual data is equal/contains expected, when those columns are excluded.

**Note**
>This option is useful in scenarios, when you need to exclude incomparable/unpredictable column data like CREATE_DATE of a record that is maintained by default value on a table column.

## Selecting columns for data comparison

Consider the following example
```sql
declare
  l_actual   sys_refcursor;
  l_expected sys_refcursor;
begin
  open l_expected for select rownum as rn, 'a' as "A_Column", 'x' SOME_COL from dual a connect by level < 4;
  open l_actual   for select rownum as rn, 'a' as "A_Column", 'x' SOME_COL, a.* from all_objects a where rownum < 4;
  ut.expect( l_actual ).to_equal( l_expected ).include( 'RN,A_Column,SOME_COL' );
end;
/
declare
  l_actual   sys_refcursor;
  l_expected sys_refcursor;
begin
  open l_expected for select rownum as rn, 'a' as "A_Column", 'x' SOME_COL from dual a connect by level < 4;
  open l_actual   for select rownum as rn, 'a' as "A_Column", 'x' SOME_COL, a.* from all_objects a where rownum < 6;
  ut.expect( l_actual ).to_contain( l_expected ).include( 'RN,A_Column,SOME_COL' );
end;
/
```
Produces:
```
SUCCESS
  Actual: refcursor [ count = 3 ] was expected to equal: refcursor [ count = 3 ]

SUCCESS
  Actual: refcursor [ count = 5 ] was expected to contain: refcursor [ count = 3 ]
```

Only columns `RN`,`A_Column` and `SOME_COL `  will be included in data comparison.
The actual data is equal/contains expected, when only those columns are included.

**Note**
>This option can be useful in scenarios where you need to narrow-down the scope of test so that the test is only focused on very specific data.  

## Combining include/exclude options
You can chain the advanced options in an expectation and mix the `varchar2` with `ut_varchar2_list` arguments.
When doing so, the final list of items to include/exclude will be a concatenation of all items.   

```sql
declare
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
begin
    open l_expected for select rownum as rn, 'a' as "A_Column", 'x' SOME_COL from dual a connect by level < 4;
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'Y' SOME_COL, a.* from all_objects a where rownum < 4;
    ut.expect( l_actual ).to_equal( l_expected )
      .include( 'RN')
      .include( ut_varchar2_list( 'A_Column', 'SOME_COL' ) )
      .exclude( 'SOME_COL' );
end;
/
declare
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
begin
    open l_expected for select rownum as rn, 'a' as "A_Column", 'x' SOME_COL from dual a connect by level < 4;
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'Y' SOME_COL, a.* from all_objects a where rownum < 6;
    ut.expect( l_actual ).to_contain( l_expected )
      .include( 'RN')
      .include( ut_varchar2_list( 'A_Column', 'SOME_COL' ) )
      .exclude( 'SOME_COL' );
end;
/
```

Results:
```
SUCCESS
  Actual: refcursor [ count = 3 ] was expected to equal: refcursor [ count = 3 ]

SUCCESS
  Actual: refcursor [ count = 5 ] was expected to contain: refcursor [ count = 3 ]
```

Example of `include / exclude` for anydata.convertCollection

```sql
create or replace type person as object(
  name varchar2(100),
  age  integer
)
/
create or replace type people as table of person
/

declare
  l_actual           people := people(person('Matt',45));
  l_expected         people :=people(person('Matt',47));
begin
  ut3.ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected)).include('NAME');  
end;

declare
  l_actual           people := people(person('Matt',45));
  l_expected         people :=people(person('Matt',47));
begin
  ut3.ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected)).exclude('AGE');   
end;

declare
  l_actual           people := people(person('Matt',45));
  l_expected         people :=people(person('Matt',47));
begin
  ut3.ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected)).include('AGE');   
end;
/
```

Results:
```
SUCCESS
  Actual: ut3.people [ count = 1 ] was expected to equal: ut3.people [ count = 1 ]

SUCCESS
  Actual: ut3.people [ count = 1 ] was expected to equal: ut3.people [ count = 1 ]

FAILURE
  Actual: ut3.people [ count = 1 ] was expected to equal: ut3.people [ count = 1 ]
  Diff:
  Rows: [ 1 differences ]
    Row No. 1 - Actual:   <AGE>45</AGE>
    Row No. 1 - Expected: <AGE>47</AGE>
  at "anonymous block", line 5

```

## Unordered

Unordered option allows for quick comparison of two compound data types without need of ordering them in any way.

Result of such comparison will be limited to only information about row existing or not existing in given set without actual information about exact differences.

```sql
declare
  l_actual   sys_refcursor;
  l_expected sys_refcursor;
begin
  open l_expected for
    select username, user_id from all_users
    union all
    select 'TEST' username, -600 user_id from dual
    order by 1 desc;
  open l_actual for 
    select username, user_id from all_users
    union all
    select 'TEST' username, -610 user_id from dual
    order by 1 asc;
  ut.expect( l_actual ).to_equal( l_expected ).unordered;
end;
/
```

Above test will result in two differences of one row extra and one row missing. 
```
FAILURE
  Actual: refcursor [ count = 29 ] was expected to equal: refcursor [ count = 29 ]
  Diff:
  Rows: [ 2 differences ]
  Extra:    <USERNAME>TEST</USERNAME><USER_ID>-610</USER_ID>
  Missing:  <USERNAME>TEST</USERNAME><USER_ID>-600</USER_ID>
  at "anonymous block", line 15
```
**Note**
> Consider using `join_by( columns... )` over `unordered()` with the `equal` matcher. The `join_by` method is much faster at performing data comparison.
>
> The `contain` matcher is not considering the order of the compared data-sets. Using `unordered` makes no difference (it's default).


## Join By option

The `join_by` syntax enables comparison of unordered compound data types by joining data using specified columns. 

You can join two compound data types by defining join column(s) that will be used to uniquely identify and compare data rows. 
With this option, framework is able to identify which rows are missing, which are extra and which are different without need to have both cursors uniformly ordered. 
When the specified join column(s) are not unique, join will partition set over rows with the same key and join on row number as well as given join key. 
The extra or missing rows will be presented to user as well as all non-matching rows. 

Join by option can be used in conjunction with include or exclude options. 
However if any of the join keys is part of exclude set, comparison will fail and report to user that sets could not be joined on specific key, as the key was excluded.

```sql
declare
  l_actual   sys_refcursor;
  l_expected sys_refcursor;
begin
  open l_expected for 
    select username, user_id from all_users
    union all
    select 'TEST' username, -600 user_id from dual
    order by 1 desc;
  open l_actual for 
    select username, user_id from all_users
    union all
    select 'TEST' username, -610 user_id from dual
    order by 1 asc;
  ut.expect( l_actual ).to_equal( l_expected ).join_by('USERNAME');
end;
/
```

Above test will result in a difference in row 'TEST' regardless of data order.
```
FAILURE
  Actual: refcursor [ count = 29 ] was expected to equal: refcursor [ count = 29 ]
  Diff:
  Rows: [ 1 differences ]
    PK <USERNAME>TEST</USERNAME> - Actual:   <USER_ID>-610</USER_ID>
    PK <USERNAME>TEST</USERNAME> - Expected: <USER_ID>-600</USER_ID>
    PK <USERNAME>TEST</USERNAME> - Extra:    <USERNAME>TEST</USERNAME><USER_ID>-610</USER_ID>
  at "anonymous block", line 15
```

**Note** 

> When using `join_by`, the join column(s) are displayed first (as PK) to help you identify the mismatched rows/columns.

You can use `join_by` syntax in combination with `contain` matcher.

```sql
declare
  l_actual   sys_refcursor;
  l_expected sys_refcursor;
begin
  open l_actual   for select username, user_id from all_users;
  open l_expected for 
    select username, user_id from all_users
    union all
    select 'TEST' username, -610 user_id from dual;
  
  ut.expect( l_actual ).to_contain( l_expected ).join_by('USERNAME');
end;
/
```

Above test will indicate that in actual data-set
```sql
FAILURE
  Actual: refcursor [ count = 28 ] was expected to contain: refcursor [ count = 29 ]
  Diff:
  Rows: [ 1 differences ]
    PK <USERNAME>TEST</USERNAME> - Missing:  <USERNAME>TEST</USERNAME><USER_ID>-610</USER_ID>
  at "anonymous block", line 11
```

### Joining using multiple columns

You can specify multiple columns in `join_by`

```sql
declare
  l_actual   sys_refcursor;
  l_expected sys_refcursor;
begin
  open l_expected for
    select username, user_id, created from all_users
     order by 1 desc;
  open l_actual for
    select username, user_id, created  from all_users
     union all
    select 'TEST' username, -610 user_id, sysdate from dual
     order by 1 asc;
  ut.expect( l_actual ).to_equal( l_expected ).join_by('USERNAME, USER_ID');
end;
/
```

Produces:
```
FAILURE
  Actual: refcursor [ count = 29 ] was expected to equal: refcursor [ count = 28 ]
  Diff:
  Rows: [ 1 differences ]
    PK <USERNAME>TEST</USERNAME><USER_ID>-610</USER_ID> - Extra:    <USERNAME>TEST</USERNAME><USER_ID>-610</USER_ID><CREATED>2019-07-11</CREATED>
  at "anonymous block", line 13 
```

### Joining using attributes of object in column list

`join_by` allows for joining data by attributes of object from column list of the compared compound data types.

To reference attribute as PK, use slash symbol `/` to separate nested elements.

In the below example, cursors are joined using the `NAME` attribute of object in column `SOMEONE`

```sql
create or replace type person as object(
  name varchar2(100),
  age  integer
)
/
create or replace type people as table of person
/

declare
  l_actual   sys_refcursor;
  l_expected sys_refcursor;
begin
  open l_expected for
    select person('Jack',42) someone from dual union all
    select person('Pat', 44) someone from dual union all
    select person('Matt',45) someone from dual;
  open l_actual for
    select person('Matt',55) someone from dual union all
    select person('Pat', 44) someone from dual;
  ut.expect( l_actual ).to_equal( l_expected ).join_by( 'SOMEONE/NAME' );
end;
/
```

Produces:
```
FAILURE
  Actual: refcursor [ count = 2 ] was expected to equal: refcursor [ count = 3 ]
  Diff:
  Rows: [ 2 differences ]
    PK <NAME>Matt</NAME> - Actual:   <SOMEONE><NAME>Matt</NAME><AGE>55</AGE></SOMEONE>
    PK <NAME>Matt</NAME> - Actual:   <AGE>55</AGE>
    PK <NAME>Matt</NAME> - Expected: <SOMEONE><NAME>Matt</NAME><AGE>45</AGE></SOMEONE>
    PK <NAME>Matt</NAME> - Expected: <AGE>45</AGE>
    PK <NAME>Jack</NAME> - Missing:  <SOMEONE><NAME>Jack</NAME><AGE>42</AGE></SOMEONE>
  at "anonymous block", line 12
```

**Note**
> `join_by` does not support joining on individual elements of nested table. You can still use data of the nested table as a PK value.
> When collection is referenced in `join_by`, test will fail with appropriate message, as it cannot perform a join.

```sql
create or replace type person as object(
  name varchar2(100),
  age  integer
)
/
create or replace type people as table of person
/

create or replace package body test_join_by is
  procedure test_join_by_collection_elem is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    open l_expected for select people(person('Matt',45)) persons from dual;
    open l_actual for select people(person('Matt',45)) persons from dual;
    ut.expect( l_actual ).to_equal( l_expected ).join_by('PERSONS/PERSON/NAME');
  end;

end;
/
```

```
FAILURE
  Actual: refcursor [ count = 1 ] was expected to equal: refcursor [ count = 1 ]
  Diff:
  Unable to join sets:
    Join key PERSONS/PERSON/NAME does not exists in expected
    Join key PERSONS/PERSON/NAME does not exists in actual
    Please make sure that your join clause is not refferring to collection element
  
  at "anonymous block", line 7
```

**Note**
>`join_by` option is slower to process as it needs to perform a cursor join. It is still faster than the `unordered`. 

## Defining item lists in option

You may provide items for `include`/`exclude`/`join_by` as a single varchar2 value containing comma-separated list of attributes.

You may provide items for `include`/`exclude`/`join_by` as a a ut_varchar2_list of attributes.   

**Note**
- object type attributes are nested under `<OBJECTY_TYPE>` element
- nested table and varray items type attributes are nested under `<ARRAY><OBJECTY_TYPE>` elements

Example of a valid parameter to include columns: `RN`, `A_Column`, `SOME_COL` in data comparison. 
```sql
declare
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
begin
    open l_expected for select rownum as rn, 'a' as "A_Column", 'x' SOME_COL from dual a connect by level < 4;
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'x' SOME_COL, a.* from all_objects a where rownum < 4;
    ut.expect( l_actual ).to_equal( l_expected ).include( 'RN,A_Column,SOME_COL' );
    open l_expected for select rownum as rn, 'a' as "A_Column", 'x' SOME_COL from dual a connect by level < 4;
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'x' SOME_COL, a.* from all_objects a where rownum < 4;
    ut.expect( l_actual ).to_equal( l_expected ).include( ut_varchar2_list( 'RN', 'A_Column', 'SOME_COL' ) );
end;
/
```

```
SUCCESS
  Actual: refcursor [ count = 3 ] was expected to equal: refcursor [ count = 3 ]
SUCCESS
  Actual: refcursor [ count = 3 ] was expected to equal: refcursor [ count = 3 ]
```

## Unordered columns / uc option

If you need to perform data comparison of compound data types without strictly depending on column order in the returned result-set, use the `unordered_columns` option.
Shortcut name `uc` is also available for that option.

Expectations that compare compound data type data with `unordered_columns` option, will not fail when columns are ordered differently.

This option can be useful whn we have no control over the ordering of the column or the column order is not of importance from testing perspective.

```sql
declare
  l_actual   sys_refcursor;
  l_expected sys_refcursor;
begin
  --Arrange
  open   l_actual for select owner, object_name, object_type from all_objects where owner = user
  order by 1,2,3 asc;
  open l_expected for select object_type, owner, object_name from all_objects where owner = user
  and rownum < 20;

  --Assert
  ut.expect(l_actual).to_contain(l_expected).unordered_columns();
end;
/
```

Produces:
```
SUCCESS
  Actual: refcursor [ count = 348 ] was expected to contain: refcursor [ count = 19 ]
```
