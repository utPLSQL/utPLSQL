![version](https://img.shields.io/badge/version-v3.1.8.3148--develop-blue.svg)

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
procedure test_cur_skip_columns_eq is
  l_expected sys_refcursor;
  l_actual   sys_refcursor;
begin
  open l_expected for select 'text' ignore_me, d.* from user_tables d;
  open l_actual   for select sysdate "ADate",  d.* from user_tables d;
  ut.expect( l_actual ).to_equal( l_expected ).exclude( 'IGNORE_ME,ADate' );
end;

procedure test_cur_skip_columns_cn is
  l_expected sys_refcursor;
  l_actual   sys_refcursor;
begin
  open l_expected for select 'text' ignore_me, d.* from user_tables d where rownum = 1;
  open l_actual   for select sysdate "ADate",  d.* from user_tables d;
  ut.expect( l_actual ).to_contain( l_expected ).exclude( 'IGNORE_ME,ADate' );
end;
```

Columns 'ignore_me' and "ADate" will get excluded from cursor comparison.
The cursor data is equal or includes expected, when those columns are excluded.

This option is useful in scenarios, when you need to exclude incomparable/unpredictable column data like CREATE_DATE of a record that is maintained by default value on a table column.

## Selecting columns for data comparison

Consider the following example
```sql
procedure include_col_as_csv_eq is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
begin
    open l_expected for select rownum as rn, 'a' as "A_Column", 'x' SOME_COL from dual a connect by level < 4;
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'x' SOME_COL, a.* from all_objects a where rownum < 4;
    ut.expect( l_actual ).to_equal( l_expected ).include( 'RN,A_Column,SOME_COL' );
end;

procedure include_col_as_csv_cn is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
begin
    open l_expected for select rownum as rn, 'a' as "A_Column", 'x' SOME_COL from dual a connect by level < 4;
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'x' SOME_COL, a.* from all_objects a where rownum < 6;
    ut.expect( l_actual ).to_contain( l_expected ).include( 'RN,A_Column,SOME_COL' );
end;
```

## Combining include/exclude options
You can chain the advanced options in an expectation and mix the `varchar2` with `ut_varchar2_list` arguments.
When doing so, the final list of items to include/exclude will be a concatenation of all items.   

```sql
procedure include_col_as_csv_eq is
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

procedure include_col_as_csv_cn is
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

```

Example of `include / exclude` for anydata.convertCollection

```plsql
create or replace type person as object(
  name varchar2(100),
  age  integer
)
/
create or replace type people as table of person
/

create or replace package ut_anydata_inc_exc IS

   --%suite(Anydata)

   --%test(Anydata include)
   procedure ut_anydata_test_inc;

   --%test(Anydata exclude)
   procedure ut_anydata_test_exc;
   
   --%test(Fail on age)
   procedure ut_fail_anydata_test;
   
end ut_anydata_inc_exc;
/

create or replace package body ut_anydata_inc_exc IS

   procedure ut_anydata_test_inc IS
    l_actual           people := people(person('Matt',45));
    l_expected         people :=people(person('Matt',47));
  begin
    ut3.ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected)).include('NAME');  
   end;

   procedure ut_anydata_test_exc IS
    l_actual           people := people(person('Matt',45));
    l_expected         people :=people(person('Matt',47));
  begin
    --Arrange
    ut3.ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected)).exclude('AGE');   
   end;

   procedure ut_fail_anydata_test IS
    l_actual           people := people(person('Matt',45));
    l_expected         people :=people(person('Matt',47));
  begin
    --Arrange
    ut3.ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected)).include('AGE');   
  end;

end ut_anydata_inc_exc;
/

```

will result in :

```sql
Anydata
  Anydata include [.044 sec]
  Anydata exclude [.035 sec]
  Fail on age [.058 sec] (FAILED - 1)
 
Failures:
 
  1) ut_fail_anydata_test
      Actual: ut3.people [ count = 1 ] was expected to equal: ut3.people [ count = 1 ]
      Diff:
      Rows: [ 1 differences ]
        Row No. 1 - Actual:   <AGE>45</AGE>
        Row No. 1 - Expected: <AGE>47</AGE>
```



Example of exclude

Only the columns 'RN', "A_Column" will be compared. Column 'SOME_COL' is excluded.

This option can be useful in scenarios where you need to narrow-down the scope of test so that the test is only focused on very specific data.  

## Unordered

Unordered option allows for quick comparison of two compound data types without need of ordering them in any way.

Result of such comparison will be limited to only information about row existing or not existing in given set without actual information about exact differences.

```sql
procedure unordered_tst is
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
```

Above test will result in two differences of one row extra and one row missing. 

```sql
      Diff:
      Rows: [ 2 differences ]
      Missing:  <ROW><USERNAME>TEST</USERNAME><USER_ID>-600</USER_ID></ROW>
      Extra:    <ROW><USERNAME>TEST</USERNAME><USER_ID>-610</USER_ID></ROW>
```

**Note**

> `contain` matcher is not considering order of compared data-sets. Using `unordered` makes no difference (it's default)


## Join By option

The `join_by` syntax enables comparison of unordered compound data types by joining data using specified columns. 

You can join two compound data types by defining join column(s) that will be used to uniquely identify and compare data rows. 
With this option, framework is able to identify which rows are missing, which are extra and which are different without need to have both cursors uniformly ordered. 
When the specified join column(s) are not unique, join will partition set over rows with the same key and join on row number as well as given join key. 
The extra or missing rows will be presented to user as well as all non-matching rows. 

Join by option can be used in conjunction with include or exclude options. 
However if any of the join keys is part of exclude set, comparison will fail and report to user that sets could not be joined on specific key, as the key was excluded.

```sql
procedure join_by_username is
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
```

Above test will result in a difference in row 'TEST' regardless of data order.

```sql
      Rows: [ 1 differences ]
        PK <USERNAME>TEST</USERNAME> - Expected: <USER_ID>-600</USER_ID>
        PK <USERNAME>TEST</USERNAME> - Actual:   <USER_ID>-610</USER_ID>
```

**Note** 

> When using `join_by`, the join column(s) are displayed first (as PK) to help you identify the mismatched rows/columns.

You can use `join_by` extended syntax in combination with `contain / include ` matcher.

```sql
procedure join_by_username_cn is
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
```

Above test will indicate that in actual data-set

```sql
     Actual: refcursor [ count = 43 ] was expected to contain: refcursor [ count = 44 ]
     Diff:
     Rows: [ 1 differences ]
       PK <USERNAME>TEST</USERNAME> - Missing   <USER_ID>-610</USER_ID>
```


### Joining using multiple columns

You can specify multiple columns in `join_by`

```sql
procedure test_join_by_many_columns is
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

create or replace package test_join_by is
--%suite

--%test
procedure test_join_by_object_attribute;

end;
/

create or replace package body test_join_by is
  procedure test_join_by_object_attribute is
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

end;
/

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

create or replace package test_join_by is
--%suite

--%test
procedure test_join_by_collection_elem;

end;
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
Actual: refcursor [ count = 1 ] was expected to equal: refcursor [ count = 1 ]
Diff:
Unable to join sets:
  Join key PERSONS/PERSON/NAME does not exists in expected
  Join key PERSONS/PERSON/NAME does not exists in actual
  Please make sure that your join clause is not refferring to collection element
```

**Note**
>`join_by` option is slower to process as it needs to perform a cursor join.

## Defining item lists in option
XPath expressions are deprecated. They are currently still supported but in future versions they can be removed completely. Please use a current standard of defining items filter.

When using item list expression, keep in mind the following:

- object type attributes are nested under `<OBJECTY_TYPE>` element
- nested table and varray items type attributes are nested under `<ARRAY><OBJECTY_TYPE>` elements

Example of a valid parameter to include columns: `RN`, `A_Column`, `SOME_COL` in data comparison. 
```sql
procedure include_col_list is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
begin
    open l_expected for select rownum as rn, 'a' as "A_Column", 'x' SOME_COL from dual a connect by level < 4;
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'x' SOME_COL, a.* from all_objects a where rownum < 4;
    ut.expect( l_actual ).to_equal( l_expected ).include( 'RN,A_Column,SOME_COL' );
    ut.expect( l_actual ).to_equal( l_expected ).include( ut_varchar2_list( 'RN', 'A_Column', 'SOME_COL' ) );
end;
```

## Unordered columns / uc option

If you need to perform data comparison of compound data types without strictly depending on column order in the returned result-set, use the `unordered_columns` option.
Shortcut name `uc` is also available for that option.

Expectations that compare compound data type data with `unordered_columns` option, will not fail when columns are ordered differently.

This option can be useful whn we have no control over the ordering of the column or the column order is not of importance from testing perspective.

```sql
create or replace package test_unordered_columns as
  --%suite

  --%test
  procedure cursor_include_unordered_cols;
end;
/

create or replace package body test_unordered_columns as

  procedure cursor_include_unordered_cols is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange
    open l_actual for select owner, object_name,object_type from all_objects where owner = user
    order by 1,2,3 asc;
    open l_expected for select object_type, owner, object_name from all_objects where owner = user
    and rownum < 20;

    --Assert
    ut.expect(l_actual).to_contain(l_expected).unordered_columns();
  end;
end;
/

exec ut.run('test_unordered_columns');
```

The above test is successful despite the fact that column ordering in cursor is different.

```
test_unordered_columns
  cursor_include_unordered_cols [.042 sec]
 
Finished in .046193 seconds
1 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```



