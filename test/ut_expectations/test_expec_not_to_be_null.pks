create or replace package test_expec_not_to_be_null
is
    --%suite(expectations - not_to_ve_null)
    --%suitepath(utplsql.core.expectations.no_to_be_null)

    --%test(test blob not null)
    procedure blob_not_null;

    --%test(test blob with length 0)
    procedure blob_0_lengt;

    --%test(test boolean not null)
    procedure boolean_not_null;

    --%test(test clob not null)
    procedure clob_not_null;

    --%test(test clob with length 0)
    procedure clob_0_lengt;

    --%test(test date not null)
    procedure date_not_null;

    --%test(test number not null)
    procedure number_not_null;

    --%test(test timestamp not null)
    procedure timestamp_not_null;

    --%test(test timestamp with local time zone)
    procedure timestamp_with_ltz_not_null;

    --%test(test timestamp with time zone)
    procedure timestamp_with_tz_not_null;

    --%test(test varchar2 not null)
    procedure varchar2_not_null;

    --%test(test with null blob)
    procedure null_blob;

    --%test(test with null boolean)
    procedure null_boolean;

    --%test(test with null clob)
    procedure null_clob;

    --%test(test with null date)
    procedure null_date;

    --%test(test with null number)
    procedure null_number;

    --%test(test with null timestamp)
    procedure null_timestamp;

    --%test(test with null timestamp with local time zone)
    procedure null_timestamp_with_ltz;

    --%test(test with null timestamp with time zone)
    procedure null_timestamp_with_tz;

    --%test(test with null varchar2)
    procedure null_varchar2;
end test_expec_not_to_be_null;
