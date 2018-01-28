create or replace package test_annot_throws_exception
is
    --%suite(annotations- throws)

    --%beforeall
    procedure create_package;

    --%afterall
    procedure drop_package;

    --%test(Gives success when annotated number exception is thrown)
    procedure throws_same_annotated_except;

    --%test(Gives failure when the raised exception is different that the annotated one)
    procedure throws_diff_annotated_except;
end;
/
