create or replace package test_expect_not_to_be_null
is
    --%suite(expectations - not_to_be_null)
    --%suitepath(utplsql.core.expectations.not_to_be_null)

    --%test(Gives succes for not null blob)
    procedure blob_not_null;

    --%test(Gives succes for blob with length 0)
    procedure blob_0_lengt;

    --%test(Gives succes for not null boolean)
    procedure boolean_not_null;

    --%test(Gives succes for not null clob)
    procedure clob_not_null;

    --%test(Gives succes for clob with length 0)
    procedure clob_0_lengt;

    --%test(Gives succes for not null date)
    procedure date_not_null;

    --%test(Gives succes for not null number)
    procedure number_not_null;

    --%test(Gives succes for not null timestamp)
    procedure timestamp_not_null;

    --%test(Gives succes for not null timestamp with local time zone)
    procedure timestamp_with_ltz_not_null;

    --%test(Gives succes for not null timestamp with time zone)
    procedure timestamp_with_tz_not_null;

    --%test(Gives succes for not null varchar2)
    procedure varchar2_not_null;

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
end test_expect_not_to_be_null;
