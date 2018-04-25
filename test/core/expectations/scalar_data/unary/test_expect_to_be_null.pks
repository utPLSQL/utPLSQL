create or replace package test_expect_to_be_null
is
    --%suite(to_be_null)
    --%suitepath(utplsql.core.expectations.scalar_data.unary)

    --%aftereach
    procedure cleanup_expectations;

    --%beforeall
    procedure create_types;

    --%afterall
    procedure drop_types;

    --%test(Gives success with null blob)
    procedure null_blob;

    --%test(Gives success with null boolean)
    procedure null_boolean;

    --%test(Gives success with null clob)
    procedure null_clob;

    --%test(Gives success with null date)
    procedure null_date;

    --%test(Gives success with null number)
    procedure null_number;

    --%test(Gives success null timestamp)
    procedure null_timestamp;

    --%test(Gives success with null timestamp with local time zone)
    procedure null_timestamp_with_ltz;

    --%test(Gives success with null timestamp with time zone)
    procedure null_timestamp_with_tz;

    --%test(Gives success with null varchar2)
    procedure null_varchar2;

    --%test(Gives success with null anydata)
    procedure null_anydata;

    --%test(Gives success with uninitialized object within anydata)
    procedure uninit_object_in_anydata;

    --%test(Gives success with uninitialized nested table within anydata)
    procedure uninit_nested_table_in_anydata;

    --%test(Gives success with uninitialized varray within anydata)
    procedure uninit_varray_in_anydata;

    --%test(Gives failure for not null blob)
    procedure blob_not_null;

    --%test(Gives failure for blob with length 0)
    procedure blob_0_length;

    --%test(Gives failure for not null boolean)
    procedure boolean_not_null;

    --%test(Gives failure for not null clob)
    procedure clob_not_null;

    --%test(Gives failure for clob with length 0)
    procedure clob_0_length;

    --%test(Gives failure for not null date)
    procedure date_not_null;

    --%test(Gives failure for not null number)
    procedure number_not_null;

    --%test(Gives failure for not null timestamp)
    procedure timestamp_not_null;

    --%test(Gives failure for not null timestamp with local time zone)
    procedure timestamp_with_ltz_not_null;

    --%test(Gives failure for not null timestamp with time zone)
    procedure timestamp_with_tz_not_null;

    --%test(Gives failure for not null varchar2)
    procedure varchar2_not_null;

    --%test(Gives failure for initialized object within anydata)
    procedure initialized_object;

    --%test(Gives failure for initialized nested table within anydata)
    procedure initialized_nested_table;

    --%test(Gives failure for initialized varray within anydata)
    procedure initialized_varray;

end test_expect_to_be_null;
/
