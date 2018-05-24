# Advanced data comparison

utPLSQL expectations incorporates advanced data comparison options when comparing compound data-types:

- refcursor
- object type
- nested table and varray  

Advanced data-comparison options are available for the [`equal`](expectations.md#equal) matcher.

## Syntax

```
  ut.expect( a_actual {data-type} ).to_( equal( a_expected {data-type})[.extendend_option()[.extendend_option()[...]]]);
  ut.expect( a_actual {data-type} ).not_to( equal( a_expected {data-type})[.extendend_option()[.extendend_option()[...]]]) );
  ut.expect( a_actual {data-type} ).to_equal( a_expected {data-type})[.extendend_option()[.extendend_option()[...]]]);
  ut.expect( a_actual {data-type} ).not_to_equal( a_expected {data-type})[.extendend_option()[.extendend_option()[...]]] );
```

`extended_option` can be one of:

 - `include(a_items varchar2)` - item or comma separated list of items to include
 - `exclude(a_items varchar2)` - item or comma separated list of items to exclude
 - `include(a_items ut_varchar2_list)` - table of items to include 
 - `exclude(a_items ut_varchar2_list)` - table of items to exclude
 - `unordered` - perform compare on unordered set of data, return only missing or actual
 - `join_by(a_columns varchar2)` - columns or comma seperated list of columns to join two cursors by
 - `join_by(a_columns ut_varchar2_list)` - table of columns to join two cursors by

Each item in the comma separated list can be:
- a column name of cursor to be compared
- an attribute name of object type to be compared   
- an attribute name of object type within a table of objects to be compared
- an [XPath](http://zvon.org/xxl/XPathTutorial/Output/example1.html) expression representing column/attribute
- Include and exclude option will not support implicit colum names that starts with single quota, or in fact any other special characters e.g. <, >, &

Each element in `ut_varchar2_list` nested table can be an item or a comma separated list of items.

When specifying column/attribute names, keep in mind that the names are **case sensitive**. 

**XPath expressions with comma are not supported.**

## Excluding elements from data comparison

Consider the following example
```sql
procedure test_cursors_skip_columns is
  l_expected sys_refcursor;
  l_actual   sys_refcursor;
begin
  open l_expected for select 'text' ignore_me, d.* from user_tables d;
  open l_actual   for select sysdate "ADate",  d.* from user_tables d;
  ut.expect( l_actual ).to_equal( l_expected ).exclude( 'IGNORE_ME,ADate' );
end;
```

Columns 'ignore_me' and "ADate" will get excluded from cursor comparison.
The cursor data is equal, when those columns are excluded.

This option is useful in scenarios, when you need to exclude incomparable/unpredictable column data like CREATE_DATE of a record that is maintained by default value on a table column.

## Selecting columns for data comparison

Consider the following example
```sql
procedure include_columns_as_csv is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
begin
    open l_expected for select rownum as rn, 'a' as "A_Column", 'x' SOME_COL from dual a connect by level < 4;
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'x' SOME_COL, a.* from all_objects a where rownum < 4;
    ut.expect( l_actual ).to_equal( l_expected ).include( 'RN,A_Column,SOME_COL' );
end;
```

## Combining include/exclude options
You can chain the advanced options in an expectation and mix the `varchar2` with `ut_varchar2_list` arguments.
When doing so, the fianl list of items to include/exclude will be a concatenation of all items.   

```sql
procedure include_columns_as_csv is
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
```

Only the columns 'RN', "A_Column" will be compared. Column 'SOME_COL' is excluded.

This option can be useful in scenarios where you need to narrow-down the scope of test so that the test is only focused on very specific data.  

##Unordered

Unordered option allows for quick comparison of two cursors without need of ordering them in any way.

Result of such comparison will be limited to only information about row existing or not existing in given set without actual information about exact differences.



```sql
procedure unordered_tst is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
begin
    open l_expected for select username, user_id from all_users
    union all
    select 'TEST' username, -600 user_id from dual
    order by 1 desc;
    open l_actual   for select username, user_id from all_users
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





## Join By option

You can now join two cursors by defining a primary key or composite key that will be used to uniquely identify and compare rows. This option allows us to exactly show which rows are missing, extra and which are different without ordering clause. In the situation where the join key is not unique, join will partition set over rows with a same key and join on row number as well as given join key. The extra rows or missing will be presented to user as well as not matching rows. 

Join by option can be used in conjunction with include or exclude options. However if any of the join keys is part of exclude set, comparison will fail and report to user that sets could not be joined on specific key  (excluded).

Join by options currently doesn't support nested table inside cursor.

```sql
procedure join_by_username is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
begin
    open l_expected for select username, user_id from all_users
    union all
    select 'TEST' username, -600 user_id from dual
    order by 1 desc;
    open l_actual   for select username, user_id from all_users
    union all
    select 'TEST' username, -610 user_id from dual
    order by 1 asc;
    ut.expect( l_actual ).to_equal( l_expected ).join_by('USERNAME');
end;
```
This will show you difference in row 'TEST' regardless of order.

```sql
      Rows: [ 1 differences ]
        PK <USERNAME>TEST</USERNAME> - Expected: <USER_ID>-600</USER_ID>
        PK <USERNAME>TEST</USERNAME> - Actual:   <USER_ID>-610</USER_ID>
```

Assumption is that join by is made by column name so that what will be displayed as part of results.



**Please note that .join_by option will take longer to process due to need of parsing via primary keys.**

## Defining item as XPath
When using XPath expression, keep in mind the following:

- cursor columns are nested under `<ROW>` element
- object type attributes are nested under `<OBJECTY_TYPE>` element
- nested table and varray items type attributes are nested under `<ARRAY><OBJECTY_TYPE>` elements

Example of a valid XPath parameter to include columns: `RN`, `A_Column`, `SOME_COL` in data comparison. 
```sql
procedure include_columns_as_xpath is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
begin
    open l_expected for select rownum as rn, 'a' as "A_Column", 'x' SOME_COL from dual a connect by level < 4;
    open l_actual   for select rownum as rn, 'a' as "A_Column", 'x' SOME_COL, a.* from all_objects a where rownum < 4;
    ut.expect( l_actual ).to_equal( l_expected ).include( '/ROW/RN|/ROW/A_Column|/ROW/SOME_COL' );
end;
```
