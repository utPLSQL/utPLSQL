create or replace package test_expect_to_be_not_null
is
    --%suite(to_be_not_null)
    --%suitepath(utplsql.core.expectations.scalar_data.unary)

    --%aftereach
    procedure cleanup_expectations;

    --%beforeall
    procedure create_types;

    --%afterall
    procedure drop_types;

    --%test(Gives success for not null blob)
    procedure blob_not_null;

    --%test(Gives success for blob with length 0)
    procedure blob_0_length;

    --%test(Gives success for not null boolean)
    procedure boolean_not_null;

    --%test(Gives success for not null clob)
    procedure clob_not_null;

    --%test(Gives success for clob with length 0)
    procedure clob_0_length;

    --%test(Gives success for not null date)
    procedure date_not_null;

    --%test(Gives success for not null number)
    procedure number_not_null;

    --%test(Gives success for not null timestamp)
    procedure timestamp_not_null;

    --%test(Gives success for not null timestamp with local time zone)
    procedure timestamp_with_ltz_not_null;

    --%test(Gives success for not null timestamp with time zone)
    procedure timestamp_with_tz_not_null;

    --%test(Gives success for not null varchar2)
    procedure varchar2_not_null;

    --%test(Gives success for initialized object within anydata)
    procedure initialized_object;

    --%test(Gives success for initialized nested table within anydata)
    procedure initialized_nested_table;

    --%test(Gives success for initialized varray within anydata)
    procedure initialized_varray;

    --%test(Gives failure with null blob)
    procedure null_blob;

    --%test(Gives failure with null boolean)
    procedure null_boolean;

    --%test(Gives failure with null clob)
    procedure null_clob;

    --%test(Gives failure with null date)
    procedure null_date;

    --%test(Gives failure with null number)
    procedure null_number;

    --%test(Gives failure null timestamp)
    procedure null_timestamp;

    --%test(Gives failure with null timestamp with local time zone)
    procedure null_timestamp_with_ltz;

    --%test(Gives failure with null timestamp with time zone)
    procedure null_timestamp_with_tz;

    --%test(Gives failure with null varchar2)
    procedure null_varchar2;

    --%test(Gives failure with null anydata)
    procedure null_anydata;

    --%test(Gives failure with uninitialized object within anydata)
    procedure uninit_object_in_anydata;

    --%test(Gives failure with uninitialized nested table within anydata)
    procedure uninit_nested_table_in_anydata;

    --%test(Gives failure with uninitialized varray within anydata)
    procedure uninit_varray_in_anydata;

end test_expect_to_be_not_null;
/
